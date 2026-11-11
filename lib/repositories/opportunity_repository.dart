import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firebase_config.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../services/mock_backend.dart';
import 'firestore_utils.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> fetchOpportunities();
  Future<List<Opportunity>> fetchNgoOpportunities(String ngoId);
  Future<void> upsertOpportunity(Opportunity opportunity);
  Future<List<Application>> fetchApplicationsForVolunteer(String volunteerId);
  Future<List<Application>> fetchApplicationsForNgo(String ngoId);
  Future<Application> createApplication({
    required Opportunity opportunity,
    required String volunteerId,
    required String volunteerName,
  });
  Future<void> updateApplication(Application application);
}

class OpportunityRepositoryFactory {
  static OpportunityRepository create() {
    return FirebaseConfig.isConfigured
        ? FirebaseOpportunityRepository()
        : DemoOpportunityRepository();
  }
}

class FirebaseOpportunityRepository implements OpportunityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    final QuerySnapshot snapshot = await _db.collection('opportunities').get();
    return snapshot.docs
        .map((doc) => Opportunity.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<List<Opportunity>> fetchNgoOpportunities(String ngoId) async {
    final QuerySnapshot snapshot = await _db
        .collection('opportunities')
        .where('ngoId', isEqualTo: ngoId)
        .get();
    return snapshot.docs
        .map((doc) => Opportunity.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<void> upsertOpportunity(Opportunity opportunity) async {
    if (opportunity.id.isEmpty) {
      final String id = _db.collection('opportunities').doc().id;
      await _db.collection('opportunities').doc(id).set(opportunity.toMap());
    } else {
      await _db
          .collection('opportunities')
          .doc(opportunity.id)
          .set(opportunity.toMap(), SetOptions(merge: true));
    }
  }

  @override
  Future<List<Application>> fetchApplicationsForVolunteer(String volunteerId) async {
    final QuerySnapshot snapshot = await _db
        .collection('applications')
        .where('volunteerId', isEqualTo: volunteerId)
        .get();
    return snapshot.docs
        .map((doc) => Application.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<List<Application>> fetchApplicationsForNgo(String ngoId) async {
    final QuerySnapshot snapshot = await _db
        .collection('applications')
        .where('ngoId', isEqualTo: ngoId)
        .get();
    return snapshot.docs
        .map((doc) => Application.fromMap(firestoreDocMap(doc.data(), id: doc.id)))
        .toList();
  }

  @override
  Future<Application> createApplication({
    required Opportunity opportunity,
    required String volunteerId,
    required String volunteerName,
  }) async {
    final String id = _db.collection('applications').doc().id;
    final Application application = Application(
      id: id,
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      ngoId: opportunity.ngoId,
    );
    await _db.collection('applications').doc(id).set(application.toMap());
    await _db.collection('opportunities').doc(opportunity.id).update({
      'currentVolunteers': FieldValue.increment(1),
    });
    return application;
  }

  @override
  Future<void> updateApplication(Application application) async {
    await _db.collection('applications').doc(application.id).set(
      application.toMap(),
      SetOptions(merge: true),
    );
  }
}

class DemoOpportunityRepository implements OpportunityRepository {
  final MockBackend _backend = MockBackend.instance;

  @override
  Future<List<Opportunity>> fetchOpportunities() async =>
      List<Opportunity>.from(_backend.opportunities);

  @override
  Future<List<Opportunity>> fetchNgoOpportunities(String ngoId) async =>
      _backend.opportunities.where((o) => o.ngoId == ngoId).toList();

  @override
  Future<void> upsertOpportunity(Opportunity opportunity) async {
    final int index = _backend.opportunities.indexWhere((o) => o.id == opportunity.id);
    if (index >= 0) {
      _backend.opportunities[index] = opportunity;
    } else {
      _backend.opportunities.add(opportunity);
    }
  }

  @override
  Future<List<Application>> fetchApplicationsForVolunteer(String volunteerId) async =>
      _backend.applications.where((a) => a.volunteerId == volunteerId).toList();

  @override
  Future<List<Application>> fetchApplicationsForNgo(String ngoId) async =>
      _backend.applications.where((a) => a.ngoId == ngoId).toList();

  @override
  Future<Application> createApplication({
    required Opportunity opportunity,
    required String volunteerId,
    required String volunteerName,
  }) async {
    final Application application = Application(
      id: 'ap-${DateTime.now().millisecondsSinceEpoch}',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      ngoId: opportunity.ngoId,
    );
    _backend.applications.add(application);
    final int oppIndex = _backend.opportunities.indexWhere((o) => o.id == opportunity.id);
    if (oppIndex >= 0) {
      _backend.opportunities[oppIndex] = opportunity.copyWith(currentVolunteers: opportunity.currentVolunteers + 1);
    }
    return application;
  }

  @override
  Future<void> updateApplication(Application application) async {
    final int index = _backend.applications.indexWhere((a) => a.id == application.id);
    if (index >= 0) {
      _backend.applications[index] = application;
    }
  }
}