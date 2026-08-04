import 'package:drift/drift.dart';

@DataClassName('SavingsGoalRow')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmountMinor => integer()();
  IntColumn get savedAmountMinor => integer().withDefault(const Constant(0))();
  IntColumn get targetEurMicros => integer()();
  IntColumn get savedEurMicros => integer().withDefault(const Constant(0))();
  TextColumn get currencyCode => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get icon => integer()();
  IntColumn get color => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
