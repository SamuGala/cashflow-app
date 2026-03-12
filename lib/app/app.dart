import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/constants/app_constants.dart';
import 'package:pocket_vault/features/settings/presentation/providers/locale_provider.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

class CashflowApp extends ConsumerWidget {
  const CashflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return CupertinoTheme(
      data: AppTheme.cupertinoOverlay,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme == AppThemeMode.dark
            ? ThemeMode.dark
            : ThemeMode.light,

        locale: locale,

        supportedLocales: const [Locale('it'), Locale('en'), Locale('es')],

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        routerConfig: appRouter,
      ),
    );
  }
}
