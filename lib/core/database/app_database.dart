import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/transactions/domain/category.dart' as model;
import 'categories_table.dart';

part 'app_database.g.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  BoolColumn get isIncome => boolean()();
  TextColumn get categoryId => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          await batch((b) {
            b.insertAll(categories, [
              CategoriesCompanion.insert(
                id: 'salary',
                name: 'Stipendio',
                isIncome: true,
                icon: 0xe227,
                color: 0xFF4CAF50,
                isDefault: const Value(true),
              ),
              CategoriesCompanion.insert(
                id: 'expense',
                name: 'Spesa',
                isIncome: false,
                icon: 0xe8cc,
                color: 0xFFF44336,
                isDefault: const Value(true),
              ),
            ]);
          });
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(categories);
          }
        },
      );

  /// TRANSACTIONS

  Future<List<Transaction>> getAllTransactions() {
    return select(transactions).get();
  }

  Future<void> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
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
        icon: category.icon,
        color: category.color,
        isDefault: Value(category.isDefault),
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  /// CLEAR ALL DATA (usato nei settings)

  Future<void> clearAllData() async {
    await batch((b) {
      b.deleteAll(transactions);
      b.deleteAll(categories);
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