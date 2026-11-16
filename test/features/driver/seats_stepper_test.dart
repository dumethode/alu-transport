import 'package:alu_transport/core/theme/app_theme.dart';
import 'package:alu_transport/features/driver/presentation/widgets/seats_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<int>> pumpStepper(WidgetTester tester, int value) async {
    final List<int> changes = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SeatsStepper(value: value, max: 29, onChanged: changes.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return changes;
  }

  testWidgets('plus and minus report +1 and -1', (WidgetTester tester) async {
    final List<int> changes = await pumpStepper(tester, 12);
    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.byTooltip('One seat more'));
    await tester.tap(find.byTooltip('One seat less'));
    expect(changes, <int>[1, -1]);
  });

  testWidgets('minus is disabled at zero', (WidgetTester tester) async {
    final List<int> changes = await pumpStepper(tester, 0);
    await tester.tap(find.byTooltip('One seat less'));
    expect(changes, isEmpty);
  });

  testWidgets('buttons meet the 48dp Material tap size', (
    WidgetTester tester,
  ) async {
    await pumpStepper(tester, 5);
    final Size size = tester.getSize(find.byType(IconButton).first);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
