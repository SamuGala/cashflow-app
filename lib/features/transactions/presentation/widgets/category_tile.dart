import 'package:flutter/material.dart';
import '../../domain/category.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          IconData(category.icon, fontFamily: 'MaterialIcons'),
          color: color,
        ),
      ),
      title: Text(category.name),
      onTap: onTap,
    );
  }
}
