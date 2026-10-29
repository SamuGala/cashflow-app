import 'dart:convert';

import '../../features/transactions/domain/recurrence_calculator.dart';
import '../../features/transactions/domain/transaction.dart';
import '../../l10n/app_localizations.dart';
import '../database/app_database.dart';

/// What the user chose in Settings › Notifications. Everything is off until
/// the user turns it on.
class NotificationPreferences {
  final bool recurring;
  final int recurringDaysBefore;
  final bool budget;
  final int budgetThreshold;
  final bool reminder;
  final int reminderHour;
  final int reminderMinute;
  final bool hideAmounts;

  const NotificationPreferences({
    this.recurring = false,
    this.recurringDaysBefore = 1,
    this.budget = false,
    this.budgetThreshold = 80,
    this.reminder = false,
    this.reminderHour = 21,
    this.reminderMinute = 0,
    this.hideAmounts = false,
  });

  bool get anyEnabled => recurring || budget || reminder;

  NotificationPreferences copyWith({
    bool? recurring,
    int? recurringDaysBefore,
    bool? budget,
    int? budgetThreshold,
    bool? reminder,
    int? reminderHour,
    int? reminderMinute,
    bool? hideAmounts,
  }) => NotificationPreferences(
    recurring: recurring ?? this.recurring,
    recurringDaysBefore: recurringDaysBefore ?? this.recurringDaysBefore,
    budget: budget ?? this.budget,
    budgetThreshold: budgetThreshold ?? this.budgetThreshold,
    reminder: reminder ?? this.reminder,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    hideAmounts: hideAmounts ?? this.hideAmounts,
  );

  String encode() => jsonEncode({
    'recurring': recurring,
    'recurringDaysBefore': recurringDaysBefore,
    'budget': budget,
    'budgetThreshold': budgetThreshold,
    'reminder': reminder,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'hideAmounts': hideAmounts,
  });

  /// Unknown or malformed values fall back to the defaults.
  static NotificationPreferences decode(String? raw) {
    const defaults = NotificationPreferences();
    if (raw == null) return defaults;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      bool flag(String key, bool fallback) =>
          json[key] is bool ? json[key] as bool : fallback;
      int number(String key, int fallback, int min, int max) =>
          json[key] is int ? (json[key] as int).clamp(min, max) : fallback;
      return NotificationPreferences(
        recurring: flag('recurring', defaults.recurring),
        recurringDaysBefore: number(
          'recurringDaysBefore',
          defaults.recurringDaysBefore,
          0,
          3,
        ),
        budget: flag('budget', defaults.budget),
        budgetThreshold: number(
          'budgetThreshold',
          defaults.budgetThreshold,
          50,
          100,
        ),
        reminder: flag('reminder', defaults.reminder),
        reminderHour: number('reminderHour', defaults.reminderHour, 0, 23),
        reminderMinute: number(
          'reminderMinute',
          defaults.reminderMinute,
          0,
          59,
        ),
        hideAmounts: flag('hideAmounts', defaults.hideAmounts),
      );
    } catch (_) {
      return defaults;
    }
  }
}

/// Where a tapped notification leads.
enum NotificationTarget { recurring, budget, quickAdd }

class PlannedNotification {
  final int id;
  final DateTime at;
  final String title;
  final String body;
  final NotificationTarget target;

  const PlannedNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.target,
  });

  String get payload => target.name;
}

/// A budget alert shown right away, sent at most once per [key].
class BudgetAlert {
  final String key;
  final String title;
  final String body;

  const BudgetAlert({
    required this.key,
    required this.title,
    required this.body,
  });
}

const recurringIdBase = 1000;
const reminderIdBase = 2000;
const budgetIdBase = 3000;

/// iOS keeps at most 64 pending requests per app; stay well below it.
const maxRecurringReminders = 40;

/// Reminders for active recurrences in the next [horizonDays], at 9:00 on
/// the day chosen by the user.
List<PlannedNotification> planRecurringReminders({
  required NotificationPreferences prefs,
  required Iterable<RecurringTransaction> recurring,
  required Map<String, String> categoryNames,
  required String Function(int minor) money,
  required AppLocalizations t,
  required DateTime now,
  int horizonDays = 45,
}) {
  if (!prefs.recurring) return const [];
  final today = dateOnly(now);
  final through = DateTime(today.year, today.month, today.day + horizonDays);
  final planned = <(DateTime, RecurringTransaction, DateTime)>[];
  for (final row in recurring.where((row) => row.active)) {
    final schedule = RecurrenceSchedule(
      startDate: row.startDate,
      frequency: recurrenceFrequencyFromName(row.frequency),
      interval: row.interval < 1 ? 1 : row.interval,
      dayOfMonth: row.dayOfMonth,
      dayOfWeek: row.dayOfWeek,
      monthOfYear: row.monthOfYear,
      endDate: row.endDate,
    );
    final occurrences = recurringOccurrences(
      schedule: schedule,
      after: DateTime(today.year, today.month, today.day - 1),
      through: through,
      limit: 12,
    );
    for (final occurrence in occurrences) {
      final remindDay = DateTime(
        occurrence.year,
        occurrence.month,
        occurrence.day - prefs.recurringDaysBefore,
        9,
      );
      if (!remindDay.isAfter(now)) continue;
      planned.add((remindDay, row, occurrence));
    }
  }
  planned.sort((a, b) => a.$1.compareTo(b.$1));
  final result = <PlannedNotification>[];
  for (final (at, row, occurrence) in planned.take(maxRecurringReminders)) {
    final note = row.note?.trim() ?? '';
    final name = note.isNotEmpty
        ? note
        : categoryNames[row.categoryId] ?? row.categoryId;
    final days = dateOnly(occurrence).difference(dateOnly(at)).inDays;
    final amount = money(row.amountCents);
    result.add(
      PlannedNotification(
        id: recurringIdBase + result.length,
        at: at,
        title: switch (days) {
          0 => t.notifyRecurringTitleToday(name),
          1 => t.notifyRecurringTitleTomorrow(name),
          _ => t.notifyRecurringTitleIn(name, days),
        },
        body: prefs.hideAmounts
            ? t.notifyRecurringHiddenBody
            : row.isIncome
            ? t.notifyRecurringIncomeBody(amount)
            : t.notifyRecurringExpenseBody(amount),
        target: NotificationTarget.recurring,
      ),
    );
  }
  return result;
}

/// Evening reminders for the next [days] days. Today's is skipped once
/// something has been logged today; the plan is rebuilt on every change.
List<PlannedNotification> planEveningReminders({
  required NotificationPreferences prefs,
  required Iterable<TransactionModel> transactions,
  required AppLocalizations t,
  required DateTime now,
  int days = 7,
}) {
  if (!prefs.reminder) return const [];
  final today = dateOnly(now);
  final loggedToday = transactions.any(
    (tx) => tx.recurringSourceId == null && dateOnly(tx.createdAt) == today,
  );
  final result = <PlannedNotification>[];
  for (var offset = 0; offset < days; offset++) {
    if (offset == 0 && loggedToday) continue;
    final at = DateTime(
      today.year,
      today.month,
      today.day + offset,
      prefs.reminderHour,
      prefs.reminderMinute,
    );
    if (!at.isAfter(now)) continue;
    result.add(
      PlannedNotification(
        id: reminderIdBase + offset,
        at: at,
        title: t.notifyReminderTitle,
        body: t.notifyReminderBody,
        target: NotificationTarget.quickAdd,
      ),
    );
  }
  return result;
}

/// Budgets of the current month that reached the threshold or the limit.
/// Keys already in [alreadySent] are skipped, so each alert fires once.
List<BudgetAlert> budgetAlerts({
  required NotificationPreferences prefs,
  required Iterable<BudgetRow> budgets,
  required Iterable<TransactionModel> transactions,
  required Map<String, String> categoryNames,
  required String Function(int minor) money,
  required AppLocalizations t,
  required DateTime now,
  required Set<String> alreadySent,
}) {
  if (!prefs.budget) return const [];
  final month = DateTime(now.year, now.month);
  final spentByCategory = <String, int>{};
  for (final tx in transactions) {
    if (tx.isIncome || tx.date.year != now.year || tx.date.month != now.month) {
      continue;
    }
    spentByCategory[tx.categoryId] =
        (spentByCategory[tx.categoryId] ?? 0) + tx.amountCents;
  }
  final alerts = <BudgetAlert>[];
  for (final budget in budgets.where((b) => b.active && b.amountMinor > 0)) {
    final spent = spentByCategory[budget.categoryId] ?? 0;
    final percent = (spent * 100 / budget.amountMinor).floor();
    final over = spent > budget.amountMinor;
    if (!over && percent < prefs.budgetThreshold) continue;
    final level = over ? 'over' : '${prefs.budgetThreshold}';
    final key = '${budget.id}:${month.year}-${month.month}:$level';
    if (alreadySent.contains(key)) continue;
    final name = categoryNames[budget.categoryId] ?? budget.categoryId;
    alerts.add(
      BudgetAlert(
        key: key,
        title: over
            ? t.notifyBudgetOverTitle(name)
            : t.notifyBudgetTitle(name, percent),
        body: prefs.hideAmounts
            ? t.notifyBudgetHiddenBody
            : t.notifyBudgetBody(money(spent), money(budget.amountMinor)),
      ),
    );
  }
  return alerts;
}
