import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocket_vault/app/launch_actions.dart';
import 'package:pocket_vault/app/theme/app_theme.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/notifications/notification_gateway.dart';
import 'package:pocket_vault/core/notifications/notification_planner.dart';
import 'package:pocket_vault/core/notifications/notification_providers.dart';
import 'package:pocket_vault/features/settings/presentation/settings_page.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeGateway implements NotificationGateway {
  bool grant = true;
  int permissionRequests = 0;
  List<PlannedNotification> scheduled = [];
  final shown = <String>[];

  @override
  Future<void> initialize(void Function(String? payload) onTap) async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> replaceScheduled(
    List<PlannedNotification> planned, {
    required String channelName,
  }) async => scheduled = planned;

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
    required String channelName,
  }) async => shown.add(title);

  @override
  Future<void> cancelScheduled() async => scheduled = [];
}

RecurringTransaction recurring(
  String id, {
  required DateTime start,
  int amount = 75000,
  String category = 'rent',
  String? note,
  bool active = true,
  bool income = false,
}) => RecurringTransaction(
  id: id,
  amountCents: amount,
  isIncome: income,
  categoryId: category,
  dayOfMonth: start.day,
  startDate: start,
  note: note,
  active: active,
  frequency: 'monthly',
  interval: 1,
);

void main() {
  final t = lookupAppLocalizations(const Locale('it'));
  String money(int minor) => formatMoney(minor, 'EUR', 'it');
  final now = DateTime(2026, 10, 29, 10);

  group('preferences', () {
    test('round trip, defaults off and bad input falls back', () {
      const custom = NotificationPreferences(
        recurring: true,
        recurringDaysBefore: 2,
        budget: true,
        budgetThreshold: 90,
        reminder: true,
        reminderHour: 20,
        reminderMinute: 30,
        hideAmounts: true,
      );
      final decoded = NotificationPreferences.decode(custom.encode());
      expect(decoded.encode(), custom.encode());
      expect(NotificationPreferences.decode(null).anyEnabled, isFalse);
      expect(NotificationPreferences.decode('{oops').anyEnabled, isFalse);
      expect(
        NotificationPreferences.decode(
          jsonEncode({'recurringDaysBefore': 40, 'budgetThreshold': 'x'}),
        ).recurringDaysBefore,
        3,
      );
    });
  });

  group('planRecurringReminders', () {
    const prefs = NotificationPreferences(recurring: true);

    test('day before at 9:00, named by note or category, amounts shown', () {
      final planned = planRecurringReminders(
        prefs: prefs,
        recurring: [
          recurring('rent', start: DateTime(2026, 1, 1)),
          recurring(
            'gym',
            start: DateTime(2026, 1, 30),
            amount: 4500,
            category: 'health',
            note: 'Palestra',
          ),
          recurring('paused', start: DateTime(2026, 1, 5), active: false),
        ],
        categoryNames: {'rent': 'Affitto', 'health': 'Salute'},
        money: money,
        t: t,
        now: now,
        horizonDays: 40,
      );
      // The gym reminder for 30 Oct (29 Oct 9:00) is already past at 10:00.
      expect(planned.map((p) => p.title), [
        'Affitto domani',
        'Palestra domani',
        'Affitto domani',
      ]);
      expect(planned.first.at, DateTime(2026, 10, 31, 9));
      expect(planned.first.body, 'Uscita ricorrente di ${money(75000)}.');
      expect(planned.map((p) => p.id).toSet(), hasLength(3));
      expect(
        planned.every((p) => p.target == NotificationTarget.recurring),
        isTrue,
      );
    });

    test('same day option, hidden amounts and off switch', () {
      final hidden = planRecurringReminders(
        prefs: prefs.copyWith(recurringDaysBefore: 0, hideAmounts: true),
        recurring: [recurring('rent', start: DateTime(2026, 1, 1))],
        categoryNames: const {'rent': 'Affitto'},
        money: money,
        t: t,
        now: now,
        horizonDays: 5,
      );
      expect(hidden.single.title, 'Affitto oggi');
      expect(hidden.single.at, DateTime(2026, 11, 1, 9));
      expect(hidden.single.body, 'Movimento ricorrente in arrivo.');
      expect(
        planRecurringReminders(
          prefs: const NotificationPreferences(),
          recurring: [recurring('rent', start: DateTime(2026, 1, 1))],
          categoryNames: const {},
          money: money,
          t: t,
          now: now,
        ),
        isEmpty,
      );
    });
  });

  group('planEveningReminders', () {
    const prefs = NotificationPreferences(reminder: true);
    TransactionModel logged(DateTime createdAt, {String? recurringId}) =>
        TransactionModel(
          id: 'x',
          amountCents: 100,
          isIncome: false,
          categoryId: 'food',
          date: createdAt,
          createdAt: createdAt,
          recurringSourceId: recurringId,
        );

    test('a week of evenings, skipping today once something is logged', () {
      final week = planEveningReminders(
        prefs: prefs,
        transactions: const [],
        t: t,
        now: now,
      );
      expect(week, hasLength(7));
      expect(week.first.at, DateTime(2026, 10, 29, 21));
      expect(week.first.target, NotificationTarget.quickAdd);

      final afterLogging = planEveningReminders(
        prefs: prefs,
        transactions: [logged(DateTime(2026, 10, 29, 8))],
        t: t,
        now: now,
      );
      expect(afterLogging.first.at, DateTime(2026, 10, 30, 21));
      // Movements generated by recurrences are not the user logging.
      expect(
        planEveningReminders(
          prefs: prefs,
          transactions: [logged(DateTime(2026, 10, 29, 8), recurringId: 'r')],
          t: t,
          now: now,
        ).first.at,
        DateTime(2026, 10, 29, 21),
      );
      // Past today's time, the first one is tomorrow.
      expect(
        planEveningReminders(
          prefs: prefs,
          transactions: const [],
          t: t,
          now: DateTime(2026, 10, 29, 22),
        ).first.at,
        DateTime(2026, 10, 30, 21),
      );
    });
  });

  group('budgetAlerts', () {
    final budget = BudgetRow(
      id: 'b-food',
      categoryId: 'food',
      amountMinor: 20000,
      eurAmountMicros: 200000000,
      periodType: 'monthly',
      rollover: false,
      active: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    TransactionModel spend(int amount, DateTime date) => TransactionModel(
      id: '$amount-$date',
      amountCents: amount,
      isIncome: false,
      categoryId: 'food',
      date: date,
    );

    List<BudgetAlert> alerts(List<TransactionModel> rows, Set<String> sent) =>
        budgetAlerts(
          prefs: const NotificationPreferences(budget: true),
          budgets: [budget],
          transactions: rows,
          categoryNames: const {'food': 'Cibo'},
          money: money,
          t: t,
          now: now,
          alreadySent: sent,
        );

    test('threshold then limit, once each, current month only', () {
      expect(alerts([spend(15000, DateTime(2026, 10, 3))], {}), isEmpty);
      // Last month's spending does not count.
      expect(
        alerts([
          spend(15000, DateTime(2026, 10, 3)),
          spend(9000, DateTime(2026, 9, 3)),
        ], {}),
        isEmpty,
      );
      final reached = alerts([spend(16500, DateTime(2026, 10, 3))], {});
      expect(reached.single.title, 'Cibo al 82% del budget');
      expect(
        reached.single.body,
        'Spesi ${money(16500)} su ${money(20000)} questo mese.',
      );
      expect(
        alerts([spend(16500, DateTime(2026, 10, 3))], {reached.single.key}),
        isEmpty,
      );
      final over = alerts(
        [spend(21000, DateTime(2026, 10, 3))],
        {reached.single.key},
      );
      expect(over.single.title, 'Budget Cibo superato');
    });
  });

  group('sync and settings', () {
    late AppDatabase database;
    late FakeGateway gateway;

    setUp(() {
      final today = DateTime.now();
      FlutterSecureStorage.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'Pockets Vault',
        packageName: 'pocket_vault',
        version: '2.1.0',
        buildNumber: '13',
        buildSignature: '',
      );
      SharedPreferences.setMockInitialValues({
        'locale': 'it',
        'base_currency_v1': 'EUR',
        'currency_rates_ecb_v1': jsonEncode({
          'rates': {'EUR': 1.0},
          'publishedAt': today.toIso8601String(),
          'fetchedAt': today.toIso8601String(),
        }),
      });
      database = AppDatabase.forTesting(NativeDatabase.memory());
      gateway = FakeGateway();
    });

    tearDown(() => database.close());

    Widget app(Widget home) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationGatewayProvider.overrideWithValue(gateway),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(notificationSyncProvider);
          return MaterialApp(
            locale: const Locale('it'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.lightTheme,
            home: home,
          );
        },
      ),
    );

    Future<void> settle(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapSwitch(WidgetTester tester, String key) async {
      final finder = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(finder, 200);
      await tester.tap(finder);
      await settle(tester);
    }

    testWidgets('switches ask permission once and drive the schedule', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await database
          .into(database.recurringTransactions)
          .insert(recurring('rent', start: DateTime(2026, 1, 1)));
      await tester.pumpWidget(app(const SettingsPage()));
      await settle(tester);
      expect(find.text('Notifiche'), findsOneWidget);
      expect(gateway.scheduled, isEmpty);

      await tapSwitch(tester, 'notify-recurring');
      expect(gateway.permissionRequests, 1);
      expect(find.byKey(const ValueKey('notify-recurring-days')), findsOne);
      expect(
        gateway.scheduled.every(
          (p) => p.target == NotificationTarget.recurring,
        ),
        isTrue,
      );
      expect(gateway.scheduled, isNotEmpty);

      await tapSwitch(tester, 'notify-reminder');
      expect(gateway.permissionRequests, 2);
      expect(
        gateway.scheduled.where((p) => p.target == NotificationTarget.quickAdd),
        isNotEmpty,
      );
      final stored = NotificationPreferences.decode(
        (await SharedPreferences.getInstance()).getString(notificationPrefsKey),
      );
      expect(stored.recurring && stored.reminder, isTrue);

      // Turning everything off clears the schedule.
      await tapSwitch(tester, 'notify-recurring');
      await tapSwitch(tester, 'notify-reminder');
      expect(gateway.scheduled, isEmpty);
      expect(gateway.permissionRequests, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('denied permission keeps the switch off and explains why', (
      tester,
    ) async {
      gateway.grant = false;
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(const SettingsPage()));
      await settle(tester);
      await tapSwitch(tester, 'notify-budget');
      expect(
        find.text(
          'Notifiche non consentite. Attivale nelle impostazioni del telefono.',
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Switch>(find.byKey(const ValueKey('notify-budget')))
            .value,
        isFalse,
      );
    });
  });

  test('tapped notifications become launch actions', () {
    handleNotificationTap('recurring');
    expect(pendingLaunchAction.value, LaunchAction.openRecurring);
    handleNotificationTap('quickAdd');
    expect(pendingLaunchAction.value, LaunchAction.addExpense);
    handleNotificationTap('budget');
    expect(pendingLaunchAction.value, LaunchAction.openHome);
    handleNotificationTap('unknown');
    expect(pendingLaunchAction.value, isNull);
    expect(
      launchActionFromUri(Uri.parse('pocketvault:///add?flow=income')),
      LaunchAction.addIncome,
    );
    expect(
      launchActionFromUri(Uri.parse('pocketvault:///scan')),
      LaunchAction.scanReceipt,
    );
  });
}
