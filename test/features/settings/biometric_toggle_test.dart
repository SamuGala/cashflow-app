import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/features/settings/presentation/settings_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

Widget _app(TargetPlatform platform) => MaterialApp(
  theme: ThemeData(platform: platform),
  locale: const Locale('it'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: const Scaffold(body: FaceIdToggle()),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('names Face ID on iOS and biometrics elsewhere', (tester) async {
    await tester.pumpWidget(_app(TargetPlatform.iOS));
    await tester.pumpAndSettle();
    expect(find.text('Face ID'), findsOneWidget);

    await tester.pumpWidget(_app(TargetPlatform.android));
    await tester.pumpAndSettle();
    expect(find.text('Face ID'), findsNothing);
    expect(find.text('Sblocco biometrico'), findsOneWidget);
  });

  testWidgets('the switch reflects a tap immediately', (tester) async {
    await tester.pumpWidget(_app(TargetPlatform.android));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });
}
