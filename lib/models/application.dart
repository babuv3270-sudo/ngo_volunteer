import '../core/utils/date_utils.dart';

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.volunteerId,
    required this.volunteerName,
    required this.ngoId,
    this.status = 'pending',
    this.appliedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String volunteerId;
  final String volunteerName;
  final String ngoId;
  final String status;
  final DateTime? appliedAt;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';

  Application copyWith({String? status}) {
    return Application(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      ngoId: ngoId,
      status: status ?? this.status,
      appliedAt: appliedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'ngoId': ngoId,
      'status': status,
      'appliedAt': appliedAt ?? DateTime.now(),
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as String? ?? '',
      opportunityId: map['opportunityId'] as String? ?? '',
      opportunityTitle: map['opportunityTitle'] as String? ?? 'Opportunity',
      volunteerId: map['volunteerId'] as String? ?? '',
      volunteerName: map['volunteerName'] as String? ?? 'Volunteer',
      ngoId: map['ngoId'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      appliedAt: dateTimeFromAny(map['appliedAt']),
    );
  }
}