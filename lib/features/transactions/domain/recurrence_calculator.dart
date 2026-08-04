enum RecurrenceFrequency { daily, weekly, monthly, yearly }

RecurrenceFrequency recurrenceFrequencyFromName(String value) {
  return RecurrenceFrequency.values.firstWhere(
    (frequency) => frequency.name == value,
    orElse: () => RecurrenceFrequency.monthly,
  );
}

class RecurrenceSchedule {
  final DateTime startDate;
  final RecurrenceFrequency frequency;
  final int interval;
  final int dayOfMonth;
  final int? dayOfWeek;
  final int? monthOfYear;
  final DateTime? endDate;

  const RecurrenceSchedule({
    required this.startDate,
    required this.frequency,
    required this.interval,
    required this.dayOfMonth,
    this.dayOfWeek,
    this.monthOfYear,
    this.endDate,
  });
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

List<DateTime> recurringOccurrences({
  required RecurrenceSchedule schedule,
  required DateTime through,
  DateTime? after,
  int limit = 5000,
}) {
  if (schedule.interval < 1) {
    throw ArgumentError.value(schedule.interval, 'interval');
  }

  final start = dateOnly(schedule.startDate);
  final inclusiveEnd = dateOnly(through);
  final scheduleEnd = schedule.endDate == null
      ? inclusiveEnd
      : _earlier(inclusiveEnd, dateOnly(schedule.endDate!));
  final exclusiveStart = after == null ? null : dateOnly(after);
  final occurrences = <DateTime>[];

  void addIfEligible(DateTime candidate) {
    if (candidate.isBefore(start) || candidate.isAfter(scheduleEnd)) return;
    if (exclusiveStart != null && !candidate.isAfter(exclusiveStart)) return;
    occurrences.add(candidate);
  }

  switch (schedule.frequency) {
    case RecurrenceFrequency.daily:
      var candidate = start;
      while (!candidate.isAfter(scheduleEnd) && occurrences.length < limit) {
        addIfEligible(candidate);
        candidate = candidate.add(Duration(days: schedule.interval));
      }
      break;

    case RecurrenceFrequency.weekly:
      final weekday = schedule.dayOfWeek ?? start.weekday;
      var candidate = start.add(
        Duration(days: (weekday - start.weekday + DateTime.daysPerWeek) % 7),
      );
      while (!candidate.isAfter(scheduleEnd) && occurrences.length < limit) {
        addIfEligible(candidate);
        candidate = candidate.add(Duration(days: 7 * schedule.interval));
      }
      break;

    case RecurrenceFrequency.monthly:
      var monthIndex = 0;
      while (occurrences.length < limit) {
        final month = DateTime(
          start.year,
          start.month + (monthIndex * schedule.interval),
        );
        if (month.isAfter(DateTime(scheduleEnd.year, scheduleEnd.month))) break;
        addIfEligible(
          _dateClamped(month.year, month.month, schedule.dayOfMonth),
        );
        monthIndex++;
      }
      break;

    case RecurrenceFrequency.yearly:
      var yearOffset = 0;
      while (occurrences.length < limit) {
        final year = start.year + (yearOffset * schedule.interval);
        if (year > scheduleEnd.year) break;
        addIfEligible(
          _dateClamped(
            year,
            schedule.monthOfYear ?? start.month,
            schedule.dayOfMonth,
          ),
        );
        yearOffset++;
      }
      break;
  }

  return occurrences;
}

DateTime? nextRecurringOccurrence({
  required RecurrenceSchedule schedule,
  required DateTime after,
  int horizonYears = 20,
}) {
  final occurrences = recurringOccurrences(
    schedule: schedule,
    after: after,
    through: DateTime(after.year + horizonYears, 12, 31),
    limit: 1,
  );
  return occurrences.firstOrNull;
}

DateTime _dateClamped(int year, int month, int day) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day.clamp(1, daysInMonth));
}

DateTime _earlier(DateTime first, DateTime second) {
  return first.isBefore(second) ? first : second;
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
