import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/budgets/providers/budget_provider.dart';
import '../../features/goals/providers/savings_goals_provider.dart';
import '../../features/transactions/providers/recurring_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../currency/currency_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/time_filter_provider.dart';
import 'widget_sync_service.dart';

/// Keeps the home-screen widgets in line with the data. "Disponibile" uses
/// the same calculation as Home for the current month, whatever period the
/// app is showing. Watched once by the app root.
final widgetSyncProvider = Provider<void>((ref) {
  // Changes that land together (e.g. a save touching movements and budgets)
  // are sent once, at the end of the current event.
  var queued = false;
  var disposed = false;
  ref.onDispose(() => disposed = true);

  void schedule() {
    if (queued) return;
    queued = true;
    scheduleMicrotask(() {
      queued = false;
      if (disposed) return;
      final transactions = ref.read(transactionProvider).value;
      final recurring = ref.read(recurringProvider).value;
      final budgets = ref.read(budgetProvider).value;
      final contributions = ref.read(savingsGoalContributionsProvider).value;
      if (transactions == null ||
          recurring == null ||
          budgets == null ||
          contributions == null) {
        return;
      }
      final now = DateTime.now();
      final overview = buildBudgetOverview(
        transactions: transactions,
        recurringTransactions: recurring,
        budgets: budgets,
        contributions: contributions,
        timeState: TimeFilterState(filter: TimeFilter.month, month: now),
        now: now,
      );
      unawaited(
        WidgetSyncService().sync(
          transactions: transactions,
          currencyCode: ref.read(currencyProvider).value?.baseCurrency ?? 'EUR',
          locale: ref.read(localeProvider),
          availableMinor: overview.availableToSpendMinor,
        ),
      );
    });
  }

  ref.listen(transactionProvider, (_, _) => schedule());
  ref.listen(recurringProvider, (_, _) => schedule());
  ref.listen(budgetProvider, (_, _) => schedule());
  ref.listen(savingsGoalContributionsProvider, (_, _) => schedule());
  ref.listen(currencyProvider, (_, _) => schedule());
  ref.listen(localeProvider, (_, _) => schedule());
  schedule();
});
