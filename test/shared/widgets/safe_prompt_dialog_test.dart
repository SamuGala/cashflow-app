import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/shared/widgets/safe_prompt_dialog.dart';

void main() {
  testWidgets('prompt can be cancelled without using a disposed controller', (
    tester,
  ) async {
    String? result = 'not-completed';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (_) => const SafePromptDialog(
                  title: 'Budget',
                  label: 'Importo',
                  cancelLabel: 'Annulla',
                  confirmLabel: 'Salva',
                ),
              );
            },
            child: const Text('Apri'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed password is returned after the dialog closes', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (_) => const SafePasswordDialog(
                  title: 'Backup',
                  cancelLabel: 'Annulla',
                  confirmLabel: 'Continua',
                  requireConfirmation: true,
                ),
              );
            },
            child: const Text('Apri'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'password sicura');
    await tester.enterText(find.byType(TextField).last, 'password sicura');
    await tester.tap(find.text('Continua'));
    await tester.pumpAndSettle();

    expect(result, 'password sicura');
    expect(tester.takeException(), isNull);
  });
}
