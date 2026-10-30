import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = _theme(Brightness.light);
  static final ThemeData darkTheme = _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    // Vault palette, shared by every tab since the Statistics redesign.
    final background = dark ? const Color(0xFF0E1722) : const Color(0xFFF5F7FC);
    final surface = dark ? const Color(0xFF182431) : Colors.white;
    final ink = dark ? const Color(0xFFF5F7FC) : const Color(0xFF0A132C);
    // #5E6A85 keeps secondary text above WCAG AA on the tinted backgrounds.
    final muted = dark ? const Color(0xFFA2B0C9) : const Color(0xFF5E6A85);
    final line = dark ? const Color(0xFF283346) : const Color(0xFFE7E9F3);
    final soft = dark ? const Color(0xFF223041) : const Color(0xFFF0F2F8);
    final track = dark ? const Color(0xFF2C3848) : const Color(0xFFEAEFF5);
    final primary = dark ? const Color(0xFF969DFF) : const Color(0xFF4654EE);
    final colors =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF4654EE),
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF182338) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF303C69)
              : const Color(0xFFDFE2FF),
          onPrimaryContainer: dark
              ? const Color(0xFFDCE3FF)
              : const Color(0xFF405384),
          surface: surface,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerLowest: background,
          surfaceContainerLow: surface,
          surfaceContainer: soft,
          surfaceContainerHigh: soft,
          surfaceContainerHighest: track,
          outlineVariant: line,
          error: dark ? const Color(0xFFFF9CAB) : const Color(0xFFB44050),
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colors,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : muted,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: muted.withValues(alpha: .38),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: .5)),
        ),
      ),
    );
  }

  /// The theme of one tab: its own background, accent and navigation pill.
  /// The four tab pages use transparent scaffolds so the shell's tinted
  /// background and top wash show behind them; pages pushed above them keep
  /// a solid background of the same tint.
  static ThemeData section(ThemeData base, VaultSection section) {
    final dark = base.brightness == Brightness.dark;
    final palette = dark ? section.dark : section.light;
    final colors = base.colorScheme.copyWith(
      primary: palette.accent,
      onPrimary: dark ? palette.background : Colors.white,
      primaryContainer: palette.tonal,
      onPrimaryContainer: palette.onTonal,
    );
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      colorScheme: colors,
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: palette.action,
        foregroundColor: Colors.white,
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: palette.background,
      ),
      extensions: [palette],
    );
  }

  static const cupertinoOverlay = CupertinoThemeData(
    primaryColor: Color(0xFF4654EE),
  );
}

/// Colors of one tab in one brightness.
class VaultSectionPalette extends ThemeExtension<VaultSectionPalette> {
  const VaultSectionPalette({
    required this.background,
    required this.wash,
    required this.accent,
    required this.tonal,
    required this.onTonal,
    required this.navigation,
    required this.action,
  });

  final Color background;

  /// Color at the top of the page, fading into [background].
  final Color wash;
  final Color accent;
  final Color tonal;
  final Color onTonal;

  /// Selected icon and label in the navigation bar; the pill is [tonal].
  final Color navigation;

  /// Floating action button.
  final Color action;

  @override
  VaultSectionPalette copyWith() => this;

  @override
  VaultSectionPalette lerp(VaultSectionPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return VaultSectionPalette(
      background: mix(background, other.background),
      wash: mix(wash, other.wash),
      accent: mix(accent, other.accent),
      tonal: mix(tonal, other.tonal),
      onTonal: mix(onTonal, other.onTonal),
      navigation: mix(navigation, other.navigation),
      action: mix(action, other.action),
    );
  }
}

/// Each tab has a color identity: Home indigo, Movements teal, Statistics
/// violet. Settings shares Home's. The entry sheets stay indigo everywhere.
enum VaultSection {
  home(
    light: VaultSectionPalette(
      background: Color(0xFFEEF0FD),
      wash: Color(0xFFE1E5FD),
      accent: Color(0xFF4654EE),
      tonal: Color(0xFFE3E6FD),
      onTonal: Color(0xFF2E39C4),
      navigation: Color(0xFF4654EE),
      action: Color(0xFF4654EE),
    ),
    dark: VaultSectionPalette(
      background: Color(0xFF10152B),
      wash: Color(0xFF1C2350),
      accent: Color(0xFF969DFF),
      tonal: Color(0xFF262E5C),
      onTonal: Color(0xFFC9CCFF),
      navigation: Color(0xFFA9AFFF),
      action: Color(0xFF4654EE),
    ),
  ),
  movements(
    light: VaultSectionPalette(
      background: Color(0xFFECF6F5),
      wash: Color(0xFFD6EEEB),
      // Darker than the income green, so the two never read alike.
      accent: Color(0xFF0A6B65),
      tonal: Color(0xFFD8EFEC),
      onTonal: Color(0xFF0A5E59),
      navigation: Color(0xFF0A6B65),
      action: Color(0xFF0E8C84),
    ),
    dark: VaultSectionPalette(
      background: Color(0xFF0B1A1C),
      wash: Color(0xFF123236),
      accent: Color(0xFF5FD3C8),
      tonal: Color(0xFF16383A),
      onTonal: Color(0xFFA4EBE4),
      navigation: Color(0xFF6FDCD2),
      action: Color(0xFF0E8C84),
    ),
  ),
  stats(
    light: VaultSectionPalette(
      background: Color(0xFFF3EFFC),
      wash: Color(0xFFE7DEFB),
      accent: Color(0xFF6A3FD6),
      tonal: Color(0xFFE8E0FB),
      onTonal: Color(0xFF5530B8),
      navigation: Color(0xFF6A3FD6),
      action: Color(0xFF7A4FE0),
    ),
    dark: VaultSectionPalette(
      background: Color(0xFF150F26),
      wash: Color(0xFF2A1F4E),
      accent: Color(0xFFB9A1FF),
      tonal: Color(0xFF2D2252),
      onTonal: Color(0xFFD9CCFF),
      navigation: Color(0xFFC4B0FF),
      action: Color(0xFF7A4FE0),
    ),
  );

  const VaultSection({required this.light, required this.dark});

  final VaultSectionPalette light;
  final VaultSectionPalette dark;

  /// Navigation branch index → section (Settings follows Home).
  static VaultSection forBranch(int index) => switch (index) {
    1 => VaultSection.movements,
    2 => VaultSection.stats,
    _ => VaultSection.home,
  };
}
