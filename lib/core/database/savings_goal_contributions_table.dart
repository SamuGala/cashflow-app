import 'package:drift/drift.dart';

import 'savings_goals_table.dart';

@DataClassName('SavingsGoalContributionRow')
class SavingsGoalContributions extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(SavingsGoals, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get eurAmountMicros => integer()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
