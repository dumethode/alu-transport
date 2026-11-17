import 'package:alu_transport/core/theme/app_theme.dart';
import 'package:alu_transport/features/alerts/domain/entities/status_update.dart';
import 'package:alu_transport/features/alerts/presentation/widgets/alert_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AlertTile shows the stop, round, note and time', (
    WidgetTester tester,
  ) async {
    final DateTime sent = DateTime(2026, 11, 12, 7, 47);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AlertTile(
            update: StatusUpdate(
              id: 'u1',
              roundId: 'r2',
              driverId: 'driver-1',
              type: StatusUpdateType.atPickup,
              stopId: 'remera',
              note: 'Traffic is light',
              createdAt: sent,
            ),
            roundLabel: 'Round 2',
            stopName: 'Remera',
            now: sent.add(const Duration(minutes: 3)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('At pickup point: Remera'), findsOneWidget);
    expect(find.text('Round 2'), findsOneWidget);
    expect(find.text('Driver note: Traffic is light'), findsOneWidget);
    expect(find.text('3 min ago'), findsOneWidget);
  });
}
