import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/app/startup_reveal.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/core/security/pin_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashflowApp extends ConsumerStatefulWidget {
  const CashflowApp({super.key});

  @override
  ConsumerState<CashflowApp> createState() => _CashflowAppState();
}

class _CashflowAppState extends ConsumerState<CashflowApp> {
  bool _startupFinished = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final unlocked = ref.watch(authProvider);

    return CupertinoTheme(
      data: AppTheme.cupertinoOverlay,
      child: MaterialApp(
        key: ValueKey(locale.languageCode), // forza rebuild lingua
        debugShowCheckedModeBanner: false,

        /// 🌍 LOCALIZATION
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,

        /// 🎨 THEME
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: switch (theme) {
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
        },
        builder: (context, child) {
          final currentTheme = Theme.of(context);
          final isDark = currentTheme.brightness == Brightness.dark;
          final baseStyle = isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: baseStyle.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: currentTheme.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },

        /// 🔐 AUTH FLOW
        home: !_startupFinished
            ? StartupReveal(
                onFinished: () {
                  if (mounted) setState(() => _startupFinished = true);
                },
              )
            : unlocked
            ? Router(
                routerDelegate: appRouter.routerDelegate,
                routeInformationParser: appRouter.routeInformationParser,
                routeInformationProvider: appRouter.routeInformationProvider,
              )
            : const PinPage(),
      ),
    );
  }
}
