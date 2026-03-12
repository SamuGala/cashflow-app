class Category {
  final String id;
  final String name;
  final bool isIncome;
  final int icon;
  final int color;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.isIncome,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  Category copyWith({
    String? id,
    String? name,
    bool? isIncome,
    int? icon,
    int? color,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isIncome: isIncome ?? this.isIncome,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}