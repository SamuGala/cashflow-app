import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeFilter { total, month, period }

class TimeWindow {
  final DateTime start;
  final DateTime end;

  const TimeWindow({required this.start, required this.end});
}

DateTime startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime endOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999, 999);

class TimeFilterState {
  final TimeFilter filter;
  final DateTime month;
  final DateTime? start;
  final DateTime? end;

  const TimeFilterState({
    required this.filter,
    required this.month,
    this.start,
    this.end,
  });

  TimeFilterState copyWith({
    TimeFilter? filter,
    DateTime? month,
    DateTime? start,
    DateTime? end,
  }) {
    return TimeFilterState(
      filter: filter ?? this.filter,
      month: month ?? this.month,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class TimeFilterNotifier extends Notifier<TimeFilterState> {
  @override
  TimeFilterState build() {
    return TimeFilterState(filter: TimeFilter.month, month: DateTime.now());
  }

  void setFilter(TimeFilter filter) {
    if (filter == TimeFilter.period &&
        (state.start == null || state.end == null)) {
      final now = DateTime.now();
      state = state.copyWith(
        filter: filter,
        start: DateTime(now.year, now.month),
        end: now,
      );
      return;
    }
    state = state.copyWith(filter: filter);
  }

  void setMonth(DateTime month) {
    state = state.copyWith(month: month);
  }

  void setPeriod(DateTime start, DateTime end) {
    final orderedStart = start.isAfter(end) ? end : start;
    final orderedEnd = start.isAfter(end) ? start : end;
    state = state.copyWith(
      filter: TimeFilter.period,
      start: orderedStart,
      end: orderedEnd,
    );
  }
}

final timeFilterProvider =
    NotifierProvider<TimeFilterNotifier, TimeFilterState>(
      TimeFilterNotifier.new,
    );

TimeWindow? selectedTimeWindow(TimeFilterState state) {
  return switch (state.filter) {
    TimeFilter.total => null,
    TimeFilter.month => TimeWindow(
      start: DateTime(state.month.year, state.month.month),
      end: endOfDay(DateTime(state.month.year, state.month.month + 1, 0)),
    ),
    TimeFilter.period when state.start != null && state.end != null =>
      TimeWindow(start: startOfDay(state.start!), end: endOfDay(state.end!)),
    TimeFilter.period => null,
  };
}

bool isInSelectedTimeWindow(DateTime date, TimeFilterState state) {
  final window = selectedTimeWindow(state);
  if (window == null) return true;
  return !date.isBefore(window.start) && !date.isAfter(window.end);
}
