import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/input_formatters/capitalize_first_letter_formatter.dart';

void main() {
  const formatter = CapitalizeFirstLetterFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }

  test('capitalizes the first non-whitespace character', () {
    final value = format('  spesa supermercato');

    expect(value.text, '  Spesa supermercato');
    expect(value.selection.baseOffset, value.text.length);
  });

  test('preserves the remaining casing', () {
    expect(format('eBay').text, 'EBay');
    expect(format('Già maiuscola').text, 'Già maiuscola');
  });
}
