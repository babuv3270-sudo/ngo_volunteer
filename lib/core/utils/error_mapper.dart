String friendlyAuthErrorMessage(Object error) {
  final String message = error.toString();
  if (message.contains('email-already-in-use')) return 'An account with this email already exists.';
  if (message.contains('invalid-email')) return 'Enter a valid email address.';
  if (message.contains('user-not-found')) return 'No account found for this email.';
  if (message.contains('wrong-password') || message.contains('invalid-credential')) return 'Incorrect email or password.';
  if (message.contains('weak-password')) return 'Password is too weak. Use at least 6 characters.';
  if (message.contains('network-request-failed') || message.contains('network_error')) return 'Network error. Check your connection and try again.';
  if (message.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
  if (message.contains('Operation not allowed') || message.contains('SERVICE_DISABLED')) {
    return 'Firebase services are not fully set up yet. Check the Firestore database and sign-in methods.';
  }
  if (message.contains('TimeoutException')) return 'Request timed out. Check that Firebase is set up correctly and try again.';
  return 'Something went wrong. Please try again.';
}