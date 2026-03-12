import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category.dart';

class LastCategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() {
    return null;
  }

  void set(Category category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

final lastCategoryProvider =
    NotifierProvider<LastCategoryNotifier, Category?>(LastCategoryNotifier.new);