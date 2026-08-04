import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

String categoryName(String key, AppLocalizations t) {
  switch (key) {
    case 'salary':
      return t.salary;
    case 'bonus':
      return t.bonus;
    case 'gift':
      return t.gift;
    case 'food':
      return t.food;
    case 'groceries':
      return t.groceries;
    case 'transport':
      return t.transport;
    case 'rent':
      return t.rent;
    case 'bills':
      return t.bills;
    case 'shopping':
      return t.shopping;
    case 'health':
      return t.health;
    case 'entertainment':
      return t.entertainment;
    case 'travel':
      return t.travel;
    case 'education':
      return t.education;
    case 'other':
      return t.otherCategory;
    default:
      return key;
  }
}

IconData categoryIcon(String key) {
  switch (key) {
    case 'salary':
      return Icons.attach_money;
    case 'bonus':
      return Icons.card_giftcard;
    case 'gift':
      return Icons.card_giftcard;
    case 'food':
      return Icons.fastfood;
    case 'groceries':
      return Icons.shopping_cart;
    case 'transport':
      return Icons.directions_car;
    case 'rent':
      return Icons.home;
    case 'bills':
      return Icons.receipt_long;
    case 'shopping':
      return Icons.shopping_bag;
    case 'health':
      return Icons.favorite;
    case 'entertainment':
      return Icons.movie;
    case 'travel':
      return Icons.flight;
    case 'education':
      return Icons.school;
    case 'other':
      return Icons.more_horiz;
    default:
      return Icons.category;
  }
}

/// Resolves persisted custom-category icon code points without constructing
/// [IconData] dynamically. This keeps release icon tree-shaking safe while
/// preserving icons written by both current and legacy app versions.
IconData customCategoryIcon(int codePoint) {
  for (final icon in _supportedCustomCategoryIcons) {
    if (icon.codePoint == codePoint) return icon;
  }

  return switch (codePoint) {
    // Legacy Material Icons code points used by earlier releases.
    0xe8cc => Icons.shopping_cart,
    0xe88a => Icons.home,
    0xe57a => Icons.fastfood,
    0xe531 => Icons.directions_car,
    0xe02c => Icons.movie,
    0xea28 => Icons.sports_esports,
    0xe56c => Icons.restaurant,
    0xe539 => Icons.flight,
    0xe80c => Icons.school,
    0xe87d => Icons.favorite,
    0xe227 => Icons.attach_money,
    0xe548 => Icons.local_hospital,
    0xe91d => Icons.pets,
    0xe8f6 => Icons.card_giftcard,
    0xe8f9 => Icons.work,
    _ => Icons.category,
  };
}

const _supportedCustomCategoryIcons = <IconData>[
  Icons.shopping_cart,
  Icons.home,
  Icons.fastfood,
  Icons.directions_car,
  Icons.movie,
  Icons.sports_esports,
  Icons.restaurant,
  Icons.flight,
  Icons.school,
  Icons.favorite,
  Icons.attach_money,
  Icons.local_hospital,
  Icons.pets,
  Icons.card_giftcard,
  Icons.work,
];
