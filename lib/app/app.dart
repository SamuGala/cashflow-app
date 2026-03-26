import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/core/security/pin_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashflowApp extends ConsumerWidget {
  const CashflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        themeMode: theme == AppThemeMode.dark
            ? ThemeMode.dark
            : ThemeMode.light,

        /// 🔐 AUTH FLOW
        home: unlocked
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
