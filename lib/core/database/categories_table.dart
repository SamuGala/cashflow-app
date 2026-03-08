import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  BoolColumn get isIncome => boolean()();

  IntColumn get icon => integer()();

  IntColumn get color => integer()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}