import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

abstract final class FirebaseConfig {
  static bool _initialized = false;
  static bool _failed = false;

  static bool get isConfigured => _initialized;
  static bool get initializationFailed => _failed;
  static FirebaseOptions? get _currentOptions => _resolveOptions();

  static Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    if (_failed) return false;
    try {
      await Firebase.initializeApp(options: _currentOptions);
      _initialized = true;
      return true;
    } catch (error) {
      _failed = true;
      debugPrint('Firebase initialization failed: $error');
      return false;
    }
  }

  static FirebaseOptions? _resolveOptions() {
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } catch (_) {
      return null;
    }
  }
}