import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionsMonthProvider =
    NotifierProvider<TransactionsMonthNotifier, DateTime>(
        TransactionsMonthNotifier.new);

class TransactionsMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime date) {
    state = DateTime(date.year, date.month);
  }
}