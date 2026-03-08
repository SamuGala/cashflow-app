import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setMonth(DateTime month) {
    state = month;
  }
}