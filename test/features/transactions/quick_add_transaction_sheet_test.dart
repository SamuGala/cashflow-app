import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/receipts/receipt_scan_review_sheet.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('quick add initializes the base currency before rendering', (
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
          home: Scaffold(body: QuickAddTransactionSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EUR'), findsWidgets);
    expect(find.text('Scansiona ricevuta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reviewed receipt pre-fills the transaction form', (
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
    const reviewed = ReceiptScanReviewResult(
      decision: ReceiptScanDecision.useDetectedData,
      draft: ReceiptScanDraft(
        imagePath: '/tmp/reviewed-receipt.jpg',
        extraction: ReceiptExtraction(
          amountMinor: 3200,
          currencyCode: 'EUR',
          date: null,
          merchant: 'La Feltrinelli',
          categoryId: 'education',
          confidence: .95,
          recognizedText: 'LA FELTRINELLI LIBRI',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          locale: Locale('it'),
          supportedLocales: [Locale('en'), Locale('it'), Locale('es')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: QuickAddTransactionSheet(initialReceipt: reviewed),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('32.00'), findsOneWidget);
    expect(find.text('La Feltrinelli'), findsOneWidget);
    expect(find.text('Studio'), findsWidgets);
    expect(find.text('Ricevuta allegata'), findsOneWidget);
    expect(find.text('Scansiona ricevuta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('amount keypad supports fast entry and long-press clear', (
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
          home: Scaffold(body: QuickAddTransactionSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('0.00'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-amount-key-00')), findsOneWidget);

    final one = find.byKey(const ValueKey('quick-amount-key-1'));
    final doubleZero = find.byKey(const ValueKey('quick-amount-key-00'));
    final zero = find.byKey(const ValueKey('quick-amount-key-0'));
    await tester.ensureVisible(one);
    await tester.tap(one);
    await tester.ensureVisible(doubleZero);
    await tester.tap(doubleZero);
    await tester.ensureVisible(zero);
    await tester.tap(zero);
    await tester.pump();
    expect(find.text('10.00'), findsOneWidget);

    final backspace = find.byKey(const ValueKey('quick-amount-backspace'));
    await tester.ensureVisible(backspace);
    await tester.longPress(backspace);
    await tester.pump();
    expect(find.text('0.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
