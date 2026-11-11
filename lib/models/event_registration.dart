import '../core/utils/date_utils.dart';

class EventRegistration {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.volunteerId,
    required this.volunteerName,
    this.ngoId = '',
    this.status = 'registered',
    this.attended = false,
    this.volunteerHours = 0,
    this.registeredAt,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final String volunteerId;
  final String volunteerName;
  final String ngoId;
  final String status;
  final bool attended;
  final double volunteerHours;
  final DateTime? registeredAt;

  EventRegistration copyWith({String? status, bool? attended, double? volunteerHours}) {
    return EventRegistration(
      id: id,
      eventId: eventId,
      eventTitle: eventTitle,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      ngoId: ngoId,
      status: status ?? this.status,
      attended: attended ?? this.attended,
      volunteerHours: volunteerHours ?? this.volunteerHours,
      registeredAt: registeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'ngoId': ngoId,
      'status': status,
      'attended': attended,
      'volunteerHours': volunteerHours,
      'registeredAt': registeredAt ?? DateTime.now(),
    };
  }

  factory EventRegistration.fromMap(Map<String, dynamic> map) {
    return EventRegistration(
      id: map['id'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? 'Event',
      volunteerId: map['volunteerId'] as String? ?? '',
      volunteerName: map['volunteerName'] as String? ?? 'Volunteer',
      ngoId: map['ngoId'] as String? ?? '',
      status: map['status'] as String? ?? 'registered',
      attended: map['attended'] as bool? ?? false,
      volunteerHours: (map['volunteerHours'] as num?)?.toDouble() ?? 0,
      registeredAt: dateTimeFromAny(map['registeredAt']),
    );
  }
}