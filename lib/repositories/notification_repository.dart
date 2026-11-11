import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firebase_config.dart';
import '../models/app_notification.dart';
import '../services/mock_backend.dart';
import 'firestore_utils.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchForUser(String userId);
  Future<void> markRead(String notificationId);
  Future<void> markAllRead(String userId);
  Future<void> create(AppNotification notification);
}

class NotificationRepositoryFactory {
  static NotificationRepository create() {
    return FirebaseConfig.isConfigured
        ? FirebaseNotificationRepository()
        : DemoNotificationRepository();
  }
}

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<AppNotification>> fetchForUser(String userId) async {
    final QuerySnapshot snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    final List<AppNotification> items = snapshot.docs
        .map((doc) => AppNotification.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
    items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return items;
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllRead(String userId) async {
    final QuerySnapshot snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    for (final QueryDocumentSnapshot doc in snapshot.docs) {
      if (doc.get('isRead') == false) {
        await doc.reference.update({'isRead': true});
      }
    }
  }

  @override
  Future<void> create(AppNotification notification) async {
    await _db.collection('notifications').add(notification.toMap());
  }
}

class DemoNotificationRepository implements NotificationRepository {
  final MockBackend _backend = MockBackend.instance;

  @override
  Future<List<AppNotification>> fetchForUser(String userId) async {
    final List<AppNotification> items = _backend.notifications
        .where((n) => n.userId == userId)
        .toList();
    items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return items;
  }

  @override
  Future<void> markRead(String notificationId) async {
    final int index = _backend.notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _backend.notifications[index] = _backend.notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    for (int i = 0; i < _backend.notifications.length; i++) {
      if (_backend.notifications[i].userId == userId && !_backend.notifications[i].isRead) {
        _backend.notifications[i] = _backend.notifications[i].copyWith(isRead: true);
      }
    }
  }

  @override
  Future<void> create(AppNotification notification) async {
    _backend.notifications.add(notification);
  }
}