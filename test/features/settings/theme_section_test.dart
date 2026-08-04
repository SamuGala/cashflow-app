import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/features/settings/presentation/settings_page.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('system theme label stays on one line on a compact screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('it'),
          supportedLocales: [Locale('en'), Locale('it'), Locale('es')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Padding(padding: EdgeInsets.all(16), child: ThemeSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final systemLabel = tester.widget<Text>(find.text('Sistema'));
    expect(systemLabel.maxLines, 1);
    expect(systemLabel.softWrap, isFalse);
    expect(tester.getSize(find.text('Sistema')).height, lessThan(24));
    expect(tester.takeException(), isNull);
  });
}
