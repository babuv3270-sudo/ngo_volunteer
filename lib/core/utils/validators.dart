abstract final class Validators {
  static String? required(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final RegExp pattern = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final RegExp pattern = RegExp(r'^\+?[0-9]{7,15}$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) return 'Password must be at least $minLength characters';
    return null;
  }

  static String? confirmPassword(String? value, String password, {String? confirmLabel}) {
    if (value == null || value.isEmpty) return 'Please re-enter your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < minLength) return 'Name must be at least $minLength characters';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final RegExp pattern = RegExp(r'^(https?://)?([\w\-]+\.)+[\w\-]+(/[\w\-./?%&=]*)?$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid URL';
    return null;
  }
}