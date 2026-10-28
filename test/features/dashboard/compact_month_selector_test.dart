import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/dashboard/widgets/revolut_month_selector.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

void main() {
  Widget app(ProviderContainer container, {bool compact = true}) =>
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('it'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Consumer(
              builder: (_, ref, _) => RevolutMonthSelector(
                compact: compact,
                initialDate: ref.watch(timeFilterProvider).month,
              ),
            ),
          ),
        ),
      );

  testWidgets('compact month arrows cross years in both directions', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(timeFilterProvider.notifier).setMonth(DateTime(2026, 12));
    await tester.pumpWidget(app(container));
    await tester.pumpAndSettle();
    expect(find.text('Dicembre 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dashboard-next-month')));
    await tester.pumpAndSettle();
    expect(find.text('Gennaio 2027'), findsOneWidget);
    expect(container.read(timeFilterProvider).month, DateTime(2027, 1));
    await tester.tap(find.byKey(const ValueKey('dashboard-previous-month')));
    await tester.pumpAndSettle();
    expect(find.text('Dicembre 2026'), findsOneWidget);
    expect(container.read(timeFilterProvider).month, DateTime(2026, 12));
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy year selection updates the shared filter', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final now = DateTime.now();
    container.read(timeFilterProvider.notifier).setMonth(DateTime(now.year, 6));
    await tester.pumpWidget(app(container, compact: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${now.year}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${now.year - 1}'));
    await tester.pumpAndSettle();
    expect(container.read(timeFilterProvider).month, DateTime(now.year - 1, 6));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'external month sync does not publish intermediate pager months',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(timeFilterProvider.notifier).setMonth(DateTime(2026, 12));
      await tester.pumpWidget(app(container, compact: false));
      await tester.pumpAndSettle();
      final updates = <DateTime>[];
      final sub = container.listen(
        timeFilterProvider,
        (_, state) => updates.add(state.month),
      );
      addTearDown(sub.close);
      container.read(timeFilterProvider.notifier).setMonth(DateTime(2025, 1));
      await tester.pumpAndSettle();
      expect(updates, [DateTime(2025, 1)]);
      expect(container.read(timeFilterProvider).month, DateTime(2025, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('compact month follows external filter updates without a pager', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(app(container));
    await tester.pumpAndSettle();
    container.read(timeFilterProvider.notifier).setMonth(DateTime(2028, 2));
    await tester.pumpAndSettle();
    expect(find.text('Febbraio 2028'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
