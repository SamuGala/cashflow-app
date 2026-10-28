import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = _theme(Brightness.light);
  static final ThemeData darkTheme = _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? const Color(0xFF10151F) : const Color(0xFFF6F7FB);
    final surface = dark ? const Color(0xFF1A2331) : Colors.white;
    final ink = dark ? const Color(0xFFEFF4FF) : const Color(0xFF182338);
    final muted = dark ? const Color(0xFFA4B1C6) : const Color(0xFF68758B);
    final line = dark ? const Color(0xFF303D50) : const Color(0xFFE8ECF3);
    final soft = dark ? const Color(0xFF232F42) : const Color(0xFFF0F2F8);
    final colors =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF5867D9),
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFFAEBAFF) : const Color(0xFF5867D9),
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
          surfaceContainerHighest: line,
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
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static const cupertinoOverlay = CupertinoThemeData(
    primaryColor: Color(0xFF5867D9),
  );
}
