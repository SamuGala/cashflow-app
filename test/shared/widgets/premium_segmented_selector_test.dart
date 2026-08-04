import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/shared/widgets/premium_segmented_selector.dart';

void main() {
  testWidgets('shared time selector keeps premium geometry and changes value', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: PremiumSegmentedSelector(
                labels: const ['Total', 'Month', 'Period'],
                selectedIndex: selected,
                onChanged: (value) => setState(() => selected = value),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(PremiumSegmentedSelector)).height, 52);
    await tester.tap(find.text('Month'));
    await tester.pump();

    expect(selected, 1);
    final semantics = tester.getSemantics(find.text('Month'));
    expect(semantics.flagsCollection.isSelected.toBoolOrNull(), isTrue);
  });
}
