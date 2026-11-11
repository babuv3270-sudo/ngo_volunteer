import '../core/utils/date_utils.dart';

class Opportunity {
  const Opportunity({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.requiredVolunteers,
    this.requiredSkills = const [],
    this.currentVolunteers = 0,
    this.image,
    this.status = 'open',
    this.createdAt,
  });

  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int requiredVolunteers;
  final int currentVolunteers;
  final String? image;
  final String status;
  final DateTime? createdAt;

  bool get isOpen => status.toLowerCase() == 'open';
  double get fillRatio => requiredVolunteers == 0 ? 0 : (currentVolunteers / requiredVolunteers).clamp(0.0, 1.0);
  bool get isFilled => currentVolunteers >= requiredVolunteers;

  Opportunity copyWith({int? currentVolunteers, String? status}) {
    return Opportunity(
      id: id,
      ngoId: ngoId,
      ngoName: ngoName,
      title: title,
      description: description,
      category: category,
      requiredSkills: requiredSkills,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
      requiredVolunteers: requiredVolunteers,
      currentVolunteers: currentVolunteers ?? this.currentVolunteers,
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
      'category': category,
      'requiredSkills': requiredSkills,
      'location': location,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'requiredVolunteers': requiredVolunteers,
      'currentVolunteers': currentVolunteers,
      'image': image,
      'status': status,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  factory Opportunity.fromMap(Map<String, dynamic> map) {
    return Opportunity(
      id: map['id'] as String? ?? '',
      ngoId: map['ngoId'] as String? ?? '',
      ngoName: map['ngoName'] as String? ?? 'Unknown NGO',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      requiredSkills: _stringList(map['requiredSkills']),
      location: map['location'] as String? ?? '',
      date: dateTimeFromAny(map['date']) ?? DateTime.now(),
      startTime: map['startTime'] as String? ?? '09:00',
      endTime: map['endTime'] as String? ?? '13:00',
      requiredVolunteers: (map['requiredVolunteers'] as num?)?.toInt() ?? 1,
      currentVolunteers: (map['currentVolunteers'] as num?)?.toInt() ?? 0,
      image: map['image'] as String?,
      status: map['status'] as String? ?? 'open',
      createdAt: dateTimeFromAny(map['createdAt']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }
}