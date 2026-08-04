import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/receipts/receipt_capture_page.dart';
import 'package:pocket_vault/core/receipts/receipt_storage_service.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

void main() {
  testWidgets('library action is bottom-left of the receipt shutter', (
    tester,
  ) async {
    var libraryTapped = false;
    var captureTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ReceiptCaptureBottomControls(
                busy: false,
                canCapture: true,
                libraryLabel: 'Choose from library',
                captureLabel: 'Take a photo',
                onLibrary: () => libraryTapped = true,
                onCapture: () => captureTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    final library = find.byKey(const ValueKey('receipt-camera-library'));
    final shutter = find.byKey(const ValueKey('receipt-camera-shutter'));
    expect(library, findsOneWidget);
    expect(shutter, findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-camera-switch')), findsNothing);
    expect(
      tester.getCenter(library).dx,
      lessThan(tester.getCenter(shutter).dx),
    );

    await tester.tap(library);
    await tester.tap(shutter);
    expect(libraryTapped, isTrue);
    expect(captureTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('receipt camera uses the root navigator and covers app footer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        supportedLocales: const [Locale('en'), Locale('it'), Locale('es')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          bottomNavigationBar: const SizedBox(
            key: ValueKey('app-footer'),
            height: 72,
          ),
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (nestedContext) => Center(
                child: FilledButton(
                  key: const ValueKey('open-receipt-camera'),
                  onPressed: () => showReceiptCapture(
                    context: nestedContext,
                    storage: ReceiptStorageService(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-footer')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('open-receipt-camera')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ReceiptCapturePage), findsOneWidget);
    expect(find.byKey(const ValueKey('app-footer')), findsNothing);
    expect(find.byKey(const ValueKey('receipt-camera-switch')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('receipt-camera-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-footer')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
