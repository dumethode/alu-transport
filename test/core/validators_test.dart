import 'package:alu_transport/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty email', () {
      expect(Validators.email(''), 'Enter your email');
    });

    test('rejects an email without a domain', () {
      expect(Validators.email('jean@'), isNotNull);
    });

    test('accepts a normal ALU email', () {
      expect(Validators.email('j.muhire@alustudent.com'), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('needs at least 8 characters', () {
      expect(Validators.newPassword('abc12'), 'Use at least 8 characters');
    });

    test('needs letters and a number', () {
      expect(
        Validators.newPassword('abcdefgh'),
        'Use letters and at least one number',
      );
    });

    test('accepts a strong password', () {
      expect(Validators.newPassword('busride2026'), isNull);
    });
  });

  test('confirmPassword checks both passwords match', () {
    expect(Validators.confirmPassword('one11111', 'two22222'), isNotNull);
    expect(Validators.confirmPassword('same1234', 'same1234'), isNull);
  });

  test('fullName limits the length', () {
    expect(Validators.fullName('A'), 'Name is too short');
    expect(Validators.fullName('Jean Muhire'), isNull);
  });
}
