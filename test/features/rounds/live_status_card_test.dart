import 'package:alu_transport/core/theme/app_theme.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:alu_transport/features/rounds/presentation/widgets/live_status_card.dart';
import 'package:alu_transport/features/rounds/presentation/widgets/round_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'round_test_data.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('LiveStatusCard shows status, departure and seats', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LiveStatusCard(
          round: sampleRound(),
          position: 2,
          totalRounds: 3,
          use24Hour: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Round 2 of 3 today'), findsOneWidget);
    expect(find.text('On the way'), findsOneWidget);
    expect(find.text('Left campus at 07:40'), findsOneWidget);
    expect(find.text('12 of 29 seats left'), findsOneWidget);
  });
  testWidgets('RoundTile lets a student turn a reminder on', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _wrap(
        RoundTile(
          round: sampleRound(status: RoundStatus.planned),
          use24Hour: false,
          onToggleReminder: () => taps++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Round 2 · 7:40 AM'), findsOneWidget);
    await tester.tap(find.text('Remind me'));
    expect(taps, 1);
  });
}
