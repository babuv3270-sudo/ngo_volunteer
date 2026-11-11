import 'package:flutter/foundation.dart';

import '../core/utils/error_mapper.dart';
import '../firebase/firebase_config.dart';
import '../models/app_user.dart';
import '../models/auth_user.dart';
import '../models/ngo_profile.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? auth, UserRepository? users})
      : _auth = auth ?? AuthServiceFactory.create(),
        _users = users ?? UserRepositoryFactory.create() {
    _initialization = _initialize();
  }

  final AuthService _auth;
  final UserRepository _users;
  late final Future<void> _initialization;

  AuthUser? user;
  AppUser? volunteerProfile;
  NgoProfile? ngoProfile;
  bool isLoading = false;
  bool isInitialized = false;
  String? errorMessage;

  bool get isDemoMode => !FirebaseConfig.isConfigured;
  bool get isSignedIn => user != null;
  bool get isVolunteer => user?.role == UserRole.volunteer;

  Future<void> get initialization => _initialization;

  Future<void> _initialize() async {
    try {
      final AuthUser? current = await _auth.loadCurrent();
      user = current;
      if (current != null) await _loadProfile(current);
    } catch (error) {
      errorMessage = friendlyAuthErrorMessage(error);
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadProfile(AuthUser current) async {
    if (current.role == UserRole.volunteer) {
      volunteerProfile = await _users.fetchUser(current.uid);
    } else {
      ngoProfile = await _users.fetchNgo(current.uid);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(() async {
      final AuthUser signedIn = await _auth.signIn(email: email, password: password);
      user = signedIn;
      await _loadProfile(signedIn);
      return true;
    });
  }

  Future<bool> signUpVolunteer({
    required String name,
    required String email,
    required String? phone,
    required String password,
  }) async {
    return _run(() async {
      final AuthUser signedIn = await _auth.signUp(
        role: UserRole.volunteer,
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      user = signedIn;
      await _loadProfile(signedIn);
      return true;
    });
  }

  Future<bool> signUpNgo({
    required String name,
    required String email,
    required String? phone,
    required String password,
    NgoProfile? ngoDetails,
  }) async {
    return _run(() async {
      final AuthUser signedIn = await _auth.signUp(
        role: UserRole.ngo,
        name: name,
        email: email,
        phone: phone,
        password: password,
        ngoDetails: ngoDetails,
      );
      user = signedIn;
      await _loadProfile(signedIn);
      return true;
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    return _run(() async {
      await _auth.sendPasswordReset(email);
      return true;
    });
  }

  Future<bool> updateVolunteerProfile(AppUser updated) async {
    try {
      await _users.saveUser(updated);
      volunteerProfile = updated;
      user = user?.copyWith(displayName: updated.name);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateNgoProfile(NgoProfile updated) async {
    try {
      await _users.saveNgo(updated);
      ngoProfile = updated;
      user = user?.copyWith(displayName: updated.name);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
    volunteerProfile = null;
    ngoProfile = null;
    notifyListeners();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      return await action().timeout(const Duration(seconds: 30));
    } catch (error) {
      errorMessage = friendlyAuthErrorMessage(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}