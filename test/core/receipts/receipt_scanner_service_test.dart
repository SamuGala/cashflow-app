import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/receipts/receipt_scanner_service.dart';
import 'package:pocket_vault/core/receipts/receipt_storage_service.dart';
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
      id: 'other',
      name: 'other',
      isIncome: false,
      icon: 1,
      color: 1,
      isDefault: true,
    ),
  ];

  test('camera photo is retained and parsed into an expense draft', () async {
    final storage = _FakeReceiptStorage(cameraPath: '/tmp/camera-receipt.jpg');
    final ocr = _FakeReceiptOcr([
      const ReceiptOcrLine(
        text: 'ESSELUNGA',
        confidence: .98,
        x: 0,
        y: .1,
        width: 1,
        height: .1,
      ),
      const ReceiptOcrLine(
        text: 'DATA 31/07/2026',
        confidence: .96,
        x: 0,
        y: .2,
        width: 1,
        height: .1,
      ),
      const ReceiptOcrLine(
        text: 'TOTALE EUR 24.00',
        confidence: .99,
        x: 0,
        y: .3,
        width: 1,
        height: .1,
      ),
    ]);
    final scanner = ReceiptScannerService(storage: storage, ocr: ocr);

    final draft = await scanner.scanCamera(
      categories: categories,
      fallbackCurrency: 'EUR',
    );

    expect(storage.cameraCalls, 1);
    expect(draft?.imagePath, '/tmp/camera-receipt.jpg');
    expect(draft?.automaticReadFailed, isFalse);
    expect(draft?.extraction?.amountMinor, 2400);
    expect(draft?.extraction?.date, DateTime(2026, 7, 31));
    expect(draft?.extraction?.categoryId, 'groceries');
  });

  test('library cancellation exits without invoking OCR', () async {
    final storage = _FakeReceiptStorage();
    final ocr = _FakeReceiptOcr(const []);
    final scanner = ReceiptScannerService(storage: storage, ocr: ocr);

    final draft = await scanner.scanLibrary(
      categories: categories,
      fallbackCurrency: 'EUR',
    );

    expect(draft, isNull);
    expect(storage.libraryCalls, 1);
    expect(ocr.calls, 0);
  });

  test('native OCR failure keeps the photo available for attachment', () async {
    final storage = _FakeReceiptStorage(libraryPath: '/tmp/manual.jpg');
    final scanner = ReceiptScannerService(
      storage: storage,
      ocr: _FakeReceiptOcr(
        const [],
        error: PlatformException(code: 'recognition_failed'),
      ),
    );

    final draft = await scanner.scanLibrary(
      categories: categories,
      fallbackCurrency: 'EUR',
    );

    expect(draft?.imagePath, '/tmp/manual.jpg');
    expect(draft?.extraction, isNull);
    expect(draft?.automaticReadFailed, isTrue);
  });
}

class _FakeReceiptStorage extends ReceiptStorageService {
  _FakeReceiptStorage({this.cameraPath, this.libraryPath});

  final String? cameraPath;
  final String? libraryPath;
  int cameraCalls = 0;
  int libraryCalls = 0;

  @override
  Future<String?> capture() async {
    cameraCalls++;
    return cameraPath;
  }

  @override
  Future<String?> chooseFromLibrary() async {
    libraryCalls++;
    return libraryPath;
  }
}

class _FakeReceiptOcr extends ReceiptOcrService {
  _FakeReceiptOcr(this.lines, {this.error});

  final List<ReceiptOcrLine> lines;
  final Object? error;
  int calls = 0;

  @override
  Future<List<ReceiptOcrLine>> recognize(String imagePath) async {
    calls++;
    if (error != null) throw error!;
    return lines;
  }
}
