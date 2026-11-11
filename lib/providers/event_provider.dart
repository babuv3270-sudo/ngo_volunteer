import 'package:flutter/foundation.dart';

import '../core/utils/badges_utils.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/event_registration.dart';
import '../models/volunteer_event.dart';
import '../repositories/event_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/user_repository.dart';

class EventProvider extends ChangeNotifier {
  EventProvider({EventRepository? repository, NotificationRepository? notifications, UserRepository? users})
      : _repository = repository ?? EventRepositoryFactory.create(),
        _notifications = notifications ?? NotificationRepositoryFactory.create(),
        _users = users ?? UserRepositoryFactory.create();

  final EventRepository _repository;
  final NotificationRepository _notifications;
  final UserRepository _users;

  List<VolunteerEvent> _events = [];
  List<EventRegistration> _myRegistrations = [];
  List<VolunteerEvent> _ngoEvents = [];
  List<EventRegistration> _ngoRegistrations = [];
  bool _loading = false;
  bool _registrationsLoading = false;
  bool _ngoLoading = false;

  List<VolunteerEvent> get events => _events;
  List<EventRegistration> get myRegistrations => _myRegistrations;
  List<VolunteerEvent> get ngoEvents => _ngoEvents;
  List<EventRegistration> get ngoRegistrations => _ngoRegistrations;
  bool get loading => _loading;
  bool get registrationsLoading => _registrationsLoading;
  bool get ngoLoading => _ngoLoading;

  List<VolunteerEvent> get upcomingEvents {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return _events.where((e) => e.isUpcoming && !e.date.isBefore(today)).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<EventRegistration> get attendedRegistrations =>
      _myRegistrations.where((r) => r.attended).toList();

  double get totalHours =>
      _myRegistrations.fold(0.0, (sum, r) => sum + r.volunteerHours);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _events = await _repository.fetchEvents();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyRegistrations(String volunteerId) async {
    _registrationsLoading = true;
    notifyListeners();
    try {
      _myRegistrations = await _repository.fetchRegistrationsForVolunteer(volunteerId);
    } finally {
      _registrationsLoading = false;
      notifyListeners();
    }
  }

  bool isRegistered(String eventId) =>
      _myRegistrations.any((r) => r.eventId == eventId);

  EventRegistration? registrationFor(String eventId) {
    for (final EventRegistration registration in _myRegistrations) {
      if (registration.eventId == eventId) return registration;
    }
    return null;
  }

  Future<void> loadNgo(String ngoId) async {
    _ngoLoading = true;
    notifyListeners();
    try {
      _ngoEvents = await _repository.fetchNgoEvents(ngoId);
      _ngoRegistrations = await _repository.fetchRegistrationsForNgo(ngoId);
      _ngoEvents.sort((a, b) => a.date.compareTo(b.date));
    } finally {
      _ngoLoading = false;
      notifyListeners();
    }
  }

  List<EventRegistration> registrationsForEvent(String eventId) {
    return _ngoRegistrations.where((r) => r.eventId == eventId).toList();
  }

  int registeredCountFor(String eventId) => registrationsForEvent(eventId).length;

  Future<bool> saveEvent(VolunteerEvent event, String ngoId) async {
    try {
      await _repository.upsertEvent(event);
      await loadNgo(ngoId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkInVolunteer(EventRegistration registration, {required double hours}) async {
    try {
      final EventRegistration updated = registration.copyWith(
        attended: true,
        volunteerHours: hours,
        status: 'attended',
      );
      await _repository.updateRegistration(updated);
      final int index = _ngoRegistrations.indexWhere((r) => r.id == registration.id);
      if (index >= 0) {
        _ngoRegistrations[index] = updated;
      }
      notifyListeners();

      final AppUser? volunteer = await _users.fetchUser(registration.volunteerId);
      if (volunteer != null) {
        final int newHours = volunteer.totalHours + hours.round();
        await _users.saveUser(volunteer.copyWith(
          totalHours: newHours,
          badges: mergeBadges(volunteer.badges, newHours),
        ));
      }
      await _notifications.create(AppNotification(
        id: 'nt-${DateTime.now().millisecondsSinceEpoch}',
        userId: registration.volunteerId,
        title: 'Check-in complete',
        message: 'Your $hours hours at "${registration.eventTitle}" were logged. Keep up the great work!',
        type: 'event',
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(VolunteerEvent event, {required String volunteerId, required String volunteerName}) async {
    try {
      final EventRegistration registration = await _repository.registerEvent(
        event: event,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
      );
      _myRegistrations.insert(0, registration);
      final int index = _events.indexWhere((e) => e.id == event.id);
      if (index >= 0) {
        _events[index] = event.copyWith(registeredVolunteers: event.registeredVolunteers + 1);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unregister(EventRegistration registration) async {
    try {
      final EventRegistration updated = registration.copyWith(status: 'cancelled');
      await _repository.updateRegistration(updated);
      final int index = _myRegistrations.indexWhere((r) => r.id == registration.id);
      if (index >= 0) {
        _myRegistrations[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}