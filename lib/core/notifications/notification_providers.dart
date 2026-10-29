import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/launch_actions.dart';
import '../../features/budgets/providers/budget_provider.dart';
import '../../features/transactions/providers/category_provider.dart';
import '../../features/transactions/providers/recurring_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../l10n/app_localizations.dart';
import '../currency/currency_metadata.dart';
import '../currency/currency_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/category_localization.dart';
import 'notification_gateway.dart';
import 'notification_planner.dart';

const notificationPrefsKey = 'notification_prefs_v1';
const notificationBudgetSentKey = 'notification_budget_sent_v1';

final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => LocalNotificationGateway(),
);

final notificationPreferencesProvider =
    AsyncNotifierProvider<
      NotificationPreferencesNotifier,
      NotificationPreferences
    >(NotificationPreferencesNotifier.new);

class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences.decode(
      prefs.getString(notificationPrefsKey),
    );
  }

  /// Saves [next]. Turning a kind of notification on asks for the system
  /// permission first; returns false, and keeps the old value, if denied.
  Future<bool> save(NotificationPreferences next) async {
    final current = state.value ?? const NotificationPreferences();
    final enabling =
        (next.recurring && !current.recurring) ||
        (next.budget && !current.budget) ||
        (next.reminder && !current.reminder);
    if (enabling) {
      final gateway = ref.read(notificationGatewayProvider);
      await gateway.initialize(handleNotificationTap);
      if (!await gateway.requestPermission()) return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(notificationPrefsKey, next.encode());
    state = AsyncData(next);
    return true;
  }
}

/// Routes a tapped notification through the shared launch actions.
void handleNotificationTap(String? payload) {
  final target = NotificationTarget.values
      .where((value) => value.name == payload)
      .firstOrNull;
  dispatchLaunchAction(switch (target) {
    NotificationTarget.recurring => LaunchAction.openRecurring,
    NotificationTarget.budget => LaunchAction.openHome,
    NotificationTarget.quickAdd => LaunchAction.addExpense,
    null => null,
  });
}

/// Keeps the scheduled notifications in line with the data: rebuilt, with a
/// short debounce, whenever preferences, movements, recurrences or budgets
/// change. Watched once by the app root.
final notificationSyncProvider = Provider<NotificationSync>((ref) {
  final sync = NotificationSync(ref);
  ref.onDispose(sync.dispose);
  for (final listenable in [
    notificationPreferencesProvider,
    transactionProvider,
    recurringProvider,
    budgetProvider,
    categoryProvider,
  ]) {
    ref.listen(listenable, (_, _) => sync.schedule());
  }
  ref.listen(localeProvider, (_, _) => sync.schedule());
  ref.listen(currencyProvider, (_, _) => sync.schedule());
  sync.schedule();
  return sync;
});

class NotificationSync {
  NotificationSync(this._ref, {this.clock = DateTime.now});

  final Ref _ref;
  final DateTime Function() clock;
  Timer? _debounce;
  Future<void>? _running;
  bool _initialized = false;

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _running = (_running ?? Future.value()).then((_) => run());
    });
  }

  void dispose() => _debounce?.cancel();

  @visibleForTesting
  Future<void> run() async {
    final prefs = _ref.read(notificationPreferencesProvider).value;
    final transactions = _ref.read(transactionProvider).value;
    final recurring = _ref.read(recurringProvider).value;
    final budgets = _ref.read(budgetProvider).value;
    final categories = _ref.read(categoryProvider).value;
    if (prefs == null ||
        transactions == null ||
        recurring == null ||
        budgets == null ||
        categories == null) {
      return;
    }
    final gateway = _ref.read(notificationGatewayProvider);
    if (!prefs.anyEnabled) {
      // Nothing to plan; only clear what an earlier session left behind.
      if (_initialized) await gateway.cancelScheduled();
      return;
    }
    if (!_initialized) {
      await gateway.initialize(handleNotificationTap);
      _initialized = true;
    }
    final t = lookupAppLocalizations(_ref.read(localeProvider));
    final locale = _ref.read(localeProvider).toString();
    final currency = _ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    String money(int minor) => formatMoney(minor, currency, locale);
    final names = {for (final c in categories) c.id: categoryName(c.name, t)};
    final now = clock();

    try {
      await gateway.replaceScheduled([
        ...planRecurringReminders(
          prefs: prefs,
          recurring: recurring,
          categoryNames: names,
          money: money,
          t: t,
          now: now,
        ),
        ...planEveningReminders(
          prefs: prefs,
          transactions: transactions,
          t: t,
          now: now,
        ),
      ], channelName: t.notifyChannelName);

      final store = await SharedPreferences.getInstance();
      final monthTag = '${now.year}-${now.month}:';
      final sent = <String>{
        for (final key
            in store.getStringList(notificationBudgetSentKey) ??
                const <String>[])
          if (key.contains(':$monthTag')) key,
      };
      final alerts = budgetAlerts(
        prefs: prefs,
        budgets: budgets,
        transactions: transactions,
        categoryNames: names,
        money: money,
        t: t,
        now: now,
        alreadySent: sent,
      );
      for (final (index, alert) in alerts.indexed) {
        await gateway.showNow(
          id: budgetIdBase + (alert.key.hashCode & 0x3ff) + index,
          title: alert.title,
          body: alert.body,
          payload: NotificationTarget.budget.name,
          channelName: t.notifyChannelName,
        );
        sent.add(alert.key);
      }
      await store.setStringList(notificationBudgetSentKey, sent.toList());
    } catch (error, stack) {
      // A platform hiccup must never break the app; the next change retries.
      debugPrint('Notification sync failed: $error\n$stack');
    }
  }
}
