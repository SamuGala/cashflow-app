import 'package:drift/drift.dart';

@DataClassName('CategorizationRuleRow')
class CategorizationRules extends Table {
  TextColumn get id => text()();
  TextColumn get pattern => text()();
  TextColumn get matchType => text().withDefault(const Constant('contains'))();
  TextColumn get categoryId => text()();
  BoolColumn get isIncome => boolean().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
