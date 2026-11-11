# Project notes

## Environment quirks (Windows)

This machine must work around a Windows path issue: the Flutter SDK lives under a
path containing a space (`C:\Users\Anantha lakshmi\...`) which breaks Flutter's
native-assets (build hooks) for packages like `objective_c`
(`'C:\Users\Anantha' is not recognized as an internal or external command`).

Workaround that is currently in place:

- The SDK is reachable at the space-free junction `C:\flutter` -> the real SDK
  location. Always invoke Flutter as `C:\flutter\bin\flutter.bat` (or ensure
  `C:\flutter\bin` is on `PATH` before any space-containing Flutter path).
- Developer Mode is enabled on this machine (registry
  `HKLM\...\AppModelUnlock\AllowDevelopmentWithoutDevLicense=1`); Windows
  requires it for Flutter plugin symlinks.
- Native assets must stay enabled: `flutter config --enable-native-assets`
  (packages such as `objective_c`, pulled in transitively via
  `path_provider_foundation`, refuse to build without it).

## Running the app

- Web/Chrome: `flutter run -d chrome`
- Devices available: Windows (desktop), Chrome, Edge.

## App architecture

- Flutter app; state management via `provider`; Firebase (Firebase Auth,
  Cloud Firestore, Firebase Storage, Firebase Messaging).
- Folders: `screens/`, `widgets/`, `models/`, `repositories/`, `routes/`,
  `services/`, `core/`, plus platform dirs.