import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/features/transactions/domain/recurrence_calculator.dart';

void main() {
  test('monthly recurrence clamps the day to the end of short months', () {
    final occurrences = recurringOccurrences(
      schedule: RecurrenceSchedule(
        startDate: DateTime(2026, 1, 31),
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        dayOfMonth: 31,
      ),
      through: DateTime(2026, 3, 31),
    );

    expect(occurrences, [
      DateTime(2026, 1, 31),
      DateTime(2026, 2, 28),
      DateTime(2026, 3, 31),
    ]);
  });

  test('weekly recurrence respects interval, weekday and end date', () {
    final occurrences = recurringOccurrences(
      schedule: RecurrenceSchedule(
        startDate: DateTime(2026, 7, 1),
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        dayOfMonth: 1,
        dayOfWeek: DateTime.friday,
        endDate: DateTime(2026, 7, 31),
      ),
      through: DateTime(2026, 9, 1),
    );

    expect(occurrences, [
      DateTime(2026, 7, 3),
      DateTime(2026, 7, 17),
      DateTime(2026, 7, 31),
    ]);
  });

  test('yearly recurrence preserves a valid leap-day schedule', () {
    final occurrences = recurringOccurrences(
      schedule: RecurrenceSchedule(
        startDate: DateTime(2024, 2, 29),
        frequency: RecurrenceFrequency.yearly,
        interval: 1,
        dayOfMonth: 29,
        monthOfYear: 2,
      ),
      through: DateTime(2028, 3),
    );

    expect(occurrences, [
      DateTime(2024, 2, 29),
      DateTime(2025, 2, 28),
      DateTime(2026, 2, 28),
      DateTime(2027, 2, 28),
      DateTime(2028, 2, 29),
    ]);
  });

  test('daily and weekly steps stay on calendar days across DST changes', () {
    for (final start in [DateTime(2026, 10, 19), DateTime(2027, 3, 22)]) {
      final daily = recurringOccurrences(
        schedule: RecurrenceSchedule(
          startDate: start,
          frequency: RecurrenceFrequency.daily,
          interval: 1,
          dayOfMonth: start.day,
        ),
        through: DateTime(start.year, start.month, start.day + 20),
      );
      expect(daily, [
        for (var day = 0; day <= 20; day++)
          DateTime(start.year, start.month, start.day + day),
      ]);

      final weekly = recurringOccurrences(
        schedule: RecurrenceSchedule(
          startDate: start,
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          dayOfMonth: start.day,
          dayOfWeek: DateTime.monday,
        ),
        through: DateTime(start.year, start.month, start.day + 28),
      );
      expect(weekly, hasLength(5));
      for (final date in weekly) {
        expect(date.weekday, DateTime.monday);
        expect(date, dateOnly(date));
      }
    }
  });
}
