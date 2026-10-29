import 'package:flutter/material.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/app/launch_actions.dart';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pocket_vault/app/app.dart';
import 'package:pocket_vault/app/startup_reveal.dart';
import 'package:pocket_vault/main.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/core/security/pin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Cashflow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CashflowApp()));

    expect(find.byType(StartupReveal), findsOneWidget);
    expect(find.text('Pockets Vault'), findsOneWidget);
    expect(find.byKey(const ValueKey('startup-app-icon')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('startup-progress-track')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    expect(find.byType(CashflowApp), findsOneWidget);
    expect(find.byType(StartupReveal), findsNothing);
    expect(find.byType(PinPage), findsOneWidget);
  });

  testWidgets('Root app provides a valid layout before MaterialApp mounts', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const RootApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(RootApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Root app locks after backgrounding with immediate timeout', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'auto_lock_timeout_v1': 'immediately',
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RootApp()),
    );
    await tester.pumpAndSettle();

    container.read(authProvider.notifier).unlock();
    await tester.pumpAndSettle();
    expect(container.read(authProvider), isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(container.read(authProvider), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'locking closes open sheets and holds a notification tap until the PIN',
    (WidgetTester tester) async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'auto_lock_timeout_v1': 'immediately',
        // A non-default language rebuilds the MaterialApp at startup.
        'locale': 'it',
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0},
          'publishedAt': now.toIso8601String(),
          'fetchedAt': now.toIso8601String(),
        }),
      });
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const RootApp()),
      );
      await tester.pumpAndSettle();
      container.read(authProvider.notifier).unlock();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // A sheet open when the app goes to the background.
      showModalBottomSheet<void>(
        context: appNavigatorKey.currentContext!,
        builder: (_) => const Text('open sheet'),
      );
      await tester.pumpAndSettle();
      expect(find.text('open sheet'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      // Android delivers a tapped notification before the resume.
      dispatchLaunchAction(LaunchAction.addExpense);
      await tester.pump();
      expect(find.byType(QuickAddTransactionSheet), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(container.read(authProvider), isFalse);
      expect(find.text('open sheet'), findsNothing);
      expect(find.byType(QuickAddTransactionSheet), findsNothing);
      // The PIN screen replaces the app: no tab bar behind the sheet.
      expect(find.byType(NavigationBar), findsNothing);

      expect(pendingLaunchAction.value, LaunchAction.addExpense);
      // After unlocking, the tapped reminder opens where it should.
      container.read(authProvider.notifier).unlock();
      await tester.pumpAndSettle();
      expect(find.byType(QuickAddTransactionSheet), findsOneWidget);
      expect(pendingLaunchAction.value, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
