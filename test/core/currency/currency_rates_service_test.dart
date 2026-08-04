import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/currency/currency_rates_service.dart';

void main() {
  test('cross-currency conversion uses EUR as canonical value', () {
    final conversion = CurrencyRatesService().convert(
      amountMinor: 12000,
      sourceCurrency: 'USD',
      baseCurrency: 'GBP',
      ratesPerEuro: const {'EUR': 1, 'USD': 1.2, 'GBP': .8},
    );

    expect(conversion.eurAmountMicros, 100000000);
    expect(conversion.baseAmountMinor, 8000);
    expect(conversion.originalAmountMinor, 12000);
    expect(conversion.exchangeRateToEur, closeTo(1 / 1.2, .000001));
  });

  test('zero-decimal currencies are rounded using their minor-unit rules', () {
    final conversion = CurrencyRatesService().convert(
      amountMinor: 1000,
      sourceCurrency: 'JPY',
      baseCurrency: 'EUR',
      ratesPerEuro: const {'EUR': 1, 'JPY': 160},
    );

    expect(conversion.baseAmountMinor, 625);
  });
}
