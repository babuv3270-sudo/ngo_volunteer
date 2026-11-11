import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/application.dart';
import '../models/app_notification.dart';
import '../models/opportunity.dart';
import '../repositories/notification_repository.dart';
import '../repositories/opportunity_repository.dart';

class OpportunityProvider extends ChangeNotifier {
  OpportunityProvider({OpportunityRepository? repository, NotificationRepository? notifications})
      : _repository = repository ?? OpportunityRepositoryFactory.create(),
        _notifications = notifications ?? NotificationRepositoryFactory.create();

  final OpportunityRepository _repository;
  final NotificationRepository _notifications;

  List<Opportunity> _all = [];
  List<Application> _myApplications = [];
  List<Opportunity> _ngoOpportunities = [];
  List<Application> _ngoApplications = [];
  bool _loading = false;
  bool _applicationsLoading = false;
  bool _ngoLoading = false;
  String _query = '';
  String? _category;
  String _sort = AppSortOptions.recent;

  List<Opportunity> get all => _all;
  List<Application> get myApplications => _myApplications;
  List<Opportunity> get ngoOpportunities => _ngoOpportunities;
  List<Application> get ngoApplications => _ngoApplications;
  bool get loading => _loading;
  bool get applicationsLoading => _applicationsLoading;
  bool get ngoLoading => _ngoLoading;
  String? get category => _category;
  String get sort => _sort;
  bool get hasActiveFilters => _query.trim().isNotEmpty || _category != null || _sort != AppSortOptions.recent;

  List<Opportunity> get display {
    final String q = _query.trim().toLowerCase();
    final List<Opportunity> filtered = _all.where((opportunity) {
      bool ok = true;
      if (q.isNotEmpty) {
        ok = opportunity.title.toLowerCase().contains(q) ||
            opportunity.description.toLowerCase().contains(q) ||
            opportunity.ngoName.toLowerCase().contains(q) ||
            opportunity.location.toLowerCase().contains(q) ||
            opportunity.category.toLowerCase().contains(q);
      }
      if (ok && _category != null) {
        ok = opportunity.category == _category;
      }
      return ok;
    }).toList();

    switch (_sort) {
      case AppSortOptions.popular:
        filtered.sort((a, b) => b.fillRatio.compareTo(a.fillRatio));
        break;
      case AppSortOptions.upcoming:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      default:
        filtered.sort((a, b) =>
            (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    }
    return filtered;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _all = await _repository.fetchOpportunities();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyApplications(String volunteerId) async {
    _applicationsLoading = true;
    notifyListeners();
    try {
      _myApplications = await _repository.fetchApplicationsForVolunteer(volunteerId);
      _myApplications.sort((a, b) =>
          (b.appliedAt ?? DateTime(2000)).compareTo(a.appliedAt ?? DateTime(2000)));
    } finally {
      _applicationsLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  void setSort(String value) {
    _sort = value;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    _sort = AppSortOptions.recent;
    notifyListeners();
  }

  bool hasApplied(String opportunityId) =>
      _myApplications.any((a) => a.opportunityId == opportunityId);

  Application? applicationFor(String opportunityId) {
    for (final Application application in _myApplications) {
      if (application.opportunityId == opportunityId) return application;
    }
    return null;
  }

  List<Opportunity> recommendations({int limit = 5}) {
    final List<Opportunity> open = _all.where((o) => o.isOpen).toList();
    open.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(2000)) ?? 0);
    return open.take(limit).toList();
  }

  Future<void> loadNgo(String ngoId) async {
    _ngoLoading = true;
    notifyListeners();
    try {
      _ngoOpportunities = await _repository.fetchNgoOpportunities(ngoId);
      _ngoApplications = await _repository.fetchApplicationsForNgo(ngoId);
      _ngoOpportunities.sort((a, b) =>
          (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    } finally {
      _ngoLoading = false;
      notifyListeners();
    }
  }

  List<Application> applicationsForOpportunity(String opportunityId) {
    return _ngoApplications.where((a) => a.opportunityId == opportunityId).toList();
  }

  int pendingCountFor(String opportunityId) {
    return _ngoApplications.where((a) => a.opportunityId == opportunityId && a.status == 'pending').length;
  }

  Future<bool> saveOpportunity(Opportunity opportunity, String ngoId) async {
    try {
      await _repository.upsertOpportunity(opportunity);
      await loadNgo(ngoId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateApplicationStatus(Application application, String status) async {
    try {
      final Application updated = application.copyWith(status: status);
      await _repository.updateApplication(updated);
      final int index = _ngoApplications.indexWhere((a) => a.id == application.id);
      if (index >= 0) {
        _ngoApplications[index] = updated;
      }
      notifyListeners();
      if (status == 'approved' || status == 'rejected') {
        await _notifications.create(AppNotification(
          id: 'nt-${DateTime.now().millisecondsSinceEpoch}',
          userId: application.volunteerId,
          title: status == 'approved' ? 'Application approved' : 'Application not selected',
          message: status == 'approved'
              ? 'Good news! You have been selected for "${application.opportunityTitle}".'
              : 'Thank you for applying to "${application.opportunityTitle}". The organization went ahead with other applicants this time.',
          type: status == 'approved' ? 'application' : 'general',
        ));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> apply(Opportunity opportunity, {required String volunteerId, required String volunteerName}) async {
    try {
      final Application application = await _repository.createApplication(
        opportunity: opportunity,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
      );
      _myApplications.insert(0, application);
      final int index = _all.indexWhere((o) => o.id == opportunity.id);
      if (index >= 0) {
        _all[index] = opportunity.copyWith(currentVolunteers: opportunity.currentVolunteers + 1);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelApplication(Application application) async {
    try {
      final Application cancelled = application.copyWith(status: 'cancelled');
      await _repository.updateApplication(cancelled);
      final int index = _myApplications.indexWhere((a) => a.id == application.id);
      if (index >= 0) {
        _myApplications[index] = cancelled;
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}