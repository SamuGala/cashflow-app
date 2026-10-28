import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/currency/currency_metadata.dart';

void main() {
  test('keypad amounts follow the locale and currency digits', () {
    expect(amountDisplayText(2750, 'EUR', 'it'), '27,50');
    expect(amountDisplayText(2750, 'EUR', 'en'), '27.50');
    expect(amountDisplayText(123456789, 'EUR', 'it'), '1.234.567,89');
    expect(amountDisplayText(0, 'EUR', 'es'), '0,00');
    expect(amountDisplayText(1500, 'JPY', 'it'), '1.500');
    // Input fields still need the parseable form.
    expect(amountInputText(2750, 'EUR'), '27.50');
  });
}
