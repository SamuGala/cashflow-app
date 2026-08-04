import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/domain/category.dart';
import '../currency/currency_metadata.dart';
import 'receipt_storage_service.dart';

final receiptOcrServiceProvider = Provider<ReceiptOcrService>((ref) {
  return const ReceiptOcrService();
});

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(
    storage: ref.read(receiptStorageServiceProvider),
    ocr: ref.read(receiptOcrServiceProvider),
  );
});

class ReceiptOcrLine {
  final String text;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  const ReceiptOcrLine({
    required this.text,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory ReceiptOcrLine.fromMap(Map<Object?, Object?> map) {
    double number(String key) => (map[key] as num?)?.toDouble() ?? 0;
    return ReceiptOcrLine(
      text: map['text'] as String? ?? '',
      confidence: number('confidence'),
      x: number('x'),
      y: number('y'),
      width: number('width'),
      height: number('height'),
    );
  }
}

class ReceiptOcrService {
  static const _channel = MethodChannel('pocket_vault/receipt_ocr');

  const ReceiptOcrService();

  Future<List<ReceiptOcrLine>> recognize(String imagePath) async {
    final raw = await _channel.invokeListMethod<Object?>('recognize', {
      'path': imagePath,
    });
    return (raw ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(ReceiptOcrLine.fromMap)
        .where((line) => line.text.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class ReceiptExtraction {
  final int? amountMinor;
  final String currencyCode;
  final DateTime? date;
  final String? merchant;
  final String? categoryId;
  final double confidence;
  final String recognizedText;

  const ReceiptExtraction({
    required this.amountMinor,
    required this.currencyCode,
    required this.date,
    required this.merchant,
    required this.categoryId,
    required this.confidence,
    required this.recognizedText,
  });

  int get detectedFieldCount => [
    amountMinor,
    date,
    merchant,
    categoryId,
  ].where((value) => value != null).length;

  ReceiptExtraction copyWith({
    int? amountMinor,
    bool clearAmount = false,
    String? currencyCode,
    DateTime? date,
    bool clearDate = false,
    String? merchant,
    bool clearMerchant = false,
    String? categoryId,
    bool clearCategory = false,
  }) {
    return ReceiptExtraction(
      amountMinor: clearAmount ? null : amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      date: clearDate ? null : date ?? this.date,
      merchant: clearMerchant ? null : merchant ?? this.merchant,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      confidence: confidence,
      recognizedText: recognizedText,
    );
  }
}

class ReceiptScanDraft {
  final String imagePath;
  final ReceiptExtraction? extraction;
  final bool automaticReadFailed;

  const ReceiptScanDraft({
    required this.imagePath,
    required this.extraction,
    this.automaticReadFailed = false,
  });
}

class ReceiptScannerService {
  final ReceiptStorageService storage;
  final ReceiptOcrService ocr;

  const ReceiptScannerService({required this.storage, required this.ocr});

  Future<ReceiptScanDraft?> scanCamera({
    required Iterable<Category> categories,
    required String fallbackCurrency,
  }) {
    return _scan(
      pick: storage.capture,
      categories: categories,
      fallbackCurrency: fallbackCurrency,
    );
  }

  Future<ReceiptScanDraft?> scanLibrary({
    required Iterable<Category> categories,
    required String fallbackCurrency,
  }) {
    return _scan(
      pick: storage.chooseFromLibrary,
      categories: categories,
      fallbackCurrency: fallbackCurrency,
    );
  }

  Future<ReceiptScanDraft> scanStoredImage({
    required String imagePath,
    required Iterable<Category> categories,
    required String fallbackCurrency,
  }) {
    return _analyze(
      imagePath: imagePath,
      categories: categories,
      fallbackCurrency: fallbackCurrency,
    );
  }

  Future<ReceiptScanDraft?> _scan({
    required Future<String?> Function() pick,
    required Iterable<Category> categories,
    required String fallbackCurrency,
  }) async {
    final path = await pick();
    if (path == null) return null;
    return _analyze(
      imagePath: path,
      categories: categories,
      fallbackCurrency: fallbackCurrency,
    );
  }

  Future<ReceiptScanDraft> _analyze({
    required String imagePath,
    required Iterable<Category> categories,
    required String fallbackCurrency,
  }) async {
    try {
      final lines = await ocr.recognize(imagePath);
      return ReceiptScanDraft(
        imagePath: imagePath,
        extraction: ReceiptParser.parse(
          lines: lines,
          categories: categories,
          fallbackCurrency: fallbackCurrency,
        ),
      );
    } on PlatformException {
      return ReceiptScanDraft(
        imagePath: imagePath,
        extraction: null,
        automaticReadFailed: true,
      );
    } on MissingPluginException {
      return ReceiptScanDraft(
        imagePath: imagePath,
        extraction: null,
        automaticReadFailed: true,
      );
    } catch (_) {
      // The image is still valuable as an attachment even if automatic
      // extraction fails on an unusual format or damaged file.
      return ReceiptScanDraft(
        imagePath: imagePath,
        extraction: null,
        automaticReadFailed: true,
      );
    }
  }
}

class ReceiptParser {
  static final _amountPattern = RegExp(
    r"(?:\d{1,3}(?:[, .’']\d{3})+(?:[,.]\d{1,2})?|\d+[,.]\d{1,2}|\d+)",
  );
  static final _totalPattern = RegExp(
    r'\b(grand\s+total|totale|total|tot\.?|da\s+pagare|importo|amount\s+due|amount|importe|a\s+pagar|suma)\b',
    caseSensitive: false,
  );
  static final _negativeAmountPattern = RegExp(
    r'\b(subtotale|subtotal|imponibile|iva|vat|tax|imposta|resto|change|cash|contanti|pagato|tendered|sconto|discount)\b',
    caseSensitive: false,
  );
  static final _currencyCodePattern = RegExp(
    r'\b(EUR|USD|GBP|CHF|JPY|AUD|CAD|CNY|CZK|DKK|HUF|NOK|PLN|RON|SEK|BGN|BRL|HKD|IDR|ILS|INR|KRW|MXN|MYR|NZD|PHP|SGD|THB|TRY|ZAR)\b',
    caseSensitive: false,
  );

  static ReceiptExtraction parse({
    required Iterable<ReceiptOcrLine> lines,
    required Iterable<Category> categories,
    required String fallbackCurrency,
    DateTime? now,
  }) {
    final cleanLines = lines
        .map(
          (line) => ReceiptOcrLine(
            text: line.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
            confidence: line.confidence,
            x: line.x,
            y: line.y,
            width: line.width,
            height: line.height,
          ),
        )
        .where((line) => line.text.isNotEmpty)
        .toList(growable: false);
    final fullText = cleanLines.map((line) => line.text).join('\n');
    final currency = _currency(fullText, fallbackCurrency);
    final amountCandidate = _amount(cleanLines, currency);
    final merchant = _merchant(cleanLines);
    final date = _date(cleanLines, now ?? DateTime.now());
    final categoryId = cleanLines.isEmpty
        ? null
        : _category(
            '${merchant ?? ''}\n$fullText',
            categories.where((category) => !category.isIncome),
          );
    final fields = [amountCandidate?.minor, date, merchant, categoryId];
    final detected = fields.where((field) => field != null).length;
    final ocrConfidence = cleanLines.isEmpty
        ? 0.0
        : cleanLines
                  .map((line) => line.confidence)
                  .where((value) => value > 0)
                  .fold<double>(0, (sum, value) => sum + value) /
              cleanLines
                  .where((line) => line.confidence > 0)
                  .length
                  .clamp(1, cleanLines.length);
    final structuralConfidence = detected / fields.length;
    return ReceiptExtraction(
      amountMinor: amountCandidate?.minor,
      currencyCode: currency,
      date: date,
      merchant: merchant,
      categoryId: categoryId,
      confidence: (structuralConfidence * .75 + ocrConfidence * .25).clamp(
        0,
        1,
      ),
      recognizedText: fullText,
    );
  }

  static String _currency(String text, String fallback) {
    final codeMatch = _currencyCodePattern.firstMatch(text);
    if (codeMatch != null) return codeMatch.group(1)!.toUpperCase();
    if (text.contains('€')) return 'EUR';
    if (text.contains('£')) return 'GBP';
    if (text.contains('CHF') || text.contains(RegExp(r'\bFr\.?\s*\d'))) {
      return 'CHF';
    }
    if (text.contains('₹')) return 'INR';
    if (text.contains('₩')) return 'KRW';
    if (text.contains('₺')) return 'TRY';
    if (text.contains('zł')) return 'PLN';
    if (text.contains('¥')) return fallback == 'CNY' ? 'CNY' : 'JPY';
    if (text.contains(r'$')) {
      const dollarCurrencies = {'USD', 'AUD', 'CAD', 'NZD', 'HKD', 'SGD'};
      return dollarCurrencies.contains(fallback) ? fallback : 'USD';
    }
    return supportedCurrencyCodes.contains(fallback) ? fallback : 'EUR';
  }

  static _AmountCandidate? _amount(
    List<ReceiptOcrLine> lines,
    String currency,
  ) {
    _AmountCandidate? best;
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex].text;
      final semanticLine =
          !RegExp(r'[A-Za-zÀ-ÿ]{4,}').hasMatch(line) && lineIndex > 0
          ? '${lines[lineIndex - 1].text} $line'
          : line;
      final isTotal = _totalPattern.hasMatch(semanticLine);
      final isNegative = _negativeAmountPattern.hasMatch(semanticLine);
      final hasCurrency =
          _currencyCodePattern.hasMatch(line) ||
          line.contains(RegExp(r'[€$£¥₹₩₺]')) ||
          line.toLowerCase().contains('chf');
      for (final match in _amountPattern.allMatches(line)) {
        final token = match.group(0)!;
        final value = _parseNumber(token, currency);
        if (value == null || value <= 0 || value > 1000000) continue;
        final hasDecimal = RegExp(r'[,.]\d{1,2}$').hasMatch(token);
        if (!isTotal && !hasCurrency && !hasDecimal) continue;
        var score = lineIndex / lines.length.clamp(1, 100) * 1.5;
        if (isTotal) score += 9;
        if (isNegative) score -= 8;
        if (hasCurrency) score += 2;
        if (hasDecimal) score += 2;
        score += lines[lineIndex].confidence.clamp(0, 1);
        final candidate = _AmountCandidate(
          minor: majorToMinor(value, currency),
          score: score,
        );
        if (best == null ||
            candidate.score > best.score ||
            (candidate.score == best.score && candidate.minor > best.minor)) {
          best = candidate;
        }
      }
    }
    return best != null && best.score >= 2 ? best : null;
  }

  static double? _parseNumber(String token, String currency) {
    var value = token.replaceAll(RegExp(r"[\s’']"), '');
    final comma = value.lastIndexOf(',');
    final dot = value.lastIndexOf('.');
    if (comma >= 0 && dot >= 0) {
      final decimal = comma > dot ? ',' : '.';
      final thousands = decimal == ',' ? '.' : ',';
      value = value.replaceAll(thousands, '').replaceAll(decimal, '.');
    } else if (comma >= 0 || dot >= 0) {
      final separator = comma >= 0 ? ',' : '.';
      final suffixLength = value.length - value.lastIndexOf(separator) - 1;
      final isDecimal = suffixLength == 1 || suffixLength == 2;
      value = isDecimal
          ? value.replaceAll(separator, '.')
          : value.replaceAll(separator, '');
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    if (currencyDecimalDigits(currency) == 0) return parsed.roundToDouble();
    return parsed;
  }

  static DateTime? _date(List<ReceiptOcrLine> lines, DateTime now) {
    // Vision and ML Kit occasionally read a narrow slash as a vertical bar.
    final numeric = RegExp(r'\b(\d{1,2})[./|\-](\d{1,2})[./|\-](\d{2,4})\b');
    final iso = RegExp(r'\b(20\d{2})[./|\-](\d{1,2})[./|\-](\d{1,2})\b');
    final textual = RegExp(
      r'\b(\d{1,2})\s+(gen(?:naio)?|jan(?:uary)?|ene(?:ro)?|feb(?:braio|ruary|rero)?|mar(?:zo|ch)?|abr(?:il)?|apr(?:ile)?|mag(?:gio)?|may|mayo|giu(?:gno)?|jun(?:e|io)?|lug(?:lio)?|jul(?:y|io)?|ago(?:sto)?|aug(?:ust|osto)?|set(?:tembre)?|sep(?:tember|tiembre)?|ott(?:obre)?|oct(?:ober|ubre)?|nov(?:ember|embre|iembre)?|dic(?:embre)?|dec(?:ember)?|diciembre)\s+(\d{2,4})\b',
      caseSensitive: false,
    );
    final candidates = <_DateCandidate>[];
    for (var index = 0; index < lines.length; index++) {
      final text = lines[index].text;
      final dateKeyword = RegExp(
        r'\b(data|date|fecha)\b',
        caseSensitive: false,
      ).hasMatch(text);
      for (final match in iso.allMatches(text)) {
        _addDate(
          candidates,
          year: int.parse(match.group(1)!),
          month: int.parse(match.group(2)!),
          day: int.parse(match.group(3)!),
          score: (dateKeyword ? 4 : 0) + (lines.length - index) / lines.length,
          now: now,
        );
      }
      for (final match in numeric.allMatches(text)) {
        var year = int.parse(match.group(3)!);
        if (year < 100) year += 2000;
        _addDate(
          candidates,
          year: year,
          month: int.parse(match.group(2)!),
          day: int.parse(match.group(1)!),
          score: (dateKeyword ? 4 : 0) + (lines.length - index) / lines.length,
          now: now,
        );
      }
      for (final match in textual.allMatches(text)) {
        var year = int.parse(match.group(3)!);
        if (year < 100) year += 2000;
        _addDate(
          candidates,
          year: year,
          month: _monthNumber(match.group(2)!),
          day: int.parse(match.group(1)!),
          score: (dateKeyword ? 4 : 0) + 1.5,
          now: now,
        );
      }
    }
    candidates.sort((first, second) => second.score.compareTo(first.score));
    return candidates.firstOrNull?.date;
  }

  static void _addDate(
    List<_DateCandidate> output, {
    required int year,
    required int month,
    required int day,
    required double score,
    required DateTime now,
  }) {
    if (year < 2000 || year > now.year + 1 || month < 1 || month > 12) return;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return;
    output.add(_DateCandidate(date, score));
  }

  static int _monthNumber(String value) {
    final month = _normalize(value);
    if (month.startsWith('gen') ||
        month.startsWith('jan') ||
        month.startsWith('ene')) {
      return 1;
    }
    if (month.startsWith('feb')) return 2;
    if (month.startsWith('mar')) return 3;
    if (month.startsWith('apr') || month.startsWith('abr')) return 4;
    if (month.startsWith('mag') || month.startsWith('may')) return 5;
    if (month.startsWith('giu') || month.startsWith('jun')) return 6;
    if (month.startsWith('lug') || month.startsWith('jul')) return 7;
    if (month.startsWith('ago') || month.startsWith('aug')) return 8;
    if (month.startsWith('set') || month.startsWith('sep')) return 9;
    if (month.startsWith('ott') || month.startsWith('oct')) return 10;
    if (month.startsWith('nov')) return 11;
    return 12;
  }

  static String? _merchant(List<ReceiptOcrLine> lines) {
    _MerchantCandidate? best;
    final limit = lines.length.clamp(0, 10);
    for (var index = 0; index < limit; index++) {
      final text = lines[index].text.trim();
      final normalized = _normalize(text);
      final letters = RegExp(r'[A-Za-zÀ-ÿ]').allMatches(text).length;
      if (letters < 3 || text.length > 48) continue;
      if (RegExp(
        r'\b(scontrino|ricevuta|receipt|factura|ticket|totale|total|iva|vat|p\.iva|telefono|phone|tel\.?|www\.|@|data|date|fecha|cassa|cashier|documento)\b',
        caseSensitive: false,
      ).hasMatch(normalized)) {
        continue;
      }
      if (RegExp(r'\d{4,}').hasMatch(text)) continue;
      var score = (10 - index) * .7 + lines[index].confidence.clamp(0, 1);
      final upperLetters = RegExp(r'[A-ZÀ-Þ]').allMatches(text).length;
      if (upperLetters / letters > .75) score += 2;
      if (!text.contains(RegExp(r'\d'))) score += 1;
      final candidate = _MerchantCandidate(_displayMerchant(text), score);
      if (best == null || candidate.score > best.score) best = candidate;
    }
    return best?.value;
  }

  static String _displayMerchant(String value) {
    final letters = RegExp(r'[A-Za-zÀ-ÿ]').allMatches(value).length;
    final upper = RegExp(r'[A-ZÀ-Þ]').allMatches(value).length;
    if (letters == 0 || upper / letters < .8 || value.length <= 5) return value;
    return value
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word.substring(0, 1).toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String? _category(String text, Iterable<Category> categories) {
    final items = categories.toList(growable: false);
    if (items.isEmpty) return null;
    final normalized = _normalize(text);
    final scores = <String, int>{};
    for (final category in items) {
      final name = _normalize(category.name);
      // Short custom names (for example "SIM") are too ambiguous for OCR:
      // substring matching them caused unrelated merchants to win. Require a
      // meaningful complete phrase and let known merchant/product signals win.
      if (name.length >= 4 && _containsPhrase(normalized, name)) {
        final weight = category.isDefault ? 4 : 7;
        scores.update(
          category.id,
          (value) => value + weight,
          ifAbsent: () => weight,
        );
      }
    }
    for (final entry in _categoryKeywords.entries) {
      final category = items.where((item) => item.id == entry.key).firstOrNull;
      if (category == null) continue;
      for (final keyword in entry.value) {
        if (_containsPhrase(normalized, keyword)) {
          scores.update(entry.key, (value) => value + 5, ifAbsent: () => 5);
        }
      }
    }
    if (scores.isNotEmpty) {
      final sorted = scores.entries.toList()
        ..sort((first, second) {
          final score = second.value.compareTo(first.value);
          return score != 0 ? score : first.key.compareTo(second.key);
        });
      return sorted.first.key;
    }
    return items.where((category) => category.id == 'other').firstOrNull?.id;
  }

  static bool _containsPhrase(String normalizedText, String phrase) {
    final normalizedPhrase = _normalize(phrase);
    if (normalizedPhrase.isEmpty) return false;
    return ' $normalizedText '.contains(' $normalizedPhrase ');
  }

  static String _normalize(String value) {
    var result = value.toLowerCase();
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    accents.forEach((source, replacement) {
      result = result.replaceAll(source, replacement);
    });
    return result.replaceAll(RegExp(r'[^a-z0-9€$£¥₹₩₺]+'), ' ').trim();
  }

  static const _categoryKeywords = <String, List<String>>{
    'groceries': [
      'supermercato',
      'supermarket',
      'market',
      'mercado',
      'alimentari',
      'grocery',
      'conad',
      'coop',
      'esselunga',
      'lidl',
      'aldi',
      'carrefour',
      'eurospin',
      'mercadona',
      'walmart',
      'tesco',
    ],
    'food': [
      'ristorante',
      'restaurant',
      'restaurante',
      'pizzeria',
      'trattoria',
      'cafe',
      'caffe',
      'burger',
      'mcdonald',
      'deliveroo',
      'just eat',
      'uber eats',
    ],
    'transport': [
      'carburante',
      'benzina',
      'diesel',
      'fuel',
      'taxi',
      'uber',
      'parcheggio',
      'parking',
      'trenitalia',
      'renfe',
      'metro',
      'autostrade',
    ],
    'health': [
      'farmacia',
      'pharmacy',
      'hospital',
      'ospedale',
      'clinica',
      'clinic',
      'dentist',
    ],
    'shopping': [
      'amazon',
      'zara',
      'ikea',
      'clothing',
      'abbigliamento',
      'department store',
      'apple store',
    ],
    'entertainment': [
      'cinema',
      'theatre',
      'teatro',
      'netflix',
      'spotify',
      'ticket',
      'bowling',
    ],
    'travel': [
      'hotel',
      'airbnb',
      'booking',
      'airline',
      'aeroporto',
      'airport',
      'flight',
      'volo',
    ],
    'education': [
      'feltrinelli',
      'mondadori',
      'libraccio',
      'ibs',
      'libreria',
      'bookstore',
      'bookshop',
      'libro',
      'libri',
      'book',
      'books',
      'isbn',
      'cartoleria',
      'stationery',
      'university',
      'universita',
      'school',
      'scuola',
      'course',
      'corso',
    ],
    'bills': [
      'elettricita',
      'electricity',
      'utility',
      'telecom',
      'internet',
      'energia',
      'acqua',
    ],
  };
}

class _AmountCandidate {
  final int minor;
  final double score;

  const _AmountCandidate({required this.minor, required this.score});
}

class _DateCandidate {
  final DateTime date;
  final double score;

  const _DateCandidate(this.date, this.score);
}

class _MerchantCandidate {
  final String value;
  final double score;

  const _MerchantCandidate(this.value, this.score);
}
