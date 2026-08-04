import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/utils/category_localization.dart';

void main() {
  test('custom category icons resolve current persisted code points', () {
    expect(customCategoryIcon(Icons.movie.codePoint), Icons.movie);
    expect(
      customCategoryIcon(Icons.shopping_cart.codePoint),
      Icons.shopping_cart,
    );
  });

  test('custom category icons preserve legacy code points', () {
    expect(customCategoryIcon(0xe02c), Icons.movie);
    expect(customCategoryIcon(0xe8cc), Icons.shopping_cart);
  });

  test('unknown category icons use a stable fallback', () {
    expect(customCategoryIcon(-1), Icons.category);
  });
}
