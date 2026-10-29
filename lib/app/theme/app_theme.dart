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
    final muted = dark ? const Color(0xFFA2B0C9) : const Color(0xFF74809A);
    final line = dark ? const Color(0xFF303D50) : const Color(0xFFE8ECF3);
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

  static const cupertinoOverlay = CupertinoThemeData(
    primaryColor: Color(0xFF4654EE),
  );
}
