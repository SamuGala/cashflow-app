import 'package:flutter/material.dart';

import '../../core/utils/category_localization.dart';
import '../../features/transactions/domain/category.dart';

/// Semantic money colors shared by Home, Movements and the entry forms.
class VaultColors {
  const VaultColors._();

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color income(BuildContext context) =>
      _dark(context) ? const Color(0xFF82DFB4) : const Color(0xFF17734E);

  static Color expense(BuildContext context) =>
      _dark(context) ? const Color(0xFFFF8E9C) : const Color(0xFFC93545);

  static Color savings(BuildContext context) =>
      _dark(context) ? const Color(0xFF8DB6FF) : const Color(0xFF2F6BDE);

  static Color flow(BuildContext context, bool isIncome) =>
      isIncome ? income(context) : expense(context);
}

/// Card surface of the Vault design: white with a hairline border in light
/// mode, a subtle gradient in dark mode.
class VaultSurface extends StatelessWidget {
  const VaultSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? null : colors.surface,
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF182431), Color(0xFF15202C)],
              )
            : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? colors.outlineVariant : const Color(0xFFF0F2F8),
          width: .7,
        ),
      ),
      child: child,
    );
  }
}

/// Category glyph on a tint of the category's own saved color.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.category,
    this.size = 40,
    this.badge,
  });

  final Category? category;
  final double size;

  /// Small icon shown in the bottom-right corner, e.g. for recurrences.
  final IconData? badge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final category = this.category;
    final tint = category == null
        ? colors.onSurfaceVariant
        : Color(category.color);
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: dark ? .22 : .13),
        borderRadius: BorderRadius.circular(size * .34),
      ),
      child: Icon(
        category == null
            ? Icons.category_outlined
            : category.isDefault
            ? categoryIcon(category.name)
            : customCategoryIcon(category.icon),
        size: size * .52,
        color: tint,
      ),
    );
    if (badge == null) return avatar;
    final badgeSize = size * .42;
    return SizedBox(
      width: size + 3,
      height: size + 3,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.outlineVariant, width: .7),
              ),
              child: Icon(
                badge,
                size: badgeSize * .66,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand row, big page title and optional trailing control, as introduced by
/// the Statistics tab.
class VaultPageHeader extends StatelessWidget {
  const VaultPageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.trailingMaxWidth = 156,
    this.brandKey,
    this.brandTooltip,
    this.onBrandTap,
    this.brandHidden = false,
  });

  final String title;
  final Widget? trailing;
  final double trailingMaxWidth;
  final Key? brandKey;
  final String? brandTooltip;
  final VoidCallback? onBrandTap;

  /// Replaces the wallet mark with a crossed eye while amounts are hidden.
  final bool brandHidden;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget brand = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (brandHidden)
            Icon(
              Icons.visibility_off_outlined,
              size: 25,
              color: colors.onSurface,
            )
          else
            VaultWalletMark(color: colors.onSurface),
          const SizedBox(width: 11),
          Flexible(
            child: Text(
              'Pockets Vault',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -.4,
                color: colors.onSurface,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
    if (onBrandTap != null) {
      brand = InkWell(
        key: brandKey,
        borderRadius: BorderRadius.circular(12),
        onTap: onBrandTap,
        child: brand,
      );
      if (brandTooltip != null) {
        brand = Tooltip(message: brandTooltip!, child: brand);
      }
    } else {
      brand = KeyedSubtree(key: brandKey, child: brand);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(alignment: Alignment.centerLeft, child: brand),
        const SizedBox(height: 2),
        LayoutBuilder(
          builder: (_, constraints) {
            final large =
                constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.15;
            final heading = Text(
              title,
              style: TextStyle(
                fontSize: 34,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
                color: colors.onSurface,
              ),
            );
            final trailing = this.trailing;
            if (trailing == null) return heading;
            final selector = ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: large ? constraints.maxWidth : trailingMaxWidth,
              ),
              child: trailing,
            );
            if (large) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading,
                  Align(alignment: Alignment.centerRight, child: selector),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: heading,
                  ),
                ),
                const SizedBox(width: 8),
                selector,
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Underlined tab strip of the Statistics tab.
class VaultTabs extends StatelessWidget {
  const VaultTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.keyPrefix = 'vault-tab',
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: .7),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: selectedIndex == i,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selectedIndex == i
                            ? colors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: TextButton(
                    key: ValueKey('$keyPrefix-$i'),
                    onPressed: () => onChanged(i),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 2,
                      ),
                      minimumSize: const Size(0, 40),
                      foregroundColor: selectedIndex == i
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selectedIndex == i
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Muted caption used above grouped sections.
class VaultSectionLabel extends StatelessWidget {
  const VaultSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Thin wallet outline used as the app mark in page headers.
class VaultWalletMark extends StatelessWidget {
  const VaultWalletMark({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(25, 25), painter: _WalletPainter(color));
}

class _WalletPainter extends CustomPainter {
  final Color color;
  const _WalletPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(4, 9)
        ..lineTo(23, 3)
        ..quadraticBezierTo(25, 2.4, 25.5, 5)
        ..lineTo(27, 9),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(3, 9, 29, 29),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(24, 19), 1.4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WalletPainter oldDelegate) => oldDelegate.color != color;
}
