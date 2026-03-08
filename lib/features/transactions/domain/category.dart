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
    this.isDefault = false,
  });
}
