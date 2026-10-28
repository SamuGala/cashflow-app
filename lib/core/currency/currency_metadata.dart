import 'dart:math' as math;

import 'package:intl/intl.dart';

const supportedCurrencyCodes = <String>[
  'EUR',
  'USD',
  'GBP',
  'CHF',
  'JPY',
  'AUD',
  'CAD',
  'CNY',
  'CZK',
  'DKK',
  'HUF',
  'NOK',
  'PLN',
  'RON',
  'SEK',
  'BGN',
  'BRL',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'KRW',
  'MXN',
  'MYR',
  'NZD',
  'PHP',
  'SGD',
  'THB',
  'TRY',
  'ZAR',
];

int currencyDecimalDigits(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'JPY':
    case 'KRW':
    case 'IDR':
      return 0;
    default:
      return 2;
  }
}

int currencyScale(String currencyCode) {
  return math.pow(10, currencyDecimalDigits(currencyCode)).toInt();
}

double minorToMajor(int amountMinor, String currencyCode) {
  return amountMinor / currencyScale(currencyCode);
}

int majorToMinor(double amount, String currencyCode) {
  return (amount * currencyScale(currencyCode)).round();
}

String formatMoney(
  int amountMinor,
  String currencyCode,
  String locale, {
  bool compact = false,
}) {
  final major = minorToMajor(amountMinor, currencyCode);
  final formatter = compact
      ? NumberFormat.compactCurrency(
          locale: locale,
          name: currencyCode,
          decimalDigits: currencyDecimalDigits(currencyCode),
        )
      : NumberFormat.simpleCurrency(
          locale: locale,
          name: currencyCode,
          decimalDigits: currencyDecimalDigits(currencyCode),
        );
  return formatter.format(major);
}

String amountInputText(int amountMinor, String currencyCode) {
  final digits = currencyDecimalDigits(currencyCode);
  return minorToMajor(amountMinor, currencyCode).toStringAsFixed(digits);
}

/// Locale-aware amount for keypad displays; not meant to be parsed back.
String amountDisplayText(int amountMinor, String currencyCode, String locale) {
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: currencyDecimalDigits(currencyCode),
  ).format(minorToMajor(amountMinor, currencyCode));
}
