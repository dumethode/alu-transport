/// Form validation rules shared by every screen.
/// Each function returns an error message, or null when the value is fine.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _letter = RegExp(r'[A-Za-z]');
  static final RegExp _digit = RegExp(r'\d');

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter your email';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Enter a valid email, like name@alustudent.com';
    }
    return null;
  }

  /// Used when creating an account: at least 8 characters, letters and a number.
  static String? newPassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return 'Enter a password';
    }
    if (text.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return 'Use letters and at least one number';
    }
    return null;
  }

  /// Used on the login screen, where we only check that something was typed.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Type your password again';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? fullName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter your full name';
    }
    if (text.length < 2) {
      return 'Name is too short';
    }
    if (text.length > 40) {
      return 'Keep your name under 40 characters';
    }
    return null;
  }

  static String? roundLabel(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Give the round a name, like Round 1';
    }
    if (text.length > 30) {
      return 'Keep the name under 30 characters';
    }
    return null;
  }
}
