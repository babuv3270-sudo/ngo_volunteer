import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firebase_config.dart';
import '../models/app_user.dart';
import '../models/ngo_profile.dart';
import '../services/mock_backend.dart';

abstract class UserRepository {
  Future<AppUser?> fetchUser(String uid);
  Future<NgoProfile?> fetchNgo(String uid);
  Future<void> saveUser(AppUser user);
  Future<void> saveNgo(NgoProfile ngo);
}

class UserRepositoryFactory {
  static UserRepository create() {
    return FirebaseConfig.isConfigured ? FirebaseUserRepository() : DemoUserRepository();
  }
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AppUser?> fetchUser(String uid) async {
    final DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<NgoProfile?> fetchNgo(String uid) async {
    final DocumentSnapshot snapshot = await _db.collection('ngos').doc(uid).get();
    if (!snapshot.exists) return null;
    return NgoProfile.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> saveNgo(NgoProfile ngo) async {
    await _db.collection('ngos').doc(ngo.uid).set(ngo.toMap(), SetOptions(merge: true));
  }
}

class DemoUserRepository implements UserRepository {
  final MockBackend _backend = MockBackend.instance;

  @override
  Future<AppUser?> fetchUser(String uid) async => _backend.findUser(uid);

  @override
  Future<NgoProfile?> fetchNgo(String uid) async => _backend.findNgo(uid);

  @override
  Future<void> saveUser(AppUser user) async {
    final int index = _backend.users.indexWhere((u) => u.uid == user.uid);
    if (index >= 0) {
      _backend.users[index] = user;
    } else {
      _backend.users.add(user);
    }
  }

  @override
  Future<void> saveNgo(NgoProfile ngo) async {
    final int index = _backend.ngos.indexWhere((n) => n.uid == ngo.uid);
    if (index >= 0) {
      _backend.ngos[index] = ngo;
    } else {
      _backend.ngos.add(ngo);
    }
  }
}