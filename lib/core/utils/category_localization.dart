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
    default:
      return Icons.category;
  }
}