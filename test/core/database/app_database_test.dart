import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'concurrent recurring generation creates one monthly transaction',
    () async {
      await database
          .into(database.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              id: 'rent-recurring',
              amountCents: 90000,
              isIncome: false,
              categoryId: 'rent',
              dayOfMonth: 5,
              startDate: DateTime(2026, 7, 1),
            ),
          );

      final asOf = DateTime(2026, 7, 31, 12);
      final results = await Future.wait([
        database.generateRecurringTransactions(asOf: asOf),
        database.generateRecurringTransactions(asOf: asOf),
      ]);
      await database.generateRecurringTransactions(asOf: asOf);

      final transactions = await database.getAllTransactions();
      final recurring = await database
          .select(database.recurringTransactions)
          .getSingle();

      expect(results, [1, 1]);
      expect(transactions, hasLength(1));
      expect(transactions.single.date, DateTime(2026, 7, 5));
      expect(recurring.lastGenerated, DateTime(2026, 7, 5));
    },
  );

  test('recurring generation never predates its start date', () async {
    await database
        .into(database.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'future-recurring',
            amountCents: 2500,
            isIncome: false,
            categoryId: 'food',
            dayOfMonth: 5,
            startDate: DateTime(2026, 7, 20),
          ),
        );

    await database.generateRecurringTransactions(asOf: DateTime(2026, 7, 31));

    expect(await database.getAllTransactions(), isEmpty);
  });

  test(
    'repairs daily and weekly occurrences shifted by 2.0.0 DST math',
    () async {
      // Rows exactly as 2.0.0 stored them after the 25 October 2026 fall-back:
      // the intended day minus one hour, i.e. 23:00 of the previous day.
      for (final (id, frequency) in [('walk', 'daily'), ('gym', 'weekly')]) {
        await database
            .into(database.recurringTransactions)
            .insert(
              RecurringTransactionsCompanion.insert(
                id: id,
                amountCents: 500,
                isIncome: false,
                categoryId: 'health',
                dayOfMonth: 19,
                startDate: DateTime(2026, 10, 19),
                frequency: Value(frequency),
                dayOfWeek: Value(
                  frequency == 'weekly' ? DateTime.monday : null,
                ),
                lastGenerated: Value(
                  frequency == 'daily'
                      ? DateTime(2026, 10, 27, 23)
                      : DateTime(2026, 10, 25, 23),
                ),
              ),
            );
      }
      Future<void> legacy(String source, DateTime date) => database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: '$source:${date.toIso8601String()}',
              amountCents: 500,
              isIncome: false,
              categoryId: 'health',
              date: date,
              isRecurring: const Value(true),
              createdAt: Value(date),
              recurringSourceId: Value(source),
              recurringOccurrenceKey: Value(
                '$source:${date.toIso8601String()}',
              ),
            ),
          );
      for (var day = 19; day <= 25; day++) {
        await legacy('walk', DateTime(2026, 10, day));
      }
      for (var day = 25; day <= 27; day++) {
        await legacy('walk', DateTime(2026, 10, day, 23));
      }
      await legacy('gym', DateTime(2026, 10, 19));
      await legacy('gym', DateTime(2026, 10, 25, 23));
      // A manual expense at 23:00 is the user's own data and stays untouched.
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: 'late-dinner',
          amountCents: 3000,
          isIncome: false,
          categoryId: 'food',
          date: DateTime(2026, 10, 25, 23),
        ),
      );

      for (var run = 0; run < 2; run++) {
        await database.generateRecurringTransactions(
          asOf: DateTime(2026, 11, 3, 15),
        );
      }

      final rows = await database.getAllTransactions();
      List<DateTime> datesOf(String source) =>
          rows
              .where((t) => t.recurringSourceId == source)
              .map((t) => t.date)
              .toList()
            ..sort();
      expect(datesOf('walk'), [
        for (var day = 19; day <= 34; day++) DateTime(2026, 10, day),
      ]);
      expect(datesOf('gym'), [
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 26),
        DateTime(2026, 11, 2),
      ]);
      expect(
        rows.singleWhere((t) => t.id == 'late-dinner').date,
        DateTime(2026, 10, 25, 23),
      );
      final cursors = await database
          .select(database.recurringTransactions)
          .get();
      expect(cursors.map((r) => r.lastGenerated), [
        DateTime(2026, 11, 3),
        DateTime(2026, 11, 2),
      ]);
    },
  );

  test('categories are ordered by their most recent use', () async {
    await database.markCategoryUsed('food', usedAt: DateTime(2026, 7, 30));
    await database.markCategoryUsed('transport', usedAt: DateTime(2026, 7, 31));

    final categories = await database.getAllCategories();

    expect(categories.take(2).map((category) => category.id), [
      'transport',
      'food',
    ]);
  });

  test('category deletion is blocked by budgets', () async {
    final now = DateTime(2026, 7, 31);
    await database
        .into(database.budgets)
        .insert(
          BudgetRow(
            id: 'food-budget',
            categoryId: 'food',
            amountMinor: 30000,
            eurAmountMicros: 300000000,
            periodType: 'monthly',
            rollover: false,
            active: true,
            createdAt: now,
            updatedAt: now,
          ),
        );

    expect(await database.deleteCategoryIfUnused('food'), isFalse);
    expect(
      (await database.getAllCategories()).any((item) => item.id == 'food'),
      isTrue,
    );
  });

  test('a hidden legacy rule does not block category deletion', () async {
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'legacy-category',
            name: 'Legacy',
            isIncome: false,
            icon: 1,
            color: 1,
          ),
        );
    await database
        .into(database.categorizationRules)
        .insert(
          CategorizationRulesCompanion.insert(
            id: 'legacy-rule',
            pattern: 'legacy',
            categoryId: 'legacy-category',
            createdAt: DateTime(2026, 7, 31),
          ),
        );

    expect(await database.deleteCategoryIfUnused('legacy-category'), isTrue);
    expect(await database.select(database.categorizationRules).get(), isEmpty);
  });

  test(
    'invalid backup import is rejected before existing data is changed',
    () async {
      final snapshot = await database.exportSnapshot();
      final transactions = snapshot['transactions'] as List;
      transactions.add({
        'id': 'dangling',
        'amountCents': 100,
        'isIncome': false,
        'categoryId': 'missing-category',
        'note': null,
        'date': DateTime(2026, 7, 31).millisecondsSinceEpoch,
        'isRecurring': false,
        'originalAmountMinor': 100,
        'originalCurrency': 'EUR',
        'eurAmountMicros': 1000000,
        'exchangeRateToEur': 1.0,
        'receiptPath': null,
        'createdAt': null,
        'recurringSourceId': null,
        'recurringOccurrenceKey': null,
      });

      await expectLater(
        database.importSnapshot(
          Map<String, dynamic>.from(snapshot),
          replaceExisting: true,
        ),
        throwsFormatException,
      );
      expect(await database.getAllCategories(), isNotEmpty);
    },
  );

  test('legacy backups preserve saved goal money as a contribution', () async {
    final updatedAt = DateTime(2026, 7, 20, 12);
    await database
        .into(database.savingsGoals)
        .insert(
          SavingsGoalRow(
            id: 'holiday',
            name: 'Holiday',
            targetAmountMinor: 100000,
            savedAmountMinor: 25000,
            targetEurMicros: 1000000000,
            savedEurMicros: 250000000,
            currencyCode: 'EUR',
            icon: 1,
            color: 0xFF4F46E5,
            completed: false,
            archived: false,
            createdAt: DateTime(2026, 7, 1),
            updatedAt: updatedAt,
          ),
        );
    final snapshot = await database.exportSnapshot();
    snapshot
      ..remove('savingsGoalContributions')
      ..['schemaVersion'] = 7;
    (snapshot['categories'] as List).removeWhere(
      (row) => (row as Map)['id'] == 'other',
    );

    await database.importSnapshot(snapshot, replaceExisting: true);

    final goals = await database.select(database.savingsGoals).get();
    final contributions = await database
        .select(database.savingsGoalContributions)
        .get();
    expect(goals.single.savedAmountMinor, 25000);
    expect(contributions, hasLength(1));
    expect(contributions.single.id, 'legacy:holiday');
    expect(contributions.single.amountMinor, 25000);
    expect(contributions.single.createdAt, updatedAt);
    expect(
      (await database.getAllCategories()).any(
        (category) => category.id == 'other' && category.isDefault,
      ),
      isTrue,
    );
  });

  for (final legacyVersion in [2, 3, 5, 10]) {
    test(
      'schema $legacyVersion upgrades without losing existing financial data',
      () async {
        await database.close();
        final directory = await Directory.systemTemp.createTemp(
          'pocket-vault-v$legacyVersion-',
        );
        final file = File('${directory.path}/cashflow.sqlite');
        final legacy = sqlite.sqlite3.open(file.path);
        _createLegacySchema(legacy, legacyVersion);
        legacy.close();

        final upgraded = AppDatabase.forTesting(NativeDatabase(file));
        try {
          final transactions = await upgraded.getAllTransactions();
          final categories = await upgraded.getAllCategories();
          final recurring = await upgraded
              .select(upgraded.recurringTransactions)
              .get();

          expect(transactions, hasLength(1));
          expect(transactions.single.id, 'legacy-transaction');
          expect(transactions.single.amountCents, 1299);
          expect(transactions.single.originalAmountMinor, 1299);
          expect(transactions.single.originalCurrency, 'EUR');
          expect(
            categories.any(
              (category) =>
                  category.id == 'custom-books' &&
                  category.name == 'I miei libri',
            ),
            isTrue,
          );
          expect(categories.any((category) => category.id == 'other'), isTrue);
          expect(
            recurring.map((item) => item.id),
            legacyVersion >= 5 ? contains('legacy-recurring') : isEmpty,
          );

          expect(await upgraded.select(upgraded.budgets).get(), isEmpty);
          expect(await upgraded.select(upgraded.savingsGoals).get(), isEmpty);
          expect(
            await upgraded.select(upgraded.savingsGoalContributions).get(),
            isEmpty,
          );

          final goalColumns = await upgraded
              .customSelect('PRAGMA table_info("savings_goals")')
              .get();
          expect(
            goalColumns
                .where((row) => row.read<String>('name') == 'archived')
                .length,
            1,
          );
          final schema = await upgraded
              .customSelect('PRAGMA user_version')
              .getSingle();
          expect(schema.read<int>('user_version'), upgraded.schemaVersion);
        } finally {
          await upgraded.close();
          await directory.delete(recursive: true);
        }
      },
    );
  }
}

void _createLegacySchema(sqlite.Database db, int version) {
  db.execute('''
    CREATE TABLE transactions (
      id TEXT NOT NULL${version < 5 ? ' PRIMARY KEY' : ''},
      amount_cents INTEGER NOT NULL,
      is_income INTEGER NOT NULL CHECK (is_income IN (0, 1)),
      category_id TEXT NOT NULL,
      note TEXT NULL,
      date INTEGER NOT NULL
      ${version >= 5 ? ', is_recurring INTEGER NOT NULL DEFAULT 0 CHECK (is_recurring IN (0, 1))' : ''}
    )
  ''');
  db.execute('''
    CREATE TABLE categories (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      is_income INTEGER NOT NULL CHECK (is_income IN (0, 1)),
      icon INTEGER NOT NULL,
      color INTEGER NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))
    )
  ''');
  if (version >= 5) {
    db.execute('''
      CREATE TABLE recurring_transactions (
        id TEXT NOT NULL PRIMARY KEY,
        amount_cents INTEGER NOT NULL,
        is_income INTEGER NOT NULL CHECK (is_income IN (0, 1)),
        category_id TEXT NOT NULL,
        day_of_month INTEGER NOT NULL,
        start_date INTEGER NOT NULL,
        note TEXT NULL,
        active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
        last_generated INTEGER NULL
      )
    ''');
  }
  db.execute('''
    INSERT INTO categories
      (id, name, is_income, icon, color, is_default)
    VALUES ('custom-books', 'I miei libri', 0, 59404, 4280722074, 0)
  ''');
  db.execute('''
    INSERT INTO transactions
      (id, amount_cents, is_income, category_id, note, date${version >= 5 ? ', is_recurring' : ''})
    VALUES
      ('legacy-transaction', 1299, 0, 'custom-books', 'Feltrinelli', 1785456000${version >= 5 ? ', 0' : ''})
  ''');
  if (version >= 5) {
    db.execute('''
      INSERT INTO recurring_transactions
        (id, amount_cents, is_income, category_id, day_of_month, start_date,
         note, active, last_generated)
      VALUES
        ('legacy-recurring', 999, 0, 'custom-books', 5, 1782864000,
         'Abbonamento libri', 1, NULL)
    ''');
  }
  db.execute('PRAGMA user_version = $version');
}
