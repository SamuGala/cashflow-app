import 'package:pocket_vault/app/router.dart';
import 'package:pocket_vault/app/startup_reveal.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/core/currency/currency_provider.dart';
import 'package:pocket_vault/core/notifications/notification_providers.dart';
import 'package:pocket_vault/core/widgets/widget_sync_service.dart';
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/core/security/pin_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app-level navigator: sheets and full-screen pages opened with
/// `useRootNavigator` live here, above the router or the PIN screen.
GlobalKey<NavigatorState> get appNavigatorKey => _appNavigatorKey;
var _appNavigatorKey = GlobalKey<NavigatorState>();
String? _navigatorLanguage;

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
    // The MaterialApp is rebuilt from scratch when the language changes; a
    // fresh navigator key keeps it from inheriting the old navigator state.
    if (_navigatorLanguage != locale.languageCode) {
      _navigatorLanguage = locale.languageCode;
      _appNavigatorKey = GlobalKey<NavigatorState>();
    }
    // Locking must not leave a sheet or page of the unlocked app above the
    // PIN screen.
    ref.listen(authProvider, (wasUnlocked, unlocked) {
      if (wasUnlocked == true && !unlocked) {
        appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
    // Keeps scheduled reminders in line with the data while the app runs.
    ref.watch(notificationSyncProvider);
    // The widget text follows the app language, loaded after the first frame.
    ref.listen(localeProvider, (previous, next) {
      final transactions = ref.read(transactionProvider).value;
      if (previous == next || transactions == null) return;
      WidgetSyncService().sync(
        transactions: transactions,
        currencyCode: ref.read(currencyProvider).value?.baseCurrency ?? 'EUR',
        locale: next,
      );
    });

    return CupertinoTheme(
      data: AppTheme.cupertinoOverlay,
      child: MaterialApp(
        key: ValueKey(locale.languageCode), // forza rebuild lingua
        navigatorKey: appNavigatorKey,
        // Deep links are routed by go_router or by RootApp, never by this
        // MaterialApp, which only hosts the startup, PIN and router screens.
        initialRoute: '/',
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
