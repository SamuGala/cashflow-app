import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/transactions/domain/category.dart' as model;
import 'categories_table.dart';
import 'recurring_transactions.dart';
part 'app_database.g.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  BoolColumn get isIncome => boolean()();
  TextColumn get categoryId => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();

  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Transactions, Categories, RecurringTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// incrementato per aggiornare le categorie
  @override
  int get schemaVersion => 5;

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
        ]);
      });
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 4) {
        await m.deleteTable('categories');
        await m.createTable(categories);

        await batch((b) {
          b.insertAll(categories, [
            CategoriesCompanion.insert(
              id: 'food',
              name: 'food',
              isIncome: false,
              icon: 0xe56c,
              color: 0xFFE53935,
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
              id: 'shopping',
              name: 'shopping',
              isIncome: false,
              icon: 0xe8cc,
              color: 0xFF8E24AA,
              isDefault: const Value(true),
            ),
            CategoriesCompanion.insert(
              id: 'entertainment',
              name: 'entertainment',
              isIncome: false,
              icon: 0xe02c,
              color: 0xFFFF9800,
              isDefault: const Value(true),
            ),
          ]);
        });
      }

      /// MIGRATION PER isRecurring
      if (from < 5) {
        await m.addColumn(transactions, transactions.isRecurring);
      }
    },
  );

  /// TRANSACTIONS
  Future<void> generateRecurringTransactions() async {
    final now = DateTime.now();

    final recurring = await (select(
      recurringTransactions,
    )..where((r) => r.active.equals(true))).get();

    for (final r in recurring) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      final day = r.dayOfMonth > daysInMonth ? daysInMonth : r.dayOfMonth;

      /// se oggi non è il giorno → skip
      if (now.day != day) continue;

      /// evita duplicati nello stesso giorno
      if (r.lastGenerated != null) {
        final last = r.lastGenerated!;

        if (last.year == now.year &&
            last.month == now.month &&
            last.day == now.day) {
          continue;
        }
      }

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amountCents: r.amountCents,
          isIncome: r.isIncome,
          categoryId: r.categoryId,
          date: now,
          note: Value(r.note),
          isRecurring: const Value(true),
        ),
      );

      await (update(recurringTransactions)..where((t) => t.id.equals(r.id)))
          .write(RecurringTransactionsCompanion(lastGenerated: Value(now)));
    }
  }

  Future<void> insertRecurringTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required int dayOfMonth,
    required DateTime startDate,
    String? note,
  }) async {
    final now = DateTime.now();

    final id = DateTime.now().millisecondsSinceEpoch.toString();

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
      ),
    );

    /// se oggi è il giorno della ricorrenza → crea subito il movimento
    if (now.day == dayOfMonth) {
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amountCents: amountCents,
          isIncome: isIncome,
          categoryId: categoryId,
          date: now,
          note: Value(note),
          isRecurring: const Value(true),
        ),
      );

      await (update(recurringTransactions)..where((t) => t.id.equals(id)))
          .write(RecurringTransactionsCompanion(lastGenerated: Value(now)));
    }
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
  }) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amountCents: Value(amountCents),
        isIncome: Value(isIncome),
        categoryId: Value(categoryId),
        date: Value(date),
        note: Value(note),
      ),
    );
  }

  Future<void> deleteTransactionById(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// CATEGORIES

  Future<List<model.Category>> getAllCategories() async {
    final rows = await select(categories).get();

    return rows
        .map(
          (row) => model.Category(
            id: row.id,
            name: row.name,
            isIncome: row.isIncome,
            icon: row.icon,
            color: row.color,
            isDefault: row.isDefault,
          ),
        )
        .toList();
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
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  /// RESET DATA

  Future<void> clearAllData() async {
    await batch((b) {
      /// elimina tutte le transazioni
      b.deleteAll(transactions);

      /// elimina tutte le ricorrenze
      b.deleteAll(recurringTransactions);

      /// elimina solo categorie custom
      b.deleteWhere(categories, (tbl) => tbl.isDefault.equals(false));
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
