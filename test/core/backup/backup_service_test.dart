import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/backup/backup_service.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late BackupService service;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'locale': 'it',
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = BackupService(database);
  });

  tearDown(() => database.close());

  test(
    'encrypted backup payload round-trips without leaking clear text',
    () async {
      final payload = <String, Object?>{
        'format': 'pocket-vault-backup',
        'secret': 'salary 2500',
        'items': [1, 2, 3],
      };
      final encrypted = await service.encryptPayload(payload, 'correct horse');
      final restored = await service.decryptPayload(encrypted, 'correct horse');

      expect(String.fromCharCodes(encrypted), isNot(contains('salary 2500')));
      expect(restored['secret'], 'salary 2500');
      expect(restored['items'], [1, 2, 3]);
    },
  );

  test('wrong password is rejected', () async {
    final encrypted = await service.encryptPayload(const {
      'format': 'pocket-vault-backup',
    }, 'correct horse');

    expect(
      () => service.decryptPayload(
        Uint8List.fromList(encrypted),
        'wrong password',
      ),
      throwsA(isA<BackupException>()),
    );
  });

  test(
    'CSV uses readable dates, major amounts and explicit currencies',
    () async {
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-1',
          amountCents: 12345,
          isIncome: false,
          categoryId: 'food',
          date: DateTime(2026, 7, 31),
          note: const Value('Pranzo, lavoro'),
          originalAmountMinor: const Value(15000),
          originalCurrency: const Value('USD'),
          exchangeRateToEur: const Value(.823),
        ),
      );

      final csv = String.fromCharCodes(await service.createCsvBytes());

      expect(csv, contains('Data;Tipo;Categoria;Descrizione;Importo (EUR)'));
      expect(csv, contains('31/07/2026;Uscita;Cibo'));
      expect(csv, contains('123,45;EUR;150,00;USD'));
      expect(csv, isNot(contains('178545')));
    },
  );

  test(
    'encrypted backup restores database and settings in merge/replace modes',
    () async {
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: 'source-transaction',
          amountCents: 4250,
          isIncome: false,
          categoryId: 'food',
          date: DateTime(2026, 7, 31),
        ),
      );
      final encrypted = await service.createEncryptedBackup('password sicura');
      final target = AppDatabase.forTesting(NativeDatabase.memory());
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'pocket-vault-backup-test-',
      );
      final targetService = BackupService(
        target,
        documentsDirectory: () async => temporaryDirectory,
      );

      try {
        await target.insertTransaction(
          TransactionsCompanion.insert(
            id: 'target-only',
            amountCents: 100,
            isIncome: true,
            categoryId: 'salary',
            date: DateTime(2026, 1, 1),
          ),
        );
        SharedPreferences.setMockInitialValues({'base_currency_v1': 'USD'});
        await targetService.restoreEncryptedBackup(
          encrypted,
          'password sicura',
          replaceExisting: false,
        );

        var restored = await target.getAllTransactions();
        expect(restored.map((row) => row.id).toSet(), {
          'source-transaction',
          'target-only',
        });
        expect(
          (await SharedPreferences.getInstance()).getString('base_currency_v1'),
          'EUR',
        );

        await targetService.restoreEncryptedBackup(
          encrypted,
          'password sicura',
          replaceExisting: true,
        );
        restored = await target.getAllTransactions();
        expect(restored.map((row) => row.id), ['source-transaction']);
        expect(restored.single.amountCents, 4250);
      } finally {
        await target.close();
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );
}
