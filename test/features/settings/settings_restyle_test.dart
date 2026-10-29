import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import 'package:pocket_vault/core/security/auto_lock_provider.dart';
import 'package:pocket_vault/features/forecast/presentation/cashflow_forecast_card.dart';
import 'package:pocket_vault/features/goals/presentation/savings_goals_card.dart';
import 'package:pocket_vault/features/goals/providers/savings_goals_provider.dart';
import 'package:pocket_vault/features/settings/presentation/settings_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    final now = DateTime.now();
    FlutterSecureStorage.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Pockets Vault',
      packageName: 'pocket_vault',
      version: '2.1.0',
      buildNumber: '13',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Widget app(
    Widget home, {
    String locale = 'it',
    bool dark = false,
    double textScale = 1,
  }) => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(database)],
    child: MaterialApp(
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    ),
  );

  testWidgets('settings render in every language, theme and at 150% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in ['it', 'en', 'es']) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 1.5]) {
          await tester.pumpWidget(
            app(
              const SettingsPage(),
              locale: locale,
              dark: dark,
              textScale: scale,
            ),
          );
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView), const Offset(0, -3000));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('settings-delete-all')),
            findsOneWidget,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$locale dark=$dark x$scale',
          );
        }
      }
    }
  });

  testWidgets('delete all asks for confirmation and cancel keeps the data', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pumpAndSettle();
    expect(find.text('Aspetto'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    final categories = await database.select(database.categories).get();
    final row = find.byKey(const ValueKey('settings-delete-all'));
    await tester.scrollUntilVisible(row, 200);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(
      find.text('Sei sicuro di voler eliminare tutti i dati salvati?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Annulla'));
    await tester.pumpAndSettle();
    expect(await database.select(database.categories).get(), categories);
  });

  testWidgets('language and auto-lock menus change the setting', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SettingsPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('settings-auto-lock')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-auto-lock')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dopo 5 minuti').last);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsPage)),
    );
    expect(container.read(autoLockProvider).value, AutoLockTimeout.minutes5);
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(container.read(localeProvider).languageCode, 'en');
    expect(tester.takeException(), isNull);
  });

  testWidgets('goal card, goal sheet and forecast render in both themes', (
    tester,
  ) async {
    await tester.pumpWidget(app(const Scaffold(body: SizedBox())));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SizedBox).first),
    );
    await container
        .read(savingsGoalsProvider.notifier)
        .addGoal(name: 'Vacanza', targetAmountMinor: 50000);
    final goal = (await container.read(savingsGoalsProvider.future)).single;
    await container
        .read(savingsGoalsProvider.notifier)
        .contribute(goal.id, 20000);
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        app(
          Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SavingsGoalsCard(),
                SizedBox(height: 12),
                CashflowForecastCard(),
              ],
            ),
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vacanza'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      // The fill starts at the leading edge of a visible track.
      final fill = find.descendant(
        of: find.byType(SavingsGoalsCard),
        matching: find.byType(FractionallySizedBox),
      );
      final track = find.ancestor(of: fill, matching: find.byType(ColoredBox));
      final fillRect = tester.getRect(fill);
      final trackRect = tester.getRect(track.first);
      expect(fillRect.left, closeTo(trackRect.left, .5));
      expect(fillRect.width, closeTo(trackRect.width * .4, 1));
      await tester.tap(find.text('Gestisci'));
      await tester.pumpAndSettle();
      expect(find.byType(SavingsGoalsSheet), findsOneWidget);
      expect(find.text('Accantona'), findsOneWidget);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(SavingsGoalsSheet))).pop();
      await tester.pumpAndSettle();
    }
  });
}
