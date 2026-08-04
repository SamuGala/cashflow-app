import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:pocket_vault/shared/widgets/inline_load_error.dart';

void main() {
  testWidgets('shows a localized retry action without technical details', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: InlineLoadError(onRetry: () => retries++)),
      ),
    );

    expect(find.text('Dati temporaneamente non disponibili.'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('objective_c'), findsNothing);

    await tester.tap(find.text('Riprova'));
    expect(retries, 1);
  });
}
