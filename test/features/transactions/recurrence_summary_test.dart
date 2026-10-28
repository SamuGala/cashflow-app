import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/features/transactions/presentation/recurring_list.dart';
import 'package:pocket_vault/l10n/app_localizations_en.dart';
import 'package:pocket_vault/l10n/app_localizations_it.dart';

RecurringTransaction _row(
  String frequency, {
  int interval = 1,
  int? dayOfWeek,
  int? monthOfYear,
}) => RecurringTransaction(
  id: frequency,
  amountCents: 100,
  isIncome: false,
  categoryId: 'bills',
  dayOfMonth: 15,
  startDate: DateTime(2026, 10, 15),
  active: true,
  frequency: frequency,
  interval: interval,
  dayOfWeek: dayOfWeek,
  monthOfYear: monthOfYear,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
    await initializeDateFormatting('en');
  });

  test('describes every frequency, not only monthly ones', () {
    final it = AppLocalizationsIt();
    expect(recurrenceSummary(_row('daily'), it, 'it'), 'Ogni giorno');
    expect(
      recurrenceSummary(_row('daily', interval: 3), it, 'it'),
      'Ogni 3 giorni',
    );
    expect(
      recurrenceSummary(_row('weekly', dayOfWeek: DateTime.monday), it, 'it'),
      'Ogni settimana · lunedì',
    );
    expect(
      recurrenceSummary(
        _row('weekly', interval: 2, dayOfWeek: DateTime.sunday),
        it,
        'it',
      ),
      'Ogni 2 settimane · domenica',
    );
    expect(recurrenceSummary(_row('monthly'), it, 'it'), 'Ogni mese · 15');
    expect(
      recurrenceSummary(_row('yearly', monthOfYear: 11), it, 'it'),
      'Ogni anno · 15 nov',
    );
    expect(
      recurrenceSummary(
        _row('monthly', interval: 2),
        AppLocalizationsEn(),
        'en',
      ),
      'Every 2 months · 15',
    );
  });
}
