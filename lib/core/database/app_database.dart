import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/transactions/domain/category.dart' as model;
import '../../features/transactions/domain/recurrence_calculator.dart';
import 'categories_table.dart';
import 'recurring_transactions.dart';
import 'budgets_table.dart';
import 'categorization_rules_table.dart';
import 'savings_goals_table.dart';
import 'savings_goal_contributions_table.dart';
part 'app_database.g.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  BoolColumn get isIncome => boolean()();
  TextColumn get categoryId => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();

  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  IntColumn get originalAmountMinor => integer().nullable()();
  TextColumn get originalCurrency => text().nullable()();
  IntColumn get eurAmountMicros => integer().nullable()();
  RealColumn get exchangeRateToEur => real().nullable()();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get recurringSourceId => text().nullable()();
  TextColumn get recurringOccurrenceKey => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {recurringOccurrenceKey},
  ];
}

@DriftDatabase(
  tables: [
    Transactions,
    Categories,
    RecurringTransactions,
    Budgets,
    CategorizationRules,
    SavingsGoals,
    SavingsGoalContributions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  Future<int>? _recurringGeneration;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      await batch((b) {
        b.insertAll(categories, [
          /// INCOME
          CategoriesCompanion.insert(
            id: 'salary',
            name: 'salary',
            isIncome: true,
            icon: 0xe0b2,
            color: 0xFF2ECC71,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'bonus',
            name: 'bonus',
            isIncome: true,
            icon: 0xe8dc,
            color: 0xFF66BB6A,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'gift',
            name: 'gift',
            isIncome: true,
            icon: 0xe8f6,
            color: 0xFFAB47BC,
            isDefault: const Value(true),
          ),

          /// EXPENSES
          CategoriesCompanion.insert(
            id: 'food',
            name: 'food',
            isIncome: false,
            icon: 0xe56c,
            color: 0xFFE53935,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'groceries',
            name: 'groceries',
            isIncome: false,
            icon: 0xe8cc,
            color: 0xFFFF7043,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'transport',
            name: 'transport',
            isIncome: false,
            icon: 0xe530,
            color: 0xFF3949AB,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'rent',
            name: 'rent',
            isIncome: false,
            icon: 0xe88a,
            color: 0xFF5C6BC0,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'bills',
            name: 'bills',
            isIncome: false,
            icon: 0xe8b0,
            color: 0xFF8D6E63,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'shopping',
            name: 'shopping',
            isIncome: false,
            icon: 0xe8cc,
            color: 0xFF8E24AA,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'health',
            name: 'health',
            isIncome: false,
            icon: 0xe548,
            color: 0xFFD32F2F,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'entertainment',
            name: 'entertainment',
            isIncome: false,
            icon: 0xe02c,
            color: 0xFFFFB300,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'travel',
            name: 'travel',
            isIncome: false,
            icon: 0xe539,
            color: 0xFF29B6F6,
            isDefault: const Value(true),
          ),

          CategoriesCompanion.insert(
            id: 'education',
            name: 'education',
            isIncome: false,
            icon: 0xe80c,
            color: 0xFF26A69A,
            isDefault: const Value(true),
          ),
          CategoriesCompanion.insert(
            id: 'other',
            name: 'other',
            isIncome: false,
            icon: 0xe5d3,
            color: 0xFF64748B,
            isDefault: const Value(true),
          ),
        ]);
      });
    },

    onUpgrade: (Migrator m, int from, int to) =>
        _upgradeLegacySchema(m, from: from),
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Repairs and upgrades every schema shipped before 2.0 without deleting
  /// user data. Checks use the actual SQLite schema instead of assuming that
  /// every user installed each intermediate app release.
  Future<void> _upgradeLegacySchema(Migrator m, {required int from}) async {
    if (!await _tableExists('transactions')) {
      await m.createTable(transactions);
    }
    if (!await _tableExists('categories')) {
      await m.createTable(categories);
    }
    if (!await _tableExists('recurring_transactions')) {
      await m.createTable(recurringTransactions);
    }

    final transactionColumns = await _columnNames('transactions');
    if (!transactionColumns.contains('is_recurring')) {
      await m.addColumn(transactions, transactions.isRecurring);
    }
    if (!transactionColumns.contains('original_amount_minor')) {
      await m.addColumn(transactions, transactions.originalAmountMinor);
    }
    if (!transactionColumns.contains('original_currency')) {
      await m.addColumn(transactions, transactions.originalCurrency);
    }
    if (!transactionColumns.contains('eur_amount_micros')) {
      await m.addColumn(transactions, transactions.eurAmountMicros);
    }
    if (!transactionColumns.contains('exchange_rate_to_eur')) {
      await m.addColumn(transactions, transactions.exchangeRateToEur);
    }
    if (!transactionColumns.contains('receipt_path')) {
      await m.addColumn(transactions, transactions.receiptPath);
    }
    if (!transactionColumns.contains('created_at')) {
      await m.addColumn(transactions, transactions.createdAt);
    }
    if (!transactionColumns.contains('recurring_source_id')) {
      await m.addColumn(transactions, transactions.recurringSourceId);
    }
    if (!transactionColumns.contains('recurring_occurrence_key')) {
      await m.addColumn(transactions, transactions.recurringOccurrenceKey);
    }

    final categoryColumns = await _columnNames('categories');
    if (!categoryColumns.contains('last_used_at')) {
      await m.addColumn(categories, categories.lastUsedAt);
    }

    final recurringColumns = await _columnNames('recurring_transactions');
    if (!recurringColumns.contains('original_amount_minor')) {
      await m.addColumn(
        recurringTransactions,
        recurringTransactions.originalAmountMinor,
      );
    }
    if (!recurringColumns.contains('original_currency')) {
      await m.addColumn(
        recurringTransactions,
        recurringTransactions.originalCurrency,
      );
    }
    if (!recurringColumns.contains('eur_amount_micros')) {
      await m.addColumn(
        recurringTransactions,
        recurringTransactions.eurAmountMicros,
      );
    }
    if (!recurringColumns.contains('exchange_rate_to_eur')) {
      await m.addColumn(
        recurringTransactions,
        recurringTransactions.exchangeRateToEur,
      );
    }
    if (!recurringColumns.contains('frequency')) {
      await m.addColumn(recurringTransactions, recurringTransactions.frequency);
    }
    if (!recurringColumns.contains('interval')) {
      await m.addColumn(recurringTransactions, recurringTransactions.interval);
    }
    if (!recurringColumns.contains('day_of_week')) {
      await m.addColumn(recurringTransactions, recurringTransactions.dayOfWeek);
    }
    if (!recurringColumns.contains('month_of_year')) {
      await m.addColumn(
        recurringTransactions,
        recurringTransactions.monthOfYear,
      );
    }
    if (!recurringColumns.contains('end_date')) {
      await m.addColumn(recurringTransactions, recurringTransactions.endDate);
    }

    if (!await _tableExists('budgets')) await m.createTable(budgets);
    if (!await _tableExists('categorization_rules')) {
      await m.createTable(categorizationRules);
    }
    if (!await _tableExists('savings_goals')) {
      await m.createTable(savingsGoals);
    } else {
      final goalColumns = await _columnNames('savings_goals');
      if (!goalColumns.contains('archived')) {
        await m.addColumn(savingsGoals, savingsGoals.archived);
      }
    }

    final contributionsCreated = !await _tableExists(
      'savings_goal_contributions',
    );
    if (contributionsCreated) {
      await m.createTable(savingsGoalContributions);
      await customStatement('''
        INSERT OR IGNORE INTO savings_goal_contributions (
          id, goal_id, amount_minor, eur_amount_micros, currency_code, created_at
        )
        SELECT
          'legacy:' || id,
          id,
          saved_amount_minor,
          saved_eur_micros,
          currency_code,
          updated_at
        FROM savings_goals
        WHERE saved_amount_minor <> 0
      ''');
    }

    await customStatement('''
      UPDATE transactions
      SET original_amount_minor = amount_cents,
          original_currency = 'EUR',
          eur_amount_micros = amount_cents * 10000,
          exchange_rate_to_eur = 1.0,
          created_at = date
      WHERE original_amount_minor IS NULL
    ''');
    await customStatement('''
      UPDATE recurring_transactions
      SET original_amount_minor = amount_cents,
          original_currency = 'EUR',
          eur_amount_micros = amount_cents * 10000,
          exchange_rate_to_eur = 1.0
      WHERE original_amount_minor IS NULL
    ''');

    await _restoreDefaultAndReferencedCategories();
    await customStatement('''
      UPDATE categories
      SET last_used_at = (
        SELECT MAX(date)
        FROM transactions
        WHERE transactions.category_id = categories.id
      )
      WHERE EXISTS (
        SELECT 1
        FROM transactions
        WHERE transactions.category_id = categories.id
      )
    ''');
    await customStatement('''
      UPDATE transactions
      SET recurring_occurrence_key = NULL
      WHERE recurring_occurrence_key IS NOT NULL
        AND rowid NOT IN (
          SELECT MIN(rowid)
          FROM transactions
          WHERE recurring_occurrence_key IS NOT NULL
          GROUP BY recurring_occurrence_key
        )
    ''');
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS transactions_occurrence_unique
      ON transactions (recurring_occurrence_key)
      WHERE recurring_occurrence_key IS NOT NULL
    ''');
  }

  Future<bool> _tableExists(String name) async {
    final row = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [Variable<String>('table'), Variable<String>(name)],
    ).getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> _columnNames(String table) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> _restoreDefaultAndReferencedCategories() async {
    await customStatement('''
      INSERT OR IGNORE INTO categories
        (id, name, is_income, icon, color, is_default, last_used_at)
      VALUES
        ('salary', 'salary', 1, 57522, 4281257073, 1, NULL),
        ('bonus', 'bonus', 1, 59612, 4284922730, 1, NULL),
        ('gift', 'gift', 1, 59638, 4289415100, 1, NULL),
        ('food', 'food', 0, 58732, 4293212469, 1, NULL),
        ('groceries', 'groceries', 0, 59596, 4294930499, 1, NULL),
        ('transport', 'transport', 0, 58672, 4281948587, 1, NULL),
        ('rent', 'rent', 0, 59530, 4284261552, 1, NULL),
        ('bills', 'bills', 0, 59568, 4287460963, 1, NULL),
        ('shopping', 'shopping', 0, 59596, 4287505578, 1, NULL),
        ('health', 'health', 0, 58696, 4292026671, 1, NULL),
        ('entertainment', 'entertainment', 0, 57388, 4294947584, 1, NULL),
        ('travel', 'travel', 0, 58681, 4280927990, 1, NULL),
        ('education', 'education', 0, 59404, 4280722074, 1, NULL),
        ('other', 'other', 0, 58835, 4284773515, 1, NULL)
    ''');
    await customStatement('''
      INSERT OR IGNORE INTO categories
        (id, name, is_income, icon, color, is_default, last_used_at)
      SELECT
        category_id,
        category_id,
        MAX(is_income),
        58835,
        4286611584,
        0,
        MAX(date)
      FROM transactions
      GROUP BY category_id
    ''');
    await customStatement('''
      INSERT OR IGNORE INTO categories
        (id, name, is_income, icon, color, is_default, last_used_at)
      SELECT
        category_id,
        category_id,
        MAX(is_income),
        58835,
        4286611584,
        0,
        NULL
      FROM recurring_transactions
      GROUP BY category_id
    ''');
  }

  /// TRANSACTIONS
  Future<int> generateRecurringTransactions({DateTime? asOf}) async {
    final running = _recurringGeneration;
    if (running != null) return running;

    final operation = _generateRecurringTransactions(asOf ?? DateTime.now());
    _recurringGeneration = operation;

    try {
      return await operation;
    } finally {
      if (identical(_recurringGeneration, operation)) {
        _recurringGeneration = null;
      }
    }
  }

  /// Versions up to 2.0.0 stepped daily and weekly schedules by 24 hours, so
  /// after a daylight-saving fall-back the occurrences were stored at 23:00 of
  /// the previous day. Moves them, and the generation cursor, to the intended
  /// day. Only exact 23:00 timestamps from those schedules are touched, which
  /// makes the repair idempotent.
  Future<void> _repairDstShiftedOccurrences() async {
    bool shifted(DateTime value) =>
        value.hour == 23 &&
        value.minute == 0 &&
        value.second == 0 &&
        value.millisecond == 0;
    DateTime nextDay(DateTime value) =>
        DateTime(value.year, value.month, value.day + 1);

    final schedules = await (select(
      recurringTransactions,
    )..where((r) => r.frequency.isIn(const ['daily', 'weekly']))).get();
    for (final schedule in schedules) {
      final cursor = schedule.lastGenerated;
      if (cursor != null && shifted(cursor)) {
        await (update(
          recurringTransactions,
        )..where((r) => r.id.equals(schedule.id))).write(
          RecurringTransactionsCompanion(lastGenerated: Value(nextDay(cursor))),
        );
      }
      final generated = await (select(
        transactions,
      )..where((t) => t.recurringSourceId.equals(schedule.id))).get();
      final keys = generated.map((t) => t.recurringOccurrenceKey).toSet();
      for (final row in generated.where((t) => shifted(t.date))) {
        final date = nextDay(row.date);
        final key = '${schedule.id}:${date.toIso8601String()}';
        if (keys.contains(key)) {
          await (delete(transactions)..where((t) => t.id.equals(row.id))).go();
          continue;
        }
        await (update(transactions)..where((t) => t.id.equals(row.id))).write(
          TransactionsCompanion(
            date: Value(date),
            createdAt: Value(date),
            recurringOccurrenceKey: Value(key),
          ),
        );
        keys.add(key);
      }
    }
  }

  Future<int> _generateRecurringTransactions(DateTime now) {
    return transaction(() async {
      await _repairDstShiftedOccurrences();
      var generatedCount = 0;
      final recurring = await (select(
        recurringTransactions,
      )..where((r) => r.active.equals(true))).get();

      for (final recurringTransaction in recurring) {
        final schedule = RecurrenceSchedule(
          startDate: recurringTransaction.startDate,
          frequency: recurrenceFrequencyFromName(
            recurringTransaction.frequency,
          ),
          interval: recurringTransaction.interval,
          dayOfMonth: recurringTransaction.dayOfMonth,
          dayOfWeek: recurringTransaction.dayOfWeek,
          monthOfYear: recurringTransaction.monthOfYear,
          endDate: recurringTransaction.endDate,
        );
        final occurrences = recurringOccurrences(
          schedule: schedule,
          after: recurringTransaction.lastGenerated,
          through: now,
        );
        var lastGenerated = recurringTransaction.lastGenerated;

        for (final scheduledDate in occurrences) {
          final occurrenceKey =
              '${recurringTransaction.id}:${scheduledDate.toIso8601String()}';
          final rowId = await into(transactions).insert(
            TransactionsCompanion.insert(
              id: occurrenceKey,
              amountCents: recurringTransaction.amountCents,
              isIncome: recurringTransaction.isIncome,
              categoryId: recurringTransaction.categoryId,
              date: scheduledDate,
              note: Value(recurringTransaction.note),
              isRecurring: const Value(true),
              originalAmountMinor: Value(
                recurringTransaction.originalAmountMinor ??
                    recurringTransaction.amountCents,
              ),
              originalCurrency: Value(
                recurringTransaction.originalCurrency ?? 'EUR',
              ),
              eurAmountMicros: Value(
                recurringTransaction.eurAmountMicros ??
                    recurringTransaction.amountCents * 10000,
              ),
              exchangeRateToEur: Value(
                recurringTransaction.exchangeRateToEur ?? 1,
              ),
              createdAt: Value(scheduledDate),
              recurringSourceId: Value(recurringTransaction.id),
              recurringOccurrenceKey: Value(occurrenceKey),
            ),
            mode: InsertMode.insertOrIgnore,
          );
          if (rowId != 0) {
            generatedCount++;
          }
          lastGenerated = scheduledDate;
        }

        if (lastGenerated != recurringTransaction.lastGenerated) {
          await (update(
            recurringTransactions,
          )..where((t) => t.id.equals(recurringTransaction.id))).write(
            RecurringTransactionsCompanion(lastGenerated: Value(lastGenerated)),
          );
        }
      }

      return generatedCount;
    });
  }

  Future<void> insertRecurringTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required int dayOfMonth,
    required DateTime startDate,
    String? note,
    int? originalAmountMinor,
    String originalCurrency = 'EUR',
    int? eurAmountMicros,
    double exchangeRateToEur = 1,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    int interval = 1,
    int? dayOfWeek,
    int? monthOfYear,
    DateTime? endDate,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    await into(recurringTransactions).insert(
      RecurringTransactionsCompanion.insert(
        id: id,
        amountCents: amountCents,
        isIncome: isIncome,
        categoryId: categoryId,
        dayOfMonth: dayOfMonth,
        startDate: startDate,
        note: Value(note),
        active: const Value(true),
        originalAmountMinor: Value(originalAmountMinor ?? amountCents),
        originalCurrency: Value(originalCurrency),
        eurAmountMicros: Value(eurAmountMicros ?? amountCents * 10000),
        exchangeRateToEur: Value(exchangeRateToEur),
        frequency: Value(frequency.name),
        interval: Value(interval),
        dayOfWeek: Value(dayOfWeek),
        monthOfYear: Value(monthOfYear),
        endDate: Value(endDate),
      ),
    );

    await generateRecurringTransactions();
  }

  Future<List<Transaction>> getAllTransactions() {
    return select(transactions).get();
  }

  Future<void> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<void> updateTransaction({
    required String id,
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required DateTime date,
    String? note,
    int? originalAmountMinor,
    String? originalCurrency,
    int? eurAmountMicros,
    double? exchangeRateToEur,
    String? receiptPath,
  }) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amountCents: Value(amountCents),
        isIncome: Value(isIncome),
        categoryId: Value(categoryId),
        date: Value(date),
        note: Value(note),
        originalAmountMinor: Value(originalAmountMinor),
        originalCurrency: Value(originalCurrency),
        eurAmountMicros: Value(eurAmountMicros),
        exchangeRateToEur: Value(exchangeRateToEur),
        receiptPath: Value(receiptPath),
      ),
    );
  }

  Future<void> deleteTransactionById(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// CATEGORIES

  Future<List<model.Category>> getAllCategories() async {
    final rows = await select(categories).get();

    final result = rows
        .map(
          (row) => model.Category(
            id: row.id,
            name: row.name,
            isIncome: row.isIncome,
            icon: row.icon,
            color: row.color,
            isDefault: row.isDefault,
            lastUsedAt: row.lastUsedAt,
          ),
        )
        .toList();

    result.sort((a, b) {
      if (a.lastUsedAt == null && b.lastUsedAt == null) {
        return a.name.compareTo(b.name);
      }
      if (a.lastUsedAt == null) return 1;
      if (b.lastUsedAt == null) return -1;

      final recentFirst = b.lastUsedAt!.compareTo(a.lastUsedAt!);
      return recentFirst != 0 ? recentFirst : a.name.compareTo(b.name);
    });

    return result;
  }

  Future<void> insertCategory(model.Category category) async {
    await into(categories).insertOnConflictUpdate(
      CategoriesCompanion.insert(
        id: category.id,
        name: category.name,
        isIncome: category.isIncome,
        icon: category.icon, // FIX
        color: category.color,
        isDefault: Value(category.isDefault),
        lastUsedAt: Value(category.lastUsedAt),
      ),
    );
  }

  Future<void> markCategoryUsed(String id, {DateTime? usedAt}) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(lastUsedAt: Value(usedAt ?? DateTime.now())),
    );
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  Future<bool> deleteCategoryIfUnused(String id) {
    return transaction(() async {
      if (await isCategoryInUse(id)) return false;
      // Smart rules are no longer part of the product. Clean up any legacy
      // imported rule transparently so an invisible record cannot make a
      // category impossible to delete.
      await (delete(
        categorizationRules,
      )..where((row) => row.categoryId.equals(id))).go();
      return await (delete(categories)..where((c) => c.id.equals(id))).go() > 0;
    });
  }

  Future<bool> isCategoryInUse(String id) async {
    final transaction =
        await (select(transactions)
              ..where((row) => row.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (transaction != null) return true;

    final recurring =
        await (select(recurringTransactions)
              ..where((row) => row.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (recurring != null) return true;

    final budget =
        await (select(budgets)
              ..where((row) => row.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (budget != null) return true;

    return false;
  }

  Future<void> revalueAmounts({
    required String currencyCode,
    required int Function(int eurAmountMicros) fromEurMicros,
  }) async {
    await transaction(() async {
      final transactionRows = await select(transactions).get();
      for (final row in transactionRows) {
        final eurMicros = row.eurAmountMicros ?? row.amountCents * 10000;
        await (update(
          transactions,
        )..where((table) => table.id.equals(row.id))).write(
          TransactionsCompanion(
            amountCents: Value(fromEurMicros(eurMicros)),
            eurAmountMicros: Value(eurMicros),
          ),
        );
      }

      final recurringRows = await select(recurringTransactions).get();
      for (final row in recurringRows) {
        final eurMicros = row.eurAmountMicros ?? row.amountCents * 10000;
        await (update(
          recurringTransactions,
        )..where((table) => table.id.equals(row.id))).write(
          RecurringTransactionsCompanion(
            amountCents: Value(fromEurMicros(eurMicros)),
            eurAmountMicros: Value(eurMicros),
          ),
        );
      }

      final budgetRows = await select(budgets).get();
      for (final row in budgetRows) {
        await (update(
          budgets,
        )..where((table) => table.id.equals(row.id))).write(
          BudgetsCompanion(
            amountMinor: Value(fromEurMicros(row.eurAmountMicros)),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      final goalRows = await select(savingsGoals).get();
      for (final row in goalRows) {
        await (update(
          savingsGoals,
        )..where((table) => table.id.equals(row.id))).write(
          SavingsGoalsCompanion(
            targetAmountMinor: Value(fromEurMicros(row.targetEurMicros)),
            savedAmountMinor: Value(fromEurMicros(row.savedEurMicros)),
            currencyCode: Value(currencyCode),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      final contributionRows = await select(savingsGoalContributions).get();
      for (final row in contributionRows) {
        await (update(
          savingsGoalContributions,
        )..where((table) => table.id.equals(row.id))).write(
          SavingsGoalContributionsCompanion(
            amountMinor: Value(fromEurMicros(row.eurAmountMicros)),
            currencyCode: Value(currencyCode),
          ),
        );
      }
    });
  }

  /// RESET DATA

  Future<void> clearAllData() async {
    await batch((b) {
      b.deleteAll(transactions);
      b.deleteAll(recurringTransactions);
      b.deleteAll(budgets);
      b.deleteAll(categorizationRules);
      b.deleteAll(savingsGoalContributions);
      b.deleteAll(savingsGoals);
      b.deleteWhere(categories, (tbl) => tbl.isDefault.equals(false));
    });

    await update(
      categories,
    ).write(const CategoriesCompanion(lastUsedAt: Value(null)));
  }

  Future<Map<String, Object?>> exportSnapshot() async {
    return {
      'schemaVersion': schemaVersion,
      'transactions': (await select(
        transactions,
      ).get()).map((row) => row.toJson()).toList(),
      'categories': (await select(
        categories,
      ).get()).map((row) => row.toJson()).toList(),
      'recurringTransactions': (await select(
        recurringTransactions,
      ).get()).map((row) => row.toJson()).toList(),
      'budgets': (await select(
        budgets,
      ).get()).map((row) => row.toJson()).toList(),
      'categorizationRules': (await select(
        categorizationRules,
      ).get()).map((row) => row.toJson()).toList(),
      'savingsGoals': (await select(
        savingsGoals,
      ).get()).map((row) => row.toJson()).toList(),
      'savingsGoalContributions': (await select(
        savingsGoalContributions,
      ).get()).map((row) => row.toJson()).toList(),
    };
  }

  Future<void> importSnapshot(
    Map<String, dynamic> snapshot, {
    required bool replaceExisting,
  }) async {
    final importedSchema = snapshot['schemaVersion'];
    if (importedSchema is int && importedSchema > schemaVersion) {
      throw FormatException(
        'This backup was created by a newer app version (schema $importedSchema).',
      );
    }

    List<Map<String, dynamic>> rows(String key) {
      final value = snapshot[key];
      if (value == null) return const [];
      if (value is! List) throw FormatException('$key is not a list.');
      return value.map((row) => Map<String, dynamic>.from(row as Map)).toList();
    }

    final categoryRows = rows('categories').map(CategoryRow.fromJson).toList();
    final transactionRows = rows('transactions').map((json) {
      json.putIfAbsent('isRecurring', () => false);
      return Transaction.fromJson(json);
    }).toList();
    final recurringRows = rows('recurringTransactions').map((json) {
      json.putIfAbsent('active', () => true);
      json.putIfAbsent('frequency', () => 'monthly');
      json.putIfAbsent('interval', () => 1);
      return RecurringTransaction.fromJson(json);
    }).toList();
    final budgetRows = rows('budgets').map(BudgetRow.fromJson).toList();
    final ruleRows = rows(
      'categorizationRules',
    ).map(CategorizationRuleRow.fromJson).toList();
    final goalRows = rows('savingsGoals').map((json) {
      json.putIfAbsent('archived', () => false);
      return SavingsGoalRow.fromJson(json);
    }).toList();
    final contributionRows = snapshot.containsKey('savingsGoalContributions')
        ? rows(
            'savingsGoalContributions',
          ).map(SavingsGoalContributionRow.fromJson).toList()
        : goalRows
              .where((row) => row.savedAmountMinor != 0)
              .map(
                (row) => SavingsGoalContributionRow(
                  id: 'legacy:${row.id}',
                  goalId: row.id,
                  amountMinor: row.savedAmountMinor,
                  eurAmountMicros: row.savedEurMicros,
                  currencyCode: row.currencyCode,
                  createdAt: row.updatedAt,
                ),
              )
              .toList();

    final availableCategoryIds = categoryRows.map((row) => row.id).toSet();
    if (!replaceExisting) {
      availableCategoryIds.addAll(
        (await select(categories).get()).map((row) => row.id),
      );
    }
    final missingCategories = <String>{
      ...transactionRows
          .map((row) => row.categoryId)
          .where((id) => !availableCategoryIds.contains(id)),
      ...recurringRows
          .map((row) => row.categoryId)
          .where((id) => !availableCategoryIds.contains(id)),
      ...budgetRows
          .map((row) => row.categoryId)
          .where((id) => !availableCategoryIds.contains(id)),
      ...ruleRows
          .map((row) => row.categoryId)
          .where((id) => !availableCategoryIds.contains(id)),
    };
    if (missingCategories.isNotEmpty) {
      throw FormatException(
        'Backup contains missing category references: '
        '${missingCategories.join(', ')}.',
      );
    }

    final availableGoalIds = goalRows.map((row) => row.id).toSet();
    if (!replaceExisting) {
      availableGoalIds.addAll(
        (await select(savingsGoals).get()).map((row) => row.id),
      );
    }
    final missingGoals = contributionRows
        .map((row) => row.goalId)
        .where((id) => !availableGoalIds.contains(id))
        .toSet();
    if (missingGoals.isNotEmpty) {
      throw FormatException(
        'Backup contains missing savings goal references: '
        '${missingGoals.join(', ')}.',
      );
    }

    await transaction(() async {
      if (replaceExisting) {
        await delete(transactions).go();
        await delete(recurringTransactions).go();
        await delete(budgets).go();
        await delete(categorizationRules).go();
        await delete(savingsGoalContributions).go();
        await delete(savingsGoals).go();
        await delete(categories).go();
      }

      for (final row in categoryRows) {
        await (delete(
          categories,
        )..where((table) => table.id.equals(row.id))).go();
        await into(categories).insert(row);
      }
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: 'other',
          name: 'other',
          isIncome: false,
          icon: 0xe5d3,
          color: 0xFF64748B,
          isDefault: const Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      for (final row in transactionRows) {
        await (delete(
          transactions,
        )..where((table) => table.id.equals(row.id))).go();
        await into(transactions).insert(row);
      }
      for (final row in recurringRows) {
        await (delete(
          recurringTransactions,
        )..where((table) => table.id.equals(row.id))).go();
        await into(recurringTransactions).insert(row);
      }
      for (final row in budgetRows) {
        await (delete(budgets)..where((table) => table.id.equals(row.id))).go();
        await into(budgets).insert(row);
      }
      for (final row in ruleRows) {
        await (delete(
          categorizationRules,
        )..where((table) => table.id.equals(row.id))).go();
        await into(categorizationRules).insert(row);
      }
      for (final row in goalRows) {
        await (delete(
          savingsGoalContributions,
        )..where((table) => table.goalId.equals(row.id))).go();
        await (delete(
          savingsGoals,
        )..where((table) => table.id.equals(row.id))).go();
        await into(savingsGoals).insert(row);
      }
      for (final row in contributionRows) {
        await (delete(
          savingsGoalContributions,
        )..where((table) => table.id.equals(row.id))).go();
        await into(savingsGoalContributions).insert(row);
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cashflow.sqlite'));

    return NativeDatabase(
      file,
      setup: (db) {
        db.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}
