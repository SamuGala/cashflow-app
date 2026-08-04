import 'package:drift/drift.dart';

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  IntColumn get amountMinor => integer()();
  IntColumn get eurAmountMicros => integer()();
  TextColumn get periodType => text().withDefault(const Constant('monthly'))();
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId},
  ];
}
