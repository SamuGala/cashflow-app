import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeFilter { total, month, period }

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
    state = state.copyWith(filter: filter);
  }

  void setMonth(DateTime month) {
    state = state.copyWith(month: month);
  }

  void setPeriod(DateTime start, DateTime end) {
    state = state.copyWith(filter: TimeFilter.period, start: start, end: end);
  }
}

final timeFilterProvider =
    NotifierProvider<TimeFilterNotifier, TimeFilterState>(
      TimeFilterNotifier.new,
    );
