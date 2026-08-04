import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../currency/currency_metadata.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

const _backupFormat = 'pocket-vault-backup';
const _backupVersion = 1;
const _kdfIterations = 210000;

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.read(databaseProvider));
});

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}

class BackupService {
  final AppDatabase _database;
  final Cipher _cipher;
  final KdfAlgorithm _kdf;
  final Future<Directory> Function() _documentsDirectory;

  BackupService(
    this._database, {
    Cipher? cipher,
    KdfAlgorithm? kdf,
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _cipher = cipher ?? AesGcm.with256bits(),
       _kdf = kdf ?? Pbkdf2.hmacSha256(iterations: _kdfIterations, bits: 256);

  Future<Uint8List> createEncryptedBackup(String password) async {
    return encryptPayload(await _buildPayload(), password);
  }

  Future<Uint8List> encryptPayload(
    Map<String, Object?> payload,
    String password,
  ) async {
    if (password.length < 8) {
      throw const BackupException('Use a password of at least 8 characters.');
    }

    final clearText = utf8.encode(jsonEncode(payload));
    final salt = SecretKeyData.random(length: 16).bytes;
    final nonce = _cipher.newNonce();
    final key = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final secretBox = await _cipher.encrypt(
      clearText,
      secretKey: key,
      nonce: nonce,
    );

    final envelope = <String, Object?>{
      'format': _backupFormat,
      'version': _backupVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'cipher': 'AES-256-GCM',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _kdfIterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
  }

  Future<void> restoreEncryptedBackup(
    Uint8List bytes,
    String password, {
    required bool replaceExisting,
  }) async {
    final payload = await decryptPayload(bytes, password);
    await _restorePayload(payload, replaceExisting: replaceExisting);
  }

  Future<Map<String, dynamic>> decryptPayload(
    Uint8List bytes,
    String password,
  ) async {
    try {
      final envelope = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (envelope['format'] != _backupFormat ||
          envelope['version'] != _backupVersion) {
        throw const BackupException('Unsupported backup format.');
      }
      final iterations = envelope['iterations'] as int? ?? _kdfIterations;
      if (iterations < 100000 || iterations > 2000000) {
        throw const BackupException('Unsafe or invalid backup parameters.');
      }
      final salt = base64Decode(envelope['salt'] as String);
      final nonce = base64Decode(envelope['nonce'] as String);
      final kdf = iterations == _kdfIterations
          ? _kdf
          : Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
      final key = await kdf.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );
      final clearText = await _cipher.decrypt(
        SecretBox(
          base64Decode(envelope['cipherText'] as String),
          nonce: nonce,
          mac: Mac(base64Decode(envelope['mac'] as String)),
        ),
        secretKey: key,
      );
      final payload =
          jsonDecode(utf8.decode(clearText)) as Map<String, dynamic>;
      return payload;
    } on SecretBoxAuthenticationError {
      throw const BackupException('Incorrect password or corrupted backup.');
    } on FormatException catch (error) {
      throw BackupException('Invalid backup: ${error.message}');
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException('The backup is invalid or corrupted.');
    }
  }

  Future<ShareResult> saveEncryptedBackup(
    String password, {
    Rect? sharePositionOrigin,
  }) async {
    final bytes = await createEncryptedBackup(password);
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final fileName = 'pocket-vault_$stamp.pvault';
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    final language =
        (await SharedPreferences.getInstance()).getString('locale') ?? 'en';
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/octet-stream')],
        fileNameOverrides: [fileName],
        subject: switch (language) {
          'it' => 'Backup cifrato Pockets Vault',
          'es' => 'Copia cifrada de Pockets Vault',
          _ => 'Encrypted Pockets Vault backup',
        },
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<Uint8List?> pickBackup() async {
    final result = await FilePicker.pickFiles(
      // FileType.any is intentional: iOS can hide custom extensions whose UTI
      // is unknown even when the document is present in Files/iCloud Drive.
      type: FileType.any,
      withData: true,
      allowMultiple: false,
    );
    final file = result?.files.single;
    if (file == null) return null;
    if (file.bytes != null) return file.bytes!;
    if (file.path != null) return File(file.path!).readAsBytes();
    throw const BackupException('Unable to read the selected backup.');
  }

  Future<Uint8List> createCsvBytes() async {
    final snapshot = await _database.exportSnapshot();
    final rows = (snapshot['transactions'] as List).cast<Map>();
    final preferences = await SharedPreferences.getInstance();
    final baseCurrency = preferences.getString('base_currency_v1') ?? 'EUR';
    final language = preferences.getString('locale') ?? 'en';
    final labels = _CsvLabels.forLanguage(language);
    final categories = {
      for (final raw in (snapshot['categories'] as List).cast<Map>())
        raw['id'] as String: raw['name'] as String,
    };
    final buffer = StringBuffer()
      ..writeln(
        [
          labels.date,
          labels.type,
          labels.category,
          labels.description,
          '${labels.amount} ($baseCurrency)',
          labels.mainCurrency,
          labels.originalAmount,
          labels.originalCurrency,
          labels.eurRate,
          labels.recurring,
          labels.receipt,
          'ID',
        ].map(_csvCell).join(';'),
      );
    for (final row in rows) {
      final date = _readDate(row['date']);
      final originalCurrency =
          row['originalCurrency'] as String? ?? baseCurrency;
      final originalAmountMinor =
          row['originalAmountMinor'] as int? ?? row['amountCents'] as int;
      buffer.writeln(
        [
          DateFormat(labels.datePattern).format(date.toLocal()),
          row['isIncome'] == true ? labels.income : labels.expense,
          _readableCategory(
            categories[row['categoryId']] ?? row['categoryId']?.toString(),
            language,
          ),
          row['note'],
          _csvAmount(row['amountCents'] as int, baseCurrency, language),
          baseCurrency,
          _csvAmount(originalAmountMinor, originalCurrency, language),
          originalCurrency,
          row['exchangeRateToEur'],
          row['isRecurring'] == true ? labels.yes : labels.no,
          row['receiptPath'] == null
              ? ''
              : p.basename(row['receiptPath'] as String),
          row['id'],
        ].map(_csvCell).join(';'),
      );
    }
    return Uint8List.fromList(utf8.encode('\uFEFF${buffer.toString()}'));
  }

  Future<ShareResult> exportCsv({Rect? sharePositionOrigin}) async {
    final bytes = await createCsvBytes();
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final fileName = 'pocket-vault_$stamp.csv';
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    final language =
        (await SharedPreferences.getInstance()).getString('locale') ?? 'en';
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        fileNameOverrides: [fileName],
        subject: switch (language) {
          'it' => 'Movimenti Pockets Vault',
          'es' => 'Movimientos de Pockets Vault',
          _ => 'Pockets Vault transactions',
        },
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<Map<String, Object?>> _buildPayload() async {
    final database = await _database.exportSnapshot();
    final receipts = <String, String>{};
    final transactions = (database['transactions'] as List).cast<Map>();
    for (final row in transactions) {
      final path = row['receiptPath'] as String?;
      if (path == null) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      final safeName = '${row['id']}${p.extension(path).toLowerCase()}';
      receipts[safeName] = base64Encode(await file.readAsBytes());
      row['receiptPath'] = 'receipts/$safeName';
    }

    final preferences = await SharedPreferences.getInstance();
    final settings = <String, Object?>{};
    for (final key in preferences.getKeys()) {
      final value = preferences.get(key);
      if (value is String || value is bool || value is int || value is double) {
        settings[key] = value;
      } else if (value is List<String>) {
        settings[key] = value;
      }
    }
    return {
      'format': _backupFormat,
      'version': _backupVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'database': database,
      'settings': settings,
      'receipts': receipts,
    };
  }

  Future<void> _restorePayload(
    Map<String, dynamic> payload, {
    required bool replaceExisting,
  }) async {
    if (payload['format'] != _backupFormat) {
      throw const BackupException('Unsupported backup payload.');
    }
    final database = Map<String, dynamic>.from(payload['database'] as Map);
    final receiptData = Map<String, dynamic>.from(
      payload['receipts'] as Map? ?? const {},
    );
    final appDirectory = await _documentsDirectory();
    final receiptDirectory = Directory(p.join(appDirectory.path, 'receipts'));
    await receiptDirectory.create(recursive: true);

    final transactions = (database['transactions'] as List? ?? const [])
        .cast<Map>();
    for (final row in transactions) {
      final relative = row['receiptPath'] as String?;
      if (relative == null) continue;
      final name = p.basename(relative);
      final encoded = receiptData[name] as String?;
      if (encoded == null) {
        row['receiptPath'] = null;
        continue;
      }
      final destination = File(p.join(receiptDirectory.path, name));
      await destination.writeAsBytes(base64Decode(encoded), flush: true);
      row['receiptPath'] = destination.path;
    }

    await _database.importSnapshot(database, replaceExisting: replaceExisting);
    if (replaceExisting) {
      final retainedPaths = transactions
          .map((row) => row['receiptPath'] as String?)
          .whereType<String>()
          .map(p.normalize)
          .toSet();
      await for (final entity in receiptDirectory.list(followLinks: false)) {
        if (entity is File &&
            !retainedPaths.contains(p.normalize(entity.path))) {
          await entity.delete();
        }
      }
    }
    final rawSettings = payload['settings'];
    if (rawSettings is Map) {
      final preferences = await SharedPreferences.getInstance();
      for (final entry in rawSettings.entries) {
        final key = entry.key as String;
        final value = entry.value;
        if (value is String) await preferences.setString(key, value);
        if (value is bool) await preferences.setBool(key, value);
        if (value is int) await preferences.setInt(key, value);
        if (value is double) await preferences.setDouble(key, value);
        if (value is List) {
          await preferences.setStringList(key, value.cast<String>());
        }
      }
    }
  }

  static DateTime _readDate(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final milliseconds = int.tryParse(value);
      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const BackupException('A transaction contains an invalid date.');
  }

  static String _csvAmount(
    int amountMinor,
    String currency,
    String language,
  ) {
    final digits = currencyDecimalDigits(currency);
    final formatter = NumberFormat.decimalPattern(language)
      ..minimumFractionDigits = digits
      ..maximumFractionDigits = digits;
    return formatter.format(minorToMajor(amountMinor, currency));
  }

  static String _readableCategory(String? value, String language) {
    final builtInNames = switch (language) {
      'it' => const <String, String>{
        'food': 'Cibo',
        'groceries': 'Supermercato',
        'transport': 'Trasporti',
        'rent': 'Affitto',
        'shopping': 'Shopping',
        'bills': 'Bollette',
        'entertainment': 'Svago',
        'health': 'Salute',
        'salary': 'Stipendio',
        'other': 'Altro',
      },
      'es' => const <String, String>{
        'food': 'Comida',
        'groceries': 'Supermercado',
        'transport': 'Transporte',
        'rent': 'Alquiler',
        'shopping': 'Compras',
        'bills': 'Facturas',
        'entertainment': 'Entretenimiento',
        'health': 'Salud',
        'salary': 'Salario',
        'other': 'Otros',
      },
      _ => const <String, String>{
        'food': 'Food',
        'groceries': 'Groceries',
        'transport': 'Transport',
        'rent': 'Rent',
        'shopping': 'Shopping',
        'bills': 'Bills',
        'entertainment': 'Entertainment',
        'health': 'Health',
        'salary': 'Salary',
        'other': 'Other',
      },
    };
    return builtInNames[value] ?? value ?? _CsvLabels.forLanguage(language).none;
  }

  static String _csvCell(Object? value) {
    final text = value?.toString() ?? '';
    if (!text.contains(RegExp('[;"\n\r]'))) return text;
    return '"${text.replaceAll('"', '""')}"';
  }
}

class _CsvLabels {
  final String date;
  final String type;
  final String category;
  final String description;
  final String amount;
  final String mainCurrency;
  final String originalAmount;
  final String originalCurrency;
  final String eurRate;
  final String recurring;
  final String receipt;
  final String income;
  final String expense;
  final String yes;
  final String no;
  final String none;
  final String datePattern;

  const _CsvLabels({
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.mainCurrency,
    required this.originalAmount,
    required this.originalCurrency,
    required this.eurRate,
    required this.recurring,
    required this.receipt,
    required this.income,
    required this.expense,
    required this.yes,
    required this.no,
    required this.none,
    required this.datePattern,
  });

  factory _CsvLabels.forLanguage(String language) {
    return switch (language) {
      'it' => const _CsvLabels(
        date: 'Data',
        type: 'Tipo',
        category: 'Categoria',
        description: 'Descrizione',
        amount: 'Importo',
        mainCurrency: 'Valuta principale',
        originalAmount: 'Importo originale',
        originalCurrency: 'Valuta originale',
        eurRate: 'Tasso verso EUR',
        recurring: 'Ricorrente',
        receipt: 'Ricevuta',
        income: 'Entrata',
        expense: 'Uscita',
        yes: 'Sì',
        no: 'No',
        none: 'Senza categoria',
        datePattern: 'dd/MM/yyyy',
      ),
      'es' => const _CsvLabels(
        date: 'Fecha',
        type: 'Tipo',
        category: 'Categoría',
        description: 'Descripción',
        amount: 'Importe',
        mainCurrency: 'Moneda principal',
        originalAmount: 'Importe original',
        originalCurrency: 'Moneda original',
        eurRate: 'Tipo hacia EUR',
        recurring: 'Recurrente',
        receipt: 'Recibo',
        income: 'Ingreso',
        expense: 'Gasto',
        yes: 'Sí',
        no: 'No',
        none: 'Sin categoría',
        datePattern: 'dd/MM/yyyy',
      ),
      _ => const _CsvLabels(
        date: 'Date',
        type: 'Type',
        category: 'Category',
        description: 'Description',
        amount: 'Amount',
        mainCurrency: 'Main currency',
        originalAmount: 'Original amount',
        originalCurrency: 'Original currency',
        eurRate: 'Rate to EUR',
        recurring: 'Recurring',
        receipt: 'Receipt',
        income: 'Income',
        expense: 'Expense',
        yes: 'Yes',
        no: 'No',
        none: 'Uncategorized',
        datePattern: 'MM/dd/yyyy',
      ),
    };
  }
}
