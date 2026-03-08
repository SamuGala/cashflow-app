import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/category_provider.dart';
import '../domain/category.dart';

Future<Category?> showAddCategoryDialog(
  BuildContext context,
  bool isIncome,
) async {
  final t = AppLocalizations.of(context)!;

  final controller = TextEditingController();

  int selectedColor = Colors.blue.value;
  int selectedIcon = Icons.category.codePoint;

  final colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  final icons = [
    Icons.home,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.directions_car,
    Icons.flight,
    Icons.movie,
    Icons.savings,
    Icons.attach_money,
  ];

  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// TITLE
                    Text(
                      t.newCategory,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PREVIEW
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(selectedColor).withOpacity(0.2),
                      child: Icon(
                        IconData(selectedIcon, fontFamily: 'MaterialIcons'),
                        color: Color(selectedColor),
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// NAME
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: t.nameCategory,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ICONS
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: icons.map((icon) {
                        final isSelected = icon.codePoint == selectedIcon;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = icon.codePoint;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(selectedColor).withOpacity(0.2)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// COLORS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: colors.map((color) {
                        final isSelected = color.value == selectedColor;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color.value;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            child: CircleAvatar(
                              radius: isSelected ? 16 : 14,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    /// ACTIONS
                    Row(
                      children: [

                        /// CANCEL
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },
                            child: Text(t.cancel),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// ADD CATEGORY
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final name = controller.text.trim();

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(sheetContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(t.nameCategory),
                                  ),
                                );
                                return;
                              }

                              final category = await ref
                                  .read(categoryProvider.notifier)
                                  .addCategory(
                                    name: name,
                                    isIncome: isIncome,
                                    icon: selectedIcon,
                                    color: selectedColor,
                                  );

                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, category);
                              }
                            },
                            child: Text(t.add),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}