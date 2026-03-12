import 'package:drift/drift.dart';

class RecurringTransactions extends Table {
  TextColumn get id => text()();

  IntColumn get amountCents => integer()();

  BoolColumn get isIncome => boolean()();

  TextColumn get categoryId => text()();

  IntColumn get dayOfMonth => integer()();

  DateTimeColumn get startDate => dateTime()();

  TextColumn get note => text().nullable()();

  /// NUOVO
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get lastGenerated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
