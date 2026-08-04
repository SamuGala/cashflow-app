import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/features/transactions/domain/category.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native OCR recognizes and parses a local receipt image', (
    tester,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    const rows = [
      'ESSELUNGA',
      'DATA 31/07/2026',
      'SUBTOTALE EUR 21.90',
      'IVA EUR 2.10',
      'TOTALE EUR 24.00',
    ];
    for (var index = 0; index < rows.length; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text: rows[index],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 58,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 1040);
      painter.paint(canvas, Offset(80, 100 + index * 170));
    }
    final image = await recorder.endRecording().toImage(1200, 1100);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await Directory.systemTemp.createTemp('receipt-ocr-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/receipt.png');
    await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);

    final lines = await const ReceiptOcrService().recognize(file.path);
    final recognized = lines.map((line) => line.text).join('\n').toUpperCase();
    expect(recognized, contains('ESSELUNGA'));
    expect(recognized, contains('TOTALE'));

    final extraction = ReceiptParser.parse(
      lines: lines,
      categories: const [
        Category(
          id: 'groceries',
          name: 'groceries',
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
      ],
      fallbackCurrency: 'EUR',
      now: DateTime(2026, 7, 31),
    );
    expect(extraction.amountMinor, 2400);
    expect(extraction.date, DateTime(2026, 7, 31));
    expect(extraction.categoryId, 'groceries');
  });
}
