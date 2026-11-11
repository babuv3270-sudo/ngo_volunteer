import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/application.dart';
import '../models/auth_user.dart';
import '../models/event_registration.dart';
import '../models/ngo_profile.dart';
import '../models/opportunity.dart';
import '../models/volunteer_event.dart';

class MockBackend {
  MockBackend._() {
    _seed();
  }

  static final MockBackend instance = MockBackend._();

  final List<AppUser> users = [];
  final List<NgoProfile> ngos = [];
  final List<Opportunity> opportunities = [];
  final List<VolunteerEvent> events = [];
  final List<Application> applications = [];
  final List<EventRegistration> eventRegistrations = [];
  final List<AppNotification> notifications = [];
  AuthUser? current;

  AppUser? findUser(String uid) {
    for (final AppUser user in users) {
      if (user.uid == uid) return user;
    }
    return null;
  }

  AppUser? findUserByEmail(String email) {
    for (final AppUser user in users) {
      if (user.email.toLowerCase() == email.toLowerCase()) return user;
    }
    return null;
  }

  NgoProfile? findNgo(String uid) {
    for (final NgoProfile ngo in ngos) {
      if (ngo.uid == uid) return ngo;
    }
    return null;
  }

  NgoProfile? findNgoByEmail(String email) {
    for (final NgoProfile ngo in ngos) {
      if (ngo.email?.toLowerCase() == email.toLowerCase()) return ngo;
    }
    return null;
  }

  void _seed() {
    users.add(AppUser(
      uid: 'v-demo-1',
      name: 'Aarav Shah',
      email: 'demo@ngo.app',
      role: UserRole.volunteer,
      phone: '+919876543210',
      location: 'Chennai',
      skills: const ['Teaching', 'Environment'],
      interests: const ['Education', 'Sustainability'],
      totalHours: 42,
      badges: const ['First Step', '10 Hour Hero', 'Community Star'],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ));

    ngos.add(NgoProfile(
      uid: 'n-demo-1',
      name: 'Green Earth Foundation',
      description: 'Dedicated to environmental conservation and community clean-ups.',
      email: 'demo-ngo@ngo.app',
      phone: '+919812345678',
      city: 'Chennai',
      address: '27 Lake View Road, Chennai',
      website: 'https://greenearth.example.org',
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
    ));

    ngos.add(NgoProfile(
      uid: 'n-demo-2',
      name: 'Bright Path Education',
      description: 'Empowering underprivileged children through after-school learning programs.',
      email: 'hello@brightpath.example.org',
      phone: '+919876543211',
      city: 'Chennai',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ));

    ngos.add(NgoProfile(
      uid: 'n-demo-3',
      name: 'CareWave Health',
      description: 'Community health camps, awareness drives and first-aid training.',
      email: 'team@carewave.example.org',
      phone: '+919876543212',
      city: 'Chennai',
      createdAt: DateTime.now().subtract(const Duration(days: 260)),
    ));

    _seedOpportunities();
    _seedEvents();
    _seedApplications();
    _seedNotifications();
  }

  void _seedOpportunities() {
    final DateTime base = DateTime.now();

    opportunities.addAll([
      Opportunity(
        id: 'op-1',
        ngoId: 'n-demo-1',
        ngoName: 'Green Earth Foundation',
        title: 'Beach Clean-up Drive',
        description: 'Join our weekend drive to clean Marina beach and protect marine life. Gloves and bags provided.',
        category: 'Environment',
        requiredSkills: const ['Environment', 'Teamwork'],
        location: 'Marina Beach, Chennai',
        date: base.add(const Duration(days: 3)),
        startTime: '06:00',
        endTime: '09:00',
        requiredVolunteers: 40,
        currentVolunteers: 18,
        createdAt: base.subtract(const Duration(days: 5)),
      ),
      Opportunity(
        id: 'op-2',
        ngoId: 'n-demo-2',
        ngoName: 'Bright Path Education',
        title: 'After-School Tutoring',
        description: 'Teach English and Maths to children aged 6–12. Lesson plans are provided.',
        category: 'Teaching',
        requiredSkills: const ['Teaching', 'Communication'],
        location: 'Kodambakkam Community Hall',
        date: base.add(const Duration(days: 6)),
        startTime: '16:00',
        endTime: '18:30',
        requiredVolunteers: 12,
        currentVolunteers: 11,
        createdAt: base.subtract(const Duration(days: 3)),
      ),
      Opportunity(
        id: 'op-3',
        ngoId: 'n-demo-3',
        ngoName: 'CareWave Health',
        title: 'Blood Donation Camp',
        description: 'Help register donors and manage the queue during our monthly blood donation camp.',
        category: 'Health',
        requiredSkills: const ['Health', 'Organization'],
        location: 'Government Hospital, Egmore',
        date: base.add(const Duration(days: 9)),
        startTime: '09:00',
        endTime: '14:00',
        requiredVolunteers: 15,
        currentVolunteers: 3,
        createdAt: base.subtract(const Duration(days: 2)),
      ),
      Opportunity(
        id: 'op-4',
        ngoId: 'n-demo-1',
        ngoName: 'Green Earth Foundation',
        title: 'Community Tree Plantation',
        description: 'Plant native saplings across the north zone and help build a greener neighbourhood.',
        category: 'Environment',
        requiredSkills: const ['Environment', 'Teamwork'],
        location: 'Anna Nagar West',
        date: base.add(const Duration(days: 12)),
        startTime: '07:30',
        endTime: '10:30',
        requiredVolunteers: 30,
        currentVolunteers: 4,
        createdAt: base.subtract(const Duration(days: 1)),
      ),
      Opportunity(
        id: 'op-5',
        ngoId: 'n-demo-2',
        ngoName: 'Bright Path Education',
        title: 'Career Guidance Workshop',
        description: 'Mentor high-school students on career paths and share your professional journey.',
        category: 'Teaching',
        requiredSkills: const ['Teaching', 'Communication'],
        location: 'Mylapore Youth Center',
        date: base.add(const Duration(days: 15)),
        startTime: '10:00',
        endTime: '13:00',
        requiredVolunteers: 8,
        currentVolunteers: 2,
        createdAt: base.subtract(const Duration(hours: 20)),
      ),
      Opportunity(
        id: 'op-6',
        ngoId: 'n-demo-3',
        ngoName: 'CareWave Health',
        title: 'First-Aid Training Partner',
        description: 'Assist certified trainers during free first-aid certification sessions for residents.',
        category: 'Health',
        requiredSkills: const ['Health'],
        location: 'T Nagar Community Center',
        date: base.add(const Duration(days: 20)),
        startTime: '11:00',
        endTime: '16:00',
        requiredVolunteers: 6,
        currentVolunteers: 1,
        createdAt: base.subtract(const Duration(hours: 10)),
      ),
    ]);
  }

  void _seedEvents() {
    final DateTime base = DateTime.now();

    events.addAll([
      VolunteerEvent(
        id: 'ev-1',
        ngoId: 'n-demo-1',
        ngoName: 'Green Earth Foundation',
        title: 'Eco-Walk & Plastic Audit',
        description: 'A guided neighbourhood walk to collect, count and document single-use plastic waste.',
        date: base.add(const Duration(days: 4)),
        startTime: '08:00',
        endTime: '11:30',
        location: 'Nehru Park',
        maxVolunteers: 25,
        registeredVolunteers: 14,
        createdAt: base.subtract(const Duration(days: 8)),
      ),
      VolunteerEvent(
        id: 'ev-2',
        ngoId: 'n-demo-2',
        ngoName: 'Bright Path Education',
        title: 'Storytelling Saturday',
        description: 'An hour of stories, rhymes and fun activities for young learners.',
        date: base.add(const Duration(days: 7)),
        startTime: '11:00',
        endTime: '12:30',
        location: 'Kodambakkam Community Hall',
        maxVolunteers: 10,
        registeredVolunteers: 6,
        createdAt: base.subtract(const Duration(days: 6)),
      ),
      VolunteerEvent(
        id: 'ev-3',
        ngoId: 'n-demo-3',
        ngoName: 'CareWave Health',
        title: 'Community Health Camp',
        description: 'Free BP, sugar and BMI check-ups for the elderly. Volunteers manage registrations.',
        date: base.add(const Duration(days: 11)),
        startTime: '09:00',
        endTime: '13:00',
        location: 'Egmore Old Age Home',
        maxVolunteers: 20,
        registeredVolunteers: 2,
        createdAt: base.subtract(const Duration(days: 4)),
      ),
      VolunteerEvent(
        id: 'ev-4',
        ngoId: 'n-demo-1',
        ngoName: 'Green Earth Foundation',
        title: 'Riverfront Restoration',
        description: 'Team up to restore the Adyar riverfront with native grasses and cleaning pathways.',
        date: base.add(const Duration(days: 18)),
        startTime: '06:30',
        endTime: '10:00',
        location: 'Adyar Eco Park',
        maxVolunteers: 35,
        registeredVolunteers: 0,
        createdAt: base.subtract(const Duration(days: 2)),
      ),
      VolunteerEvent(
        id: 'ev-5',
        ngoId: 'n-demo-2',
        ngoName: 'Bright Path Education',
        title: 'Science Fair Helpers',
        description: 'Support students setting up science exhibits and guide visitors around stalls.',
        date: base.subtract(const Duration(days: 10)),
        startTime: '10:00',
        endTime: '15:00',
        location: 'Alandur Assembly Hall',
        maxVolunteers: 12,
        registeredVolunteers: 12,
        status: 'completed',
        createdAt: base.subtract(const Duration(days: 30)),
      ),
    ]);
  }

  void _seedApplications() {
    applications.addAll([
      Application(
        id: 'ap-1',
        opportunityId: 'op-2',
        opportunityTitle: 'After-School Tutoring',
        volunteerId: 'v-demo-1',
        volunteerName: 'Aarav Shah',
        ngoId: 'n-demo-2',
        status: 'approved',
        appliedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Application(
        id: 'ap-2',
        opportunityId: 'op-3',
        opportunityTitle: 'Blood Donation Camp',
        volunteerId: 'v-demo-1',
        volunteerName: 'Aarav Shah',
        ngoId: 'n-demo-3',
        status: 'pending',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    eventRegistrations.addAll([
      EventRegistration(
        id: 'er-1',
        eventId: 'ev-1',
        eventTitle: 'Eco-Walk & Plastic Audit',
        ngoId: 'n-demo-1',
        volunteerId: 'v-demo-1',
        volunteerName: 'Aarav Shah',
        registeredAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      EventRegistration(
        id: 'er-2',
        eventId: 'ev-5',
        eventTitle: 'Science Fair Helpers',
        ngoId: 'n-demo-2',
        volunteerId: 'v-demo-1',
        volunteerName: 'Aarav Shah',
        attended: true,
        volunteerHours: 5,
        registeredAt: DateTime.now().subtract(const Duration(days: 21)),
      ),
    ]);
  }

  void _seedNotifications() {
    notifications.addAll([
      AppNotification(
        id: 'nt-1',
        userId: 'v-demo-1',
        title: 'Application approved 🎉',
        message: 'Your application for After-School Tutoring was approved. See you there!',
        type: 'application',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'nt-2',
        userId: 'v-demo-1',
        title: 'Upcoming event reminder',
        message: 'Eco-Walk & Plastic Audit starts in 4 days at Nehru Park, 08:00.',
        type: 'event',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      ),
      AppNotification(
        id: 'nt-3',
        userId: 'v-demo-1',
        title: 'Hours logged ✅',
        message: '5 volunteer hours were added for Science Fair Helpers.',
        type: 'hours',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      AppNotification(
        id: 'nt-n1',
        userId: 'n-demo-1',
        title: 'New application received',
        message: 'Aarav Shah applied for Beach Clean-up Drive.',
        type: 'application',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'nt-n2',
        userId: 'n-demo-1',
        title: 'Event coming up',
        message: 'Eco-Walk & Plastic Audit is in 4 days. Check your volunteer registrations.',
        type: 'event',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);
    notifications.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
  }
}