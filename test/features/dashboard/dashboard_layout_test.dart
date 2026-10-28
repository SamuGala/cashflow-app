import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/dashboard/presentation/dashboard_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'populated dashboard fits small screens, large text and every locale',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();
      final month = DateTime(now.year, now.month + 1);
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
      for (final entry in [('salary', 280000, true), ('food', 35000, false)]) {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            id: entry.$1,
            categoryId: entry.$1,
            amountCents: entry.$2,
            isIncome: entry.$3,
            date: DateTime(month.year, month.month, 2),
          ),
        );
      }
      await database
          .into(database.recurringTransactions)
          .insert(
            RecurringTransaction(
              id: 'rent',
              amountCents: 40000,
              isIncome: false,
              categoryId: 'rent',
              dayOfMonth: 20,
              startDate: month,
              active: true,
              frequency: 'monthly',
              interval: 1,
            ),
          );
      for (final language in ['it', 'en', 'es']) {
        for (final dark in [false, true]) {
          final container = ProviderContainer(
            overrides: [databaseProvider.overrideWithValue(database)],
          );
          container.read(timeFilterProvider.notifier).setMonth(month);
          container.read(balanceVisibilityProvider.notifier).show();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: Locale(language),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.5)),
                  child: child!,
                ),
                home: const DashboardPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$language, dark=$dark',
          );
          final amount = find.byKey(const ValueKey('category-total-food'));
          await tester.scrollUntilVisible(
            amount,
            200,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 20,
          );
          await tester.pumpAndSettle();
          expect(amount, findsOneWidget);
          final box = tester.getRect(amount);
          for (final key in ['scan-receipt-button', 'add-transaction-button']) {
            expect(
              box.overlaps(tester.getRect(find.byKey(ValueKey(key)))),
              isFalse,
            );
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '$language, dark=$dark',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
        }
      }
    },
  );
}
