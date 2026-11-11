import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryFactory.create();

  final NotificationRepository _repository;

  List<AppNotification> _items = [];
  bool _loading = false;

  List<AppNotification> get items => _items;
  bool get loading => _loading;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> load(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _items = await _repository.fetchForUser(userId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> send({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _repository.create(AppNotification(
      id: 'nt-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      type: type,
    ));
  }

  Future<void> markRead(String notificationId) async {
    await _repository.markRead(notificationId);
    final int index = _items.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllRead(String userId) async {
    await _repository.markAllRead(userId);
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}