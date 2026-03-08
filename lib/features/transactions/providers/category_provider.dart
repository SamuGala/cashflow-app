import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart' as database;
import '../../../core/providers/database_provider.dart';

import '../domain/category.dart';

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
  CategoryNotifier.new,
);

class CategoryNotifier extends AsyncNotifier<List<Category>> {

  final _uuid = const Uuid();

  database.AppDatabase get db => ref.read(databaseProvider);

  @override
  Future<List<Category>> build() async {

    final categories = await db.getAllCategories();

    return categories;
  }

  Future<Category> addCategory({
    required String name,
    required bool isIncome,
    required int icon,
    required int color,
  }) async {

    final category = Category(
      id: _uuid.v4(),
      name: name,
      isIncome: isIncome,
      icon: icon,
      color: color,
      isDefault: false,
    );

    await db.insertCategory(category);

    final updated = await db.getAllCategories();

    state = AsyncData(updated);

    return category;
  }

  Future<void> deleteCategory(String id) async {

    await db.deleteCategory(id);

    final updated = await db.getAllCategories();

    state = AsyncData(updated);
  }

  List<Category> byType(bool isIncome) {

    final categories = state.value ?? [];

    return categories
        .where((c) => c.isIncome == isIncome)
        .toList();
  }
}