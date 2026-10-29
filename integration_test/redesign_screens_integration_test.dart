import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/core/database/database_provider.dart';
import 'package:pocket_vault/core/providers/balance_visibility_provider.dart';
import 'package:pocket_vault/core/receipts/receipt_scan_review_sheet.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/core/security/auth_provider.dart';
import 'package:pocket_vault/features/goals/presentation/savings_goals_card.dart';
import 'package:pocket_vault/features/goals/providers/savings_goals_provider.dart';
import 'package:pocket_vault/features/settings/presentation/providers/theme_provider.dart';
import 'package:pocket_vault/features/transactions/providers/category_provider.dart';
import 'package:pocket_vault/features/transactions/presentation/add_transaction_page.dart';
import 'package:pocket_vault/features/transactions/presentation/edit_recurring_sheet.dart';
import 'package:pocket_vault/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const capture = bool.fromEnvironment('CAPTURE_REDESIGN');

  testWidgets('redesigned Home, Movements and entry flows keep their actions', (
    tester,
  ) async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    SharedPreferences.setMockInitialValues({
      'locale': 'it',
      'theme_mode_v1': 'light',
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
    final day = now.day;
    DateTime on(int offset) =>
        DateTime(month.year, month.month, (day - offset).clamp(1, day), 12);
    for (final entry in [
      ('salary', 'salary', 280000, true, 0, 'Stipendio'),
      ('groceries-1', 'groceries', 6840, false, 0, 'Esselunga'),
      ('food-1', 'food', 2750, false, 0, 'Pizza con amici'),
      ('transport-1', 'transport', 3500, false, 1, 'Abbonamento bus'),
      ('shopping-1', 'shopping', 12900, false, 1, 'Scarpe'),
      ('bills-1', 'bills', 8400, false, 2, 'Luce e gas'),
      ('entertainment-1', 'entertainment', 1599, false, 2, 'Cinema'),
      ('health-1', 'health', 4200, false, 3, 'Farmacia'),
      ('gift-1', 'gift', 5000, true, 3, 'Regalo nonna'),
    ]) {
      await database.insertTransaction(
        TransactionsCompanion.insert(
          id: entry.$1,
          categoryId: entry.$2,
          amountCents: entry.$3,
          isIncome: entry.$4,
          date: on(entry.$5),
          note: Value(entry.$6),
        ),
      );
    }
    for (final recurring in [
      ('gym', 'health', 4500, false, 15),
      ('netflix', 'entertainment', 1399, false, 22),
      ('rent', 'rent', 75000, false, 1),
    ]) {
      await database
          .into(database.recurringTransactions)
          .insert(
            RecurringTransaction(
              id: recurring.$1,
              amountCents: recurring.$3,
              isIncome: recurring.$4,
              categoryId: recurring.$2,
              dayOfMonth: recurring.$5,
              startDate: DateTime(month.year, month.month + 1),
              active: recurring.$1 != 'netflix',
              frequency: 'monthly',
              interval: 1,
            ),
          );
    }
    final goals = container.read(savingsGoalsProvider.notifier);
    await container.read(savingsGoalsProvider.future);
    await goals.addGoal(name: 'Vacanza in Giappone', targetAmountMinor: 300000);
    await goals.addGoal(name: 'Fondo emergenze', targetAmountMinor: 500000);
    final seededGoals = await container.read(savingsGoalsProvider.future);
    await goals.contribute(
      seededGoals.firstWhere((g) => g.name.startsWith('Vacanza')).id,
      126000,
    );
    await goals.contribute(
      seededGoals.firstWhere((g) => g.name.startsWith('Fondo')).id,
      90000,
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
      if (capture) await binding.takeScreenshot('redesign-$name');
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

    // Home: compact header with the shared period control.
    expect(find.byKey(const ValueKey('stats-global-period')), findsOneWidget);
    await shot('01-home-light');
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await shot('02-home-categories');
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    await shot('03-home-dark');
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    await tester.pumpAndSettle();

    // Quick add (Aurora Bagliore): keypad, category carousel, note, date,
    // repeat, a brand-new category and the real save.
    await tester.tap(find.byKey(const ValueKey('add-transaction-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('flow-switch-expense')));
    await shot('04-quick-add');
    for (final key in ['2', '7', '5', '0']) {
      await tester.tap(find.byKey(ValueKey('quick-amount-key-$key')));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await shot('05-quick-add-amount');
    final carousel = find.byKey(const ValueKey('quick-category-carousel'));
    final newTile = find.byKey(const ValueKey('quick-category-new'));
    for (var i = 0; i < 30 && newTile.evaluate().isEmpty; i++) {
      await tester.drag(carousel, const Offset(-160, 0));
      await tester.pumpAndSettle();
    }
    await tester.drag(carousel, const Offset(-400, 0));
    await shot('06-quick-add-carousel-end');
    expect(find.byKey(const ValueKey('quick-category-new')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quick-category-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Palestra');
    await shot('07-quick-add-new-category');
    await tester.tap(find.text('Salva categoria'));
    await tester.pumpAndSettle();
    final created = (await database.select(database.categories).get())
        .singleWhere((row) => row.name == 'Palestra');
    expect(
      find.byKey(ValueKey('quick-category-${created.id}')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('quick-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quick-note-field')),
      'Abbonamento palestra',
    );
    await shot('08-quick-add-note');
    await tester.tap(find.byKey(const ValueKey('quick-note-done')));
    await tester.pumpAndSettle();
    expect(find.text('Abbonamento palestra'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quick-date')));
    await tester.pumpAndSettle();
    await shot('09-quick-add-date');
    await tester.tap(find.text('Annulla').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-repeat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-recurring-switch')));
    await tester.pumpAndSettle();
    await shot('10-quick-add-repeat');
    await tester.tap(find.byKey(const ValueKey('quick-recurring-done')));
    await tester.pumpAndSettle();
    await shot('11-quick-add-filled');
    await tester.tap(find.byKey(const ValueKey('quick-save')));
    await tester.pump(const Duration(milliseconds: 260));
    if (capture) await binding.takeScreenshot('redesign-12-quick-add-saved');
    await tester.pumpAndSettle();
    final saved = (await database.select(database.recurringTransactions).get())
        .singleWhere((row) => row.note == 'Abbonamento palestra');
    expect(saved.categoryId, created.id);
    expect(saved.amountCents, 2750);
    expect(saved.frequency, 'monthly');
    expect(saved.dayOfMonth, now.day);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Movements: grouped days, summary, swipe actions.
    await openTab('Movimenti');
    await shot('13-movements');
    await tester.drag(
      find.byKey(const ValueKey('food-1')),
      const Offset(-500, 0),
    );
    await shot('14-delete-dialog');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Annulla'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-1')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('food-1')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionPage), findsOneWidget);
    await shot('15-edit-transaction');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    await shot('16-movements-dark');
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    await tester.pumpAndSettle();

    // Recurring list, actions and edit sheet.
    await tester.tap(find.text('Ricorrenti'));
    await shot('17-recurring');
    await tester.drag(find.byKey(const ValueKey('gym')), const Offset(500, 0));
    await shot('18-recurring-actions');
    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();
    expect(find.byType(EditRecurringSheet), findsOneWidget);
    await shot('19-edit-recurring');
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();
    expect(find.byType(EditRecurringSheet), findsNothing);

    // Statistics keeps the category colors on its icons.
    await openTab('Statistiche');
    await shot('20-stats-overview');
    await tester.tap(find.byKey(const ValueKey('stats-tab-1')));
    await tester.pumpAndSettle();
    await shot('21-stats-donut');
    await tester.tap(find.byKey(const ValueKey('stats-category-groceries')));
    await tester.pump(const Duration(milliseconds: 160));
    if (capture) await binding.takeScreenshot('redesign-22-stats-selecting');
    await shot('23-stats-category-detail');
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await shot('24-stats-donut-selected');
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('stats-forecast')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stats-forecast')));
    await shot('25-stats-forecast');
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();

    // Savings goals on Home and their management sheet.
    await openTab('Home');
    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await shot('26-home-goals');
    await tester.tap(find.text('Gestisci'));
    await tester.pumpAndSettle();
    expect(find.byType(SavingsGoalsSheet), findsOneWidget);
    await shot('27-goals-sheet');
    await tester.tap(find.text('Accantona').first);
    await shot('28-goals-amount-dialog');
    await tester.tap(find.text('Annulla').last);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();

    // Receipt review after a scan.
    final receipt = await _receiptImage();
    final categories = await container.read(categoryProvider.future);
    final review = showReceiptScanReview(
      context: tester.element(find.byType(Scaffold).first),
      draft: ReceiptScanDraft(
        imagePath: receipt,
        extraction: ReceiptExtraction(
          amountMinor: 6840,
          currencyCode: 'EUR',
          date: now,
          merchant: 'Esselunga',
          categoryId: 'groceries',
          confidence: .92,
          recognizedText: '',
        ),
      ),
      categories: categories,
    );
    await shot('29-receipt-review');
    await tester.tap(find.text('Solo allegato'));
    await tester.pumpAndSettle();
    expect((await review)?.decision, ReceiptScanDecision.attachOnly);

    // Settings in the Vault style, both themes.
    await openTab('Impostazioni');
    await shot('30-settings');
    await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
    await shot('31-settings-bottom');
    await tester.tap(find.byKey(const ValueKey('settings-delete-all')));
    await shot('32-settings-delete-all');
    await tester.tap(find.text('Annulla').last);
    await tester.pumpAndSettle();
    expect((await database.getAllTransactions()), isNotEmpty);
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    await shot('33-settings-dark');
    await openTab('Home');
    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await shot('34-home-goals-dark');
    await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

/// Paints a simple paper receipt so the review sheet shows a real image.
Future<String> _receiptImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(900, 340);
  canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9E4DA));
  final paper = Paint()..color = Colors.white;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(250, 20, 400, 360),
      const Radius.circular(8),
    ),
    paper,
  );
  final ink = Paint()..color = const Color(0xFFB9BEC8);
  for (var i = 0; i < 9; i++) {
    final width = i == 0 ? 180.0 : (i.isEven ? 300.0 : 240.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(290, 50.0 + i * 30, width, 10),
        const Radius.circular(5),
      ),
      ink,
    );
  }
  final image = await recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${(await getTemporaryDirectory()).path}/receipt-demo.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file.path;
}
