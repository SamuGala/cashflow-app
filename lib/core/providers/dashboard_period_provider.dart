import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardPeriod {
  total,
  month
}

final dashboardPeriodProvider =
    NotifierProvider<DashboardPeriodNotifier, DashboardPeriod>(
        DashboardPeriodNotifier.new);

class DashboardPeriodNotifier extends Notifier<DashboardPeriod> {
  @override
  DashboardPeriod build() => DashboardPeriod.month;

  void setPeriod(DashboardPeriod period) {
    state = period;
  }
}