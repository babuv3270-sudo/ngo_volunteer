import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebase_config.dart';
import '../models/app_user.dart';
import '../models/auth_user.dart';
import '../models/ngo_profile.dart';
import 'mock_backend.dart';

abstract class AuthService {
  Future<AuthUser?> loadCurrent();
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({
    required UserRole role,
    required String name,
    required String email,
    required String? phone,
    required String password,
    NgoProfile? ngoDetails,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class AuthServiceFactory {
  static AuthService create() {
    return FirebaseConfig.isConfigured ? FirebaseAuthService() : DemoAuthService();
  }
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AuthUser?> loadCurrent() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _resolveRole(firebaseUser);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _resolveRole(credential.user!);
  }

  @override
  Future<AuthUser> signUp({
    required UserRole role,
    required String name,
    required String email,
    required String? phone,
    required String password,
    NgoProfile? ngoDetails,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final String uid = credential.user!.uid;

    if (role == UserRole.volunteer) {
      await _db.collection('users').doc(uid).set(
            AppUser(uid: uid, name: name, email: email.trim(), role: role, phone: phone).toMap(),
          );
    } else {
final NgoProfile profile = (ngoDetails ??
        NgoProfile(uid: uid, name: name, email: email.trim(), phone: phone))
    .copyWith(uid: uid);
    await _db.collection('ngos').doc(uid).set(profile.toMap());
    }

    return AuthUser(uid: uid, email: email.trim(), role: role, displayName: name);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<AuthUser> _resolveRole(User firebaseUser) async {
    final String uid = firebaseUser.uid;
    final String email = firebaseUser.email ?? '';

    final DocumentSnapshot userSnapshot = await _db.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      final AppUser profile = AppUser.fromMap(userSnapshot.data() as Map<String, dynamic>);
      return AuthUser(uid: uid, email: email, role: UserRole.volunteer, displayName: profile.name);
    }

    final DocumentSnapshot ngoSnapshot = await _db.collection('ngos').doc(uid).get();
    if (ngoSnapshot.exists) {
      final NgoProfile profile = NgoProfile.fromMap(ngoSnapshot.data() as Map<String, dynamic>);
      return AuthUser(uid: uid, email: email, role: UserRole.ngo, displayName: profile.name);
    }

    return AuthUser(uid: uid, email: email, role: UserRole.volunteer);
  }
}

class DemoAuthService implements AuthService {
  final MockBackend _backend = MockBackend.instance;

  @override
  Future<AuthUser?> loadCurrent() async => _backend.current;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    if (password.isEmpty || password.length < 6) {
      throw Exception('wrong-password');
    }
    final AppUser? volunteer = _backend.findUserByEmail(email);
    if (volunteer != null) {
      final AuthUser user = AuthUser(uid: volunteer.uid, email: volunteer.email, role: UserRole.volunteer, displayName: volunteer.name);
      _backend.current = user;
      return user;
    }
    final NgoProfile? ngo = _backend.findNgoByEmail(email);
    if (ngo != null) {
      final AuthUser user = AuthUser(uid: ngo.uid, email: ngo.email ?? email, role: UserRole.ngo, displayName: ngo.name);
      _backend.current = user;
      return user;
    }
    throw Exception('user-not-found');
  }

  @override
  Future<AuthUser> signUp({
    required UserRole role,
    required String name,
    required String email,
    required String? phone,
    required String password,
    NgoProfile? ngoDetails,
  }) async {
    final String safeEmail = email.trim().toLowerCase();
    if (_backend.findUserByEmail(safeEmail) != null || _backend.findNgoByEmail(safeEmail) != null) {
      throw Exception('email-already-in-use');
    }

    AuthUser user;
    if (role == UserRole.volunteer) {
      final String uid = 'v-${DateTime.now().millisecondsSinceEpoch}';
      _backend.users.add(AppUser(uid: uid, name: name, email: safeEmail, role: role, phone: phone));
      user = AuthUser(uid: uid, email: safeEmail, role: role, displayName: name);
    } else {
      final String uid = 'n-${DateTime.now().millisecondsSinceEpoch}';
      _backend.ngos.add(
        (ngoDetails ?? NgoProfile(uid: uid, name: name, email: safeEmail, phone: phone)).copyWith(uid: uid),
      );
      user = AuthUser(uid: uid, email: safeEmail, role: role, displayName: name);
    }
    _backend.current = user;
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final bool exists = _backend.findUserByEmail(email) != null || _backend.findNgoByEmail(email) != null;
    if (!exists) throw Exception('user-not-found');
  }

  @override
  Future<void> signOut() async {
    _backend.current = null;
  }
}