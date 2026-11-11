import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIj3-g3p2yf3-jpFWvsAIsONdYowZTZeQ',
    appId: '1:681467142846:web:ddc199d457838ac238b4ef',
    messagingSenderId: '681467142846',
    projectId: 'volunteer-ad8c4',
    authDomain: 'volunteer-ad8c4.firebaseapp.com',
    storageBucket: 'volunteer-ad8c4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIj3-g3p2yf3-jpFWvsAIsONdYowZTZeQ',
    appId: '1:681467142846:web:ddc199d457838ac238b4ef',
    messagingSenderId: '681467142846',
    projectId: 'volunteer-ad8c4',
    storageBucket: 'volunteer-ad8c4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    appId: 'REPLACE_WITH_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    appId: 'REPLACE_WITH_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
  );
}