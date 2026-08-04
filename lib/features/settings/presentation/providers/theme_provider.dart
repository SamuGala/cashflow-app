import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    unawaited(_load());
    return AppThemeMode.system;
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString('theme_mode_v1');
    if (saved == null) return;
    state = AppThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('theme_mode_v1', mode.name);
    state = mode;
  }

  Future<void> toggle() {
    return setTheme(
      state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light,
    );
  }
}
