import 'package:alu_transport/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime evening = DateTime(2026, 11, 12, 17, 5);

  test('time uses 24-hour or 12-hour format', () {
    expect(Formatters.time(evening), '17:05');
    expect(Formatters.time(evening, use24Hour: false), '5:05 PM');
    expect(
      Formatters.time(DateTime(2026, 1, 1, 0, 30), use24Hour: false),
      '12:30 AM',
    );
  });

  test('timeAgo gives short readable text', () {
    final DateTime now = DateTime(2026, 11, 12, 8);
    expect(Formatters.timeAgo(now, now: now), 'just now');
    expect(
      Formatters.timeAgo(now.subtract(const Duration(minutes: 4)), now: now),
      '4 min ago',
    );
    expect(
      Formatters.timeAgo(now.subtract(const Duration(days: 1)), now: now),
      'Yesterday',
    );
  });

  test('minutesFromNow handles minutes and hours', () {
    expect(Formatters.minutesFromNow(0), 'now');
    expect(Formatters.minutesFromNow(10), 'in 10 min');
    expect(Formatters.minutesFromNow(65), 'in 1h 5min');
  });

  test('firstName and greeting', () {
    expect(Formatters.firstName('  Jean   Muhire '), 'Jean');
    expect(Formatters.firstName(''), 'there');
    expect(Formatters.greeting(DateTime(2026, 1, 1, 9)), 'Good morning');
    expect(Formatters.greeting(DateTime(2026, 1, 1, 20)), 'Good evening');
  });
}
