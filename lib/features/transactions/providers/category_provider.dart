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
    return db.getAllCategories();
  }

  /// CHECK DUPLICATE CATEGORY NAME
  bool _exists(String name, {String? ignoreId}) {
    final normalized = name.trim().toLowerCase();

    final categories = state.value ?? [];

    return categories.any((c) {
      if (ignoreId != null && c.id == ignoreId) return false;

      return c.name.trim().toLowerCase() == normalized;
    });
  }

  /// CREATE CATEGORY
  Future<Category?> addCategory({
    required String name,
    required bool isIncome,
    required int icon,
    required int color,
  }) async {
    if (_exists(name)) {
      return null;
    }

    final category = Category(
      id: _uuid.v4(),
      name: name.trim(),
      isIncome: isIncome,
      icon: icon,
      color: color,
      isDefault: false,
    );

    await db.insertCategory(category);

    state = AsyncData(await db.getAllCategories());

    return category;
  }

  /// UPDATE CATEGORY
  Future<bool> updateCategory(Category category) async {
    if (_exists(category.name, ignoreId: category.id)) {
      return false;
    }

    await db.insertCategory(category);

    state = AsyncData(await db.getAllCategories());

    return true;
  }

  /// DELETE CATEGORY
  Future<void> deleteCategory(String id) async {
    await db.deleteCategory(id);

    state = AsyncData(await db.getAllCategories());
  }

  /// FILTER BY TYPE
  List<Category> byType(bool isIncome) {
    final categories = state.value ?? [];

    return categories.where((c) => c.isIncome == isIncome).toList();
  }
}