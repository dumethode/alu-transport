/// Turns Firebase error codes into short, polite messages.
String authMessageForCode(String code) {
  switch (code) {
    case 'invalid-email':
      return 'That email address does not look right.';
    case 'user-disabled':
      return 'This account has been turned off. Contact the transport office.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect. Please try again.';
    case 'email-already-in-use':
      return 'An account already uses this email. Try logging in instead.';
    case 'weak-password':
      return 'Choose a stronger password (8+ characters with a number).';
    case 'too-many-requests':
      return 'Too many attempts. Wait a minute and try again.';
    case 'network-request-failed':
      return 'No internet connection. Check your network and try again.';
    case 'account-exists-with-different-credential':
      return 'This email is linked to another sign-in method.';
    case 'operation-not-allowed':
      return 'This sign-in method is not turned on yet.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
