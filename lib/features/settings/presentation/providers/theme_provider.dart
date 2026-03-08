import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark }

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.light;
  }

  void setTheme(AppThemeMode mode) {
    state = mode;
  }

  void toggle() {
    state =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }
}