import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/receipts/receipt_scan_review_sheet.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/features/transactions/domain/category.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

void main() {
  testWidgets('detected receipt fields can be corrected before use', (
    tester,
  ) async {
    late Directory directory;
    late File image;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('receipt-review-');
      image = File('${directory.path}/receipt.png');
      await image.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
          'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      );
    });
    addTearDown(() => directory.deleteSync(recursive: true));

    const categories = [
      Category(
        id: 'education',
        name: 'education',
        isIncome: false,
        icon: 59404,
        color: 0xFF26A69A,
        isDefault: true,
      ),
      Category(
        id: 'other',
        name: 'other',
        isIncome: false,
        icon: 58835,
        color: 0xFF64748B,
        isDefault: true,
      ),
    ];
    ReceiptScanReviewResult? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showReceiptScanReview(
                  context: context,
                  draft: ReceiptScanDraft(
                    imagePath: image.path,
                    extraction: const ReceiptExtraction(
                      amountMinor: 3200,
                      currencyCode: 'EUR',
                      date: null,
                      merchant: 'Feltrinelli',
                      categoryId: 'education',
                      confidence: .92,
                      recognizedText: 'FELTRINELLI LIBRI TOTALE 32,00',
                    ),
                  ),
                  categories: categories,
                );
              },
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(
      find.byKey(const ValueKey('receipt-review-merchant')),
      'La Feltrinelli Roma',
    );
    await tester.enterText(
      find.byKey(const ValueKey('receipt-review-amount')),
      '45,90',
    );
    final apply = find.byKey(const ValueKey('receipt-review-apply'));
    await tester.ensureVisible(apply);
    await tester.tap(apply);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(result?.appliesDetectedData, isTrue);
    expect(result?.draft.extraction?.merchant, 'La Feltrinelli Roma');
    expect(result?.draft.extraction?.amountMinor, 4590);
    expect(result?.draft.extraction?.categoryId, 'education');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
