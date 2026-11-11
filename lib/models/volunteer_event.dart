import '../core/utils/date_utils.dart';

class VolunteerEvent {
  const VolunteerEvent({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.startTime = '10:00',
    this.endTime = '15:00',
    this.maxVolunteers = 20,
    this.registeredVolunteers = 0,
    this.image,
    this.status = 'upcoming',
    this.createdAt,
  });

  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final int maxVolunteers;
  final int registeredVolunteers;
  final String? image;
  final String status;
  final DateTime? createdAt;

  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isFull => registeredVolunteers >= maxVolunteers;

  VolunteerEvent copyWith({int? registeredVolunteers, String? status}) {
    return VolunteerEvent(
      id: id,
      ngoId: ngoId,
      ngoName: ngoName,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      location: location,
      maxVolunteers: maxVolunteers,
      registeredVolunteers: registeredVolunteers ?? this.registeredVolunteers,
      image: image,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'title': title,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'maxVolunteers': maxVolunteers,
      'registeredVolunteers': registeredVolunteers,
      'image': image,
      'status': status,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  factory VolunteerEvent.fromMap(Map<String, dynamic> map) {
    return VolunteerEvent(
      id: map['id'] as String? ?? '',
      ngoId: map['ngoId'] as String? ?? '',
      ngoName: map['ngoName'] as String? ?? 'Unknown NGO',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: dateTimeFromAny(map['date']) ?? DateTime.now(),
      startTime: map['startTime'] as String? ?? '10:00',
      endTime: map['endTime'] as String? ?? '15:00',
      location: map['location'] as String? ?? '',
      maxVolunteers: (map['maxVolunteers'] as num?)?.toInt() ?? 20,
      registeredVolunteers: (map['registeredVolunteers'] as num?)?.toInt() ?? 0,
      image: map['image'] as String?,
      status: map['status'] as String? ?? 'upcoming',
      createdAt: dateTimeFromAny(map['createdAt']),
    );
  }
}