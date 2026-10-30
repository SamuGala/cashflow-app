import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/app/launch_actions.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/notifications/notification_gateway.dart';
import 'package:pocket_vault/core/notifications/notification_planner.dart';
import 'package:pocket_vault/core/notifications/notification_providers.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/receipts/receipt_capture_page.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/features/transactions/presentation/quick_add_transaction_sheet.dart';
import 'package:pocket_vault/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what would reach the system, so no permission prompt blocks the
/// run and the schedule can be checked.
class RecordingGateway implements NotificationGateway {
  List<PlannedNotification> scheduled = [];
  final shown = <String>[];

  @override
  Future<void> initialize(void Function(String? payload) onTap) async {}

  @override
  Future<bool> requestPermission() async => true;

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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_REDESIGN');

  testWidgets('suggestions, filters, notifications and launch actions', (
    tester,
  ) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'locale': 'it',
      'theme_mode_v1': 'light',
      'base_currency_v1': 'EUR',
      'currency_rates_ecb_v1': jsonEncode({
        'rates': {'EUR': 1.0, 'USD': 1.1},
        'publishedAt': now.toIso8601String(),
        'fetchedAt': now.toIso8601String(),
      }),
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final gateway = RecordingGateway();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    DateTime daysAgo(int days) =>
        DateTime(now.year, now.month, now.day - days, 12);
    var serial = 0;
    Future<void> add(
      String category,
      int amount,
      String note,
      int ago, {
      bool income = false,
    }) => database.insertTransaction(
      TransactionsCompanion.insert(
        id: 'seed-${serial++}',
        categoryId: category,
        amountCents: amount,
        isIncome: income,
        date: daysAgo(ago),
        note: Value(note),
      ),
    );
    // Repeated movements become suggestions.
    for (final ago in [1, 8, 15, 22]) {
      await add('groceries', 6840, 'Esselunga', ago);
    }
    for (final ago in [2, 9, 16]) {
      await add('food', 250, 'Caffè al bar', ago);
    }
    await add('transport', 3500, 'Abbonamento bus', 3);
    await add('transport', 3500, 'Abbonamento bus', 33);
    await add('shopping', 12900, 'Scarpe', 4);
    await add('salary', 280000, 'Stipendio', 5, income: true);
    await add('salary', 280000, 'Stipendio', 35, income: true);
    await database
        .into(database.recurringTransactions)
        .insert(
          RecurringTransaction(
            id: 'rent',
            amountCents: 75000,
            isIncome: false,
            categoryId: 'rent',
            dayOfMonth: 1,
            startDate: DateTime(now.year, now.month + 1),
            note: 'Affitto',
            active: true,
            frequency: 'monthly',
            interval: 1,
          ),
        );

    container.read(authProvider.notifier).unlock();
    container.read(balanceVisibilityProvider.notifier).show();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RootApp()),
    );
    await tester.pumpAndSettle();
    if (capture) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      if (capture) await binding.takeScreenshot('features-$name');
    }

    Future<void> openTab(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder byKey(String key) => find.byKey(ValueKey(key));

    // 1 · Suggestions in the quick add sheet.
    await tester.tap(byKey('add-transaction-button'));
    await tester.pumpAndSettle();
    expect(find.text('Suggeriti'), findsOneWidget);
    await tester.ensureVisible(byKey('quick-suggestions'));
    await shot('01-suggestions');
    await tester.tap(byKey('quick-suggestion-0'));
    await tester.pumpAndSettle();
    await shot('02-suggestion-applied');
    await tester.tap(byKey('quick-save'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byType(QuickAddTransactionSheet), findsNothing);
    final rows = await database.getAllTransactions();
    expect(rows.where((r) => r.note == 'Esselunga'), hasLength(5));

    // 5 · Filters in Movements.
    await openTab('Movimenti');
    // Movement rows shown in the list (each is a Dismissible).
    int movementCount() => find.byType(Dismissible).evaluate().length;
    final unfiltered = movementCount();
    await tester.tap(byKey('movements-filter-button'));
    await tester.pumpAndSettle();
    await shot('03-filters-sheet');
    await tester.tap(byKey('filter-flow-1'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('filter-category-groceries'));
    await tester.tap(byKey('filter-category-food'));
    await tester.pumpAndSettle();
    await shot('04-filters-selected');
    await tester.tap(byKey('filter-apply'));
    await tester.pumpAndSettle();
    expect(byKey('movement-filter-chip-categories'), findsOneWidget);
    expect(find.text('Scarpe'), findsNothing);
    await shot('05-filters-applied');
    await tester.tap(byKey('movement-filter-chip-categories'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('movement-filter-chip-flow'));
    await tester.pumpAndSettle();
    expect(byKey('movement-filter-chip-flow'), findsNothing);
    expect(movementCount(), unfiltered);

    // 3 · Notifications in Settings.
    await openTab('Impostazioni');
    final recurringSwitch = byKey('notify-recurring');
    await tester.scrollUntilVisible(
      recurringSwitch,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(recurringSwitch);
    await tester.pumpAndSettle();
    await tester.tap(byKey('notify-reminder'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      byKey('notify-hide-amounts'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      gateway.scheduled.map((p) => p.target).toSet(),
      containsAll({NotificationTarget.recurring, NotificationTarget.quickAdd}),
    );
    expect(gateway.scheduled.any((p) => p.title == 'Affitto domani'), isTrue);
    await tester.scrollUntilVisible(
      find.text('Notifiche'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Notifiche')),
      alignment: .02,
    );
    await shot('06-notification-settings');
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    await shot('07-notification-settings-dark');
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    await tester.pumpAndSettle();

    // A tapped recurrence reminder opens the Recurring tab.
    handleNotificationTap(NotificationTarget.recurring.name);
    await tester.pumpAndSettle();
    expect(find.text('Affitto'), findsWidgets);
    expect(byKey('movements-filter-button'), findsNothing);
    await shot('08-from-recurring-notification');

    // 2 · Widget and quick actions: the deep link used by Android and the
    // channel used by iOS both open the preset sheet.
    await tester.binding.handlePushRoute('/add?flow=income');
    await tester.pumpAndSettle();
    final sheet = find.byType(QuickAddTransactionSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Stipendio')),
      findsWidgets,
    );
    await shot('09-quick-action-income');
    await tester.tap(byKey('quick-add-close'));
    await tester.pumpAndSettle();

    // main() starts this listener; the test pumps RootApp directly.
    await listenForNativeLaunches();
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'pocket_vault/launch',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('open', '/add'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.byType(QuickAddTransactionSheet), findsOneWidget);
    expect(find.text('Esselunga'), findsWidgets);
    await tester.tap(byKey('quick-add-close'));
    await tester.pumpAndSettle();

    // A live camera preview (Android emulator) never settles: pump frames.
    Future<void> frames() async {
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    dispatchLaunchAction(LaunchAction.scanReceipt);
    await frames();
    expect(find.byType(ReceiptCapturePage), findsOneWidget);
    // Closed from code: on Android the camera permission prompt may cover
    // the close button.
    Navigator.of(tester.element(find.byType(ReceiptCapturePage))).pop();
    await frames();
    expect(find.byType(ReceiptCapturePage), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
