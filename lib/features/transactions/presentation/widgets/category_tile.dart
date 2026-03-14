import 'package:flutter/material.dart';

import '../../domain/category.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/category_localization.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(category.color).withOpacity(0.2),
        child: Icon(
          category.isDefault
              ? categoryIcon(category.name)
              : IconData(category.icon, fontFamily: 'MaterialIcons'),
          color: Color(category.color),
        ),
      ),
      title: Text(
        categoryName(category.name, t),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
