import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/features/transactions/domain/category.dart';

void main() {
  const categories = [
    Category(
      id: 'groceries',
      name: 'groceries',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
    Category(
      id: 'food',
      name: 'food',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
    Category(
      id: 'transport',
      name: 'transport',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
    Category(
      id: 'education',
      name: 'education',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
    Category(
      id: 'other',
      name: 'other',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
    Category(
      id: 'salary',
      name: 'salary',
      isIncome: true,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
  ];

  ReceiptOcrLine line(String text, [double confidence = .95]) {
    return ReceiptOcrLine(
      text: text,
      confidence: confidence,
      x: 0,
      y: 0,
      width: 1,
      height: .05,
    );
  }

  test('extracts Italian total instead of subtotal cash or change', () {
    final result = ReceiptParser.parse(
      lines: [
        line('ESSELUNGA'),
        line('Via Roma 10 Milano'),
        line('DATA 31/07|2026 12:45'),
        line('SUBTOTALE 21,90 €'),
        line('IVA 2,10 €'),
        line('TOTALE EUR 24,00'),
        line('CONTANTI 30,00 €'),
        line('RESTO 6,00 €'),
      ],
      categories: categories,
      fallbackCurrency: 'USD',
      now: DateTime(2026, 7, 31),
    );

    expect(result.amountMinor, 2400);
    expect(result.currencyCode, 'EUR');
    expect(result.date, DateTime(2026, 7, 31));
    expect(result.merchant, 'Esselunga');
    expect(result.categoryId, 'groceries');
    expect(result.confidence, greaterThan(.8));
  });

  test('extracts Spanish receipt and dollar currency', () {
    final result = ReceiptParser.parse(
      lines: [
        line('RESTAURANTE SOL'),
        line('Fecha 30-07-2026'),
        line(r'Subtotal $ 20.00'),
        line(r'TOTAL $ 23.50'),
        line(r'Cambio $ 6.50'),
      ],
      categories: categories,
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.amountMinor, 2350);
    expect(result.currencyCode, 'USD');
    expect(result.date, DateTime(2026, 7, 30));
    expect(result.merchant, 'Restaurante Sol');
    expect(result.categoryId, 'food');
  });

  test('supports thousands separators ISO dates and generic fallback', () {
    final result = ReceiptParser.parse(
      lines: [
        line('ACME SERVICES'),
        line('Date 2026-07-29'),
        line("TOTAL CHF 1'234.50"),
      ],
      categories: categories,
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.amountMinor, 123450);
    expect(result.currencyCode, 'CHF');
    expect(result.date, DateTime(2026, 7, 29));
    expect(result.merchant, 'Acme Services');
    expect(result.categoryId, 'other');
  });

  test('handles zero-decimal currencies and textual dates', () {
    final result = ReceiptParser.parse(
      lines: [
        line('TOKYO MARKET'),
        line('29 Jul 2026'),
        line('TOTAL JPY 1,200'),
      ],
      categories: categories,
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.amountMinor, 1200);
    expect(result.currencyCode, 'JPY');
    expect(result.date, DateTime(2026, 7, 29));
    expect(result.categoryId, 'groceries');
  });

  test('custom category names are learned without a remote rule engine', () {
    const pharmacy = Category(
      id: 'custom-pharmacy',
      name: 'Farmacia',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: false,
    );
    final result = ReceiptParser.parse(
      lines: [line('FARMACIA CENTRALE'), line('TOTALE € 12,80')],
      categories: [...categories, pharmacy],
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.categoryId, pharmacy.id);
  });

  test('rejoins total labels and amounts split into separate OCR boxes', () {
    final result = ReceiptParser.parse(
      lines: [
        line('CORNER SHOP'),
        line('SUBTOTAL'),
        line('EUR 99.00'),
        line('TOTAL'),
        line('EUR 24.00'),
      ],
      categories: categories,
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.amountMinor, 2400);
  });

  test('empty OCR never pretends that generic data was detected', () {
    final result = ReceiptParser.parse(
      lines: const [],
      categories: categories,
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );

    expect(result.detectedFieldCount, 0);
    expect(result.categoryId, isNull);
    expect(result.confidence, 0);
  });

  test('Feltrinelli books beat an ambiguous short custom category', () {
    const simCategory = Category(
      id: 'custom-sim',
      name: 'SIM',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: false,
    );
    final result = ReceiptParser.parse(
      lines: [
        line('LA FELTRINELLI'),
        line('SIM S.p.A. documento commerciale'),
        line('LIBRO NARRATIVA ISBN 9788800000000'),
        line('LIBRO SAGGISTICA ISBN 9788811111111'),
        line('TOTALE EUR 32,00'),
      ],
      categories: [...categories, simCategory],
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 8, 1),
    );

    expect(result.merchant, 'La Feltrinelli');
    expect(result.categoryId, 'education');
  });
}
