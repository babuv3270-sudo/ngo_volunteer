import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firebase_config.dart';
import '../models/event_registration.dart';
import '../models/volunteer_event.dart';
import '../services/mock_backend.dart';
import 'firestore_utils.dart';

abstract class EventRepository {
  Future<List<VolunteerEvent>> fetchEvents();
  Future<List<VolunteerEvent>> fetchNgoEvents(String ngoId);
  Future<void> upsertEvent(VolunteerEvent event);
  Future<List<EventRegistration>> fetchRegistrationsForVolunteer(String volunteerId);
  Future<List<EventRegistration>> fetchRegistrationsForNgo(String ngoId);
  Future<EventRegistration> registerEvent({
    required VolunteerEvent event,
    required String volunteerId,
    required String volunteerName,
  });
  Future<void> updateRegistration(EventRegistration registration);
}

class EventRepositoryFactory {
  static EventRepository create() {
    return FirebaseConfig.isConfigured ? FirebaseEventRepository() : DemoEventRepository();
  }
}

class FirebaseEventRepository implements EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<VolunteerEvent>> fetchEvents() async {
    final QuerySnapshot snapshot = await _db.collection('events').get();
    return snapshot.docs
        .map((doc) => VolunteerEvent.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<List<VolunteerEvent>> fetchNgoEvents(String ngoId) async {
    final QuerySnapshot snapshot = await _db.collection('events').where('ngoId', isEqualTo: ngoId).get();
    return snapshot.docs
        .map((doc) => VolunteerEvent.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<void> upsertEvent(VolunteerEvent event) async {
    if (event.id.isEmpty) {
      final String id = _db.collection('events').doc().id;
      await _db.collection('events').doc(id).set(event.toMap());
    } else {
      await _db.collection('events').doc(event.id).set(event.toMap(), SetOptions(merge: true));
    }
  }

  @override
  Future<List<EventRegistration>> fetchRegistrationsForVolunteer(String volunteerId) async {
    final QuerySnapshot snapshot = await _db
        .collection('eventRegistrations')
        .where('volunteerId', isEqualTo: volunteerId)
        .get();
    return snapshot.docs
        .map((doc) => EventRegistration.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<List<EventRegistration>> fetchRegistrationsForNgo(String ngoId) async {
    final QuerySnapshot snapshot = await _db
        .collection('eventRegistrations')
        .where('ngoId', isEqualTo: ngoId)
        .get();
    return snapshot.docs
        .map((doc) => EventRegistration.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<EventRegistration> registerEvent({
    required VolunteerEvent event,
    required String volunteerId,
    required String volunteerName,
  }) async {
    final String id = _db.collection('eventRegistrations').doc().id;
    final EventRegistration registration = EventRegistration(
      id: id,
      eventId: event.id,
      eventTitle: event.title,
      ngoId: event.ngoId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
    );
    await _db.collection('eventRegistrations').doc(id).set(registration.toMap());
    await _db.collection('events').doc(event.id).update({
      'registeredVolunteers': FieldValue.increment(1),
    });
    return registration;
  }

  @override
  Future<void> updateRegistration(EventRegistration registration) async {
    await _db.collection('eventRegistrations').doc(registration.id).set(
      registration.toMap(),
      SetOptions(merge: true),
    );
  }
}

class DemoEventRepository implements EventRepository {
  final MockBackend _backend = MockBackend.instance;

  @override
  Future<List<VolunteerEvent>> fetchEvents() async => List<VolunteerEvent>.from(_backend.events);

  @override
  Future<List<VolunteerEvent>> fetchNgoEvents(String ngoId) async =>
      _backend.events.where((e) => e.ngoId == ngoId).toList();

  @override
  Future<void> upsertEvent(VolunteerEvent event) async {
    final int index = _backend.events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      _backend.events[index] = event;
    } else {
      _backend.events.add(event);
    }
  }

  @override
  Future<List<EventRegistration>> fetchRegistrationsForVolunteer(String volunteerId) async =>
      _backend.eventRegistrations.where((r) => r.volunteerId == volunteerId).toList();

  @override
  Future<List<EventRegistration>> fetchRegistrationsForNgo(String ngoId) async =>
      _backend.eventRegistrations.where((r) => r.ngoId == ngoId).toList();

  @override
  Future<EventRegistration> registerEvent({
    required VolunteerEvent event,
    required String volunteerId,
    required String volunteerName,
  }) async {
    final EventRegistration registration = EventRegistration(
      id: 'er-${DateTime.now().millisecondsSinceEpoch}',
      eventId: event.id,
      eventTitle: event.title,
      ngoId: event.ngoId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
    );
    _backend.eventRegistrations.add(registration);
    final int eventIndex = _backend.events.indexWhere((e) => e.id == event.id);
    if (eventIndex >= 0) {
      _backend.events[eventIndex] = event.copyWith(registeredVolunteers: event.registeredVolunteers + 1);
    }
    return registration;
  }

  @override
  Future<void> updateRegistration(EventRegistration registration) async {
    final int index = _backend.eventRegistrations.indexWhere((r) => r.id == registration.id);
    if (index >= 0) {
      _backend.eventRegistrations[index] = registration;
    }
  }
}