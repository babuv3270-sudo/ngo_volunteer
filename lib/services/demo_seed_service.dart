import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/application.dart';
import '../models/event_registration.dart';
import '../models/ngo_profile.dart';
import '../models/opportunity.dart';
import '../models/volunteer_event.dart';

class DemoSeedService {
  DemoSeedService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  static const String volunteerEmail = 'demo@ngo.app';
  static const String ngoEmail = 'demo-ngo@ngo.app';
  static const String demoPassword = 'demo1234';

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<void> ensureSeeded() async {
    final String volunteerUid = await _uidForAccount(volunteerEmail, demoPassword);
    final String ngoUid = await _uidForAccount(ngoEmail, demoPassword);
    await _auth.signOut();
    await _auth.signInWithEmailAndPassword(email: volunteerEmail, password: demoPassword);
    await _seedData(volunteerUid, ngoUid);
    await _auth.signOut();
  }

  Future<String> _uidForAccount(String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return credential.user!.uid;
      }
      rethrow;
    }
  }

  Future<void> _seedData(String volunteerUid, String ngoUid) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> signature = {'#demoSeed': true};

    await _db.collection('users').doc(volunteerUid).set({
      ...AppUser(
        uid: volunteerUid,
        name: 'Aarav Shah',
        email: volunteerEmail,
        role: UserRole.volunteer,
        phone: '+919876543210',
        location: 'Chennai',
        skills: const ['Teaching', 'Environment'],
        interests: const ['Education', 'Sustainability'],
        totalHours: 42,
        badges: const ['First Step', '10 Hour Hero', 'Community Star'],
        createdAt: now.subtract(const Duration(days: 120)),
      ).toMap(),
      ...signature,
    });

    await _db.collection('ngos').doc(ngoUid).set({
      ...NgoProfile(
        uid: ngoUid,
        name: 'Green Earth Foundation',
        description: 'Dedicated to environmental conservation and community clean-ups.',
        email: ngoEmail,
        phone: '+919812345678',
        city: 'Chennai',
        address: '27 Lake View Road, Chennai',
        website: 'https://greenearth.example.org',
        createdAt: now.subtract(const Duration(days: 400)),
      ).toMap(),
      ...signature,
    });

    final Opportunity op1 = Opportunity(
      id: 'op-demo-1',
      ngoId: ngoUid,
      ngoName: 'Green Earth Foundation',
      title: 'Beach Clean-up Drive',
      description: 'Join our weekend drive to clean Marina beach and protect marine life. Gloves and bags provided.',
      category: 'Environment',
      requiredSkills: const ['Environment', 'Teamwork'],
      location: 'Marina Beach, Chennai',
      date: now.add(const Duration(days: 3)),
      startTime: '06:00',
      endTime: '09:00',
      requiredVolunteers: 40,
      currentVolunteers: 18,
      createdAt: now.subtract(const Duration(days: 5)),
    );
    final Opportunity op2 = Opportunity(
      id: 'op-demo-2',
      ngoId: ngoUid,
      ngoName: 'Green Earth Foundation',
      title: 'Community Tree Plantation',
      description: 'Plant native saplings across the north zone and help build a greener neighbourhood.',
      category: 'Environment',
      requiredSkills: const ['Environment', 'Teamwork'],
      location: 'Anna Nagar West',
      date: now.add(const Duration(days: 12)),
      startTime: '07:30',
      endTime: '10:30',
      requiredVolunteers: 30,
      currentVolunteers: 4,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    await _db.collection('opportunities').doc(op1.id).set({...op1.toMap(), ...signature});
    await _db.collection('opportunities').doc(op2.id).set({...op2.toMap(), ...signature});

    await _db.collection('applications').doc('ap-demo-1').set({
      ...Application(
        id: 'ap-demo-1',
        opportunityId: op1.id,
        opportunityTitle: op1.title,
        volunteerId: volunteerUid,
        volunteerName: 'Aarav Shah',
        ngoId: ngoUid,
        status: 'pending',
        appliedAt: now.subtract(const Duration(hours: 20)),
      ).toMap(),
      ...signature,
    });

    final VolunteerEvent ev1 = VolunteerEvent(
      id: 'ev-demo-1',
      ngoId: ngoUid,
      ngoName: 'Green Earth Foundation',
      title: 'Eco-Walk & Plastic Audit',
      description: 'A guided neighbourhood walk to collect, count and document single-use plastic waste.',
      date: now.add(const Duration(days: 4)),
      startTime: '08:00',
      endTime: '11:30',
      location: 'Nehru Park',
      maxVolunteers: 25,
      registeredVolunteers: 1,
      createdAt: now.subtract(const Duration(days: 8)),
    );
    final VolunteerEvent ev2 = VolunteerEvent(
      id: 'ev-demo-2',
      ngoId: ngoUid,
      ngoName: 'Green Earth Foundation',
      title: 'Riverfront Restoration',
      description: 'Team up to restore the Adyar riverfront with native grasses and cleaning pathways.',
      date: now.add(const Duration(days: 18)),
      startTime: '06:30',
      endTime: '10:00',
      location: 'Adyar Eco Park',
      maxVolunteers: 35,
      registeredVolunteers: 0,
      createdAt: now.subtract(const Duration(days: 2)),
    );

    await _db.collection('events').doc(ev1.id).set({...ev1.toMap(), ...signature});
    await _db.collection('events').doc(ev2.id).set({...ev2.toMap(), ...signature});

    await _db.collection('eventRegistrations').doc('er-demo-1').set({
      ...EventRegistration(
        id: 'er-demo-1',
        eventId: ev1.id,
        eventTitle: ev1.title,
        ngoId: ngoUid,
        volunteerId: volunteerUid,
        volunteerName: 'Aarav Shah',
        registeredAt: now.subtract(const Duration(days: 3)),
      ).toMap(),
      ...signature,
    });

    final List<AppNotification> notifications = [
      AppNotification(
        id: 'nt-demo-v1',
        userId: volunteerUid,
        title: 'Application pending',
        message: 'Your application for Beach Clean-up Drive is awaiting review.',
        type: 'application',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'nt-demo-v2',
        userId: volunteerUid,
        title: 'Upcoming event',
        message: 'Eco-Walk & Plastic Audit starts in 4 days at Nehru Park, 08:00.',
        type: 'event',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 26)),
      ),
      AppNotification(
        id: 'nt-demo-n1',
        userId: ngoUid,
        title: 'New application received',
        message: 'Aarav Shah applied for Beach Clean-up Drive.',
        type: 'application',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'nt-demo-n2',
        userId: ngoUid,
        title: 'Event coming up',
        message: 'Eco-Walk & Plastic Audit is in 4 days. Check your volunteer registrations.',
        type: 'event',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];

    final WriteBatch batch = _db.batch();
    for (final AppNotification notification in notifications) {
      batch.set(_db.collection('notifications').doc(notification.id), {
        ...notification.toMap(),
        ...signature,
      });
    }
    await batch.commit();
  }
}