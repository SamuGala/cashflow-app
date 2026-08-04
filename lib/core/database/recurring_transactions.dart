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

  IntColumn get originalAmountMinor => integer().nullable()();

  TextColumn get originalCurrency => text().nullable()();

  IntColumn get eurAmountMicros => integer().nullable()();

  RealColumn get exchangeRateToEur => real().nullable()();

  TextColumn get frequency => text().withDefault(const Constant('monthly'))();

  IntColumn get interval => integer().withDefault(const Constant(1))();

  IntColumn get dayOfWeek => integer().nullable()();

  IntColumn get monthOfYear => integer().nullable()();

  DateTimeColumn get endDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
