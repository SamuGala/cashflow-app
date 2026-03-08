import 'package:flutter/material.dart';
import '../domain/category.dart';

final mockCategories = [
  Category(
    id: 'salary',
    name: 'Stipendio',
    isIncome: true,
    icon: Icons.payments.codePoint,
    color: Colors.green.value,
    isDefault: true,
  ),
  Category(
    id: 'gift',
    name: 'Regalo',
    isIncome: true,
    icon: Icons.card_giftcard.codePoint,
    color: Colors.blue.value,
    isDefault: true,
  ),
  Category(
    id: 'rent',
    name: 'Affitto',
    isIncome: false,
    icon: Icons.home.codePoint,
    color: Colors.orange.value,
    isDefault: true,
  ),
  Category(
    id: 'groceries',
    name: 'Spesa',
    isIncome: false,
    icon: Icons.shopping_cart.codePoint,
    color: Colors.purple.value,
    isDefault: true,
  ),
  Category(
    id: 'transport',
    name: 'Trasporti',
    isIncome: false,
    icon: Icons.directions_bus.codePoint,
    color: Colors.indigo.value,
    isDefault: true,
  ),
];
