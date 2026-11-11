import 'app_user.dart';

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  AuthUser copyWith({String? displayName}) {
    return AuthUser(uid: uid, email: email, role: role, displayName: displayName ?? this.displayName);
  }
}