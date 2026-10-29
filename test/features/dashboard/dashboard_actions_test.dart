import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/features/dashboard/presentation/dashboard_page.dart';
import 'package:pocket_vault/features/forecast/presentation/cashflow_forecast_card.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:pocket_vault/shared/widgets/receipt_scan_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('receipt camera action is directly above transaction add', (
    tester,
  ) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          locale: Locale('it'),
          supportedLocales: [Locale('en'), Locale('it'), Locale('es')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: DashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final camera = find.byKey(const ValueKey('scan-receipt-button'));
    final add = find.byKey(const ValueKey('add-transaction-button'));
    expect(camera, findsOneWidget);
    expect(add, findsOneWidget);
    expect(
      find.descendant(of: camera, matching: find.byType(ReceiptScanIcon)),
      findsOneWidget,
    );
    expect(
      tester.getSize(
        find.descendant(of: camera, matching: find.byType(Material)).first,
      ),
      const Size(40, 40),
    );
    expect(tester.getSize(add), const Size(56, 56));
    expect(tester.getCenter(camera).dx, tester.getCenter(add).dx);
    expect(find.byType(CashflowForecastCard), findsNothing);
    expect(tester.getCenter(camera).dy, lessThan(tester.getCenter(add).dy));

    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byType(QuickAddTransactionSheet), findsOneWidget);

    final handle = find.byKey(const ValueKey('quick-add-drag-handle'));
    expect(handle, findsOneWidget);
    await tester.drag(handle, const Offset(0, 120));
    await tester.pumpAndSettle();

    expect(find.byType(QuickAddTransactionSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick add opens above the navigation and keeps Save visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          locale: const Locale('it'),
          supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
            ),
            bottomNavigationBar: const SizedBox(
              key: ValueKey('fake-navigation'),
              height: 64,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-transaction-button')));
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('quick-save'));
    expect(save, findsOneWidget);
    final rect = tester.getRect(save);
    expect(rect.bottom, lessThanOrEqualTo(640));
    // The sheet belongs to the root navigator, so it covers the navigation.
    final hit = tester.hitTestOnBinding(rect.center);
    expect(
      hit.path.any(
        (entry) =>
            entry.target is RenderBox &&
            (entry.target as RenderBox).hasSize &&
            find
                .byKey(const ValueKey('fake-navigation'))
                .evaluate()
                .any((e) => e.renderObject == entry.target),
      ),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
