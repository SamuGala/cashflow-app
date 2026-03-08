import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cashflow_app/app/app.dart';

void main() {

  testWidgets('Cashflow app loads', (WidgetTester tester) async {

    await tester.pumpWidget(
      const ProviderScope(
        child: CashflowApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CashflowApp), findsOneWidget);
  });

}