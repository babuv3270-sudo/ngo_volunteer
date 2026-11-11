import '../core/utils/date_utils.dart';

enum UserRole {
  volunteer,
  ngo;

  static UserRole fromName(String? value) {
    if (value == null) return UserRole.volunteer;
    return UserRole.values.asNameMap()[value] ?? UserRole.volunteer;
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.location,
    this.skills = const [],
    this.interests = const [],
    this.totalHours = 0,
    this.badges = const [],
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? profileImage;
  final String? location;
  final List<String> skills;
  final List<String> interests;
  final int totalHours;
  final List<String> badges;
  final DateTime? createdAt;

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    final String buffer = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return buffer.isEmpty ? '?' : buffer.toUpperCase();
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? profileImage,
    String? location,
    List<String>? skills,
    List<String>? interests,
    int? totalHours,
    List<String>? badges,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      totalHours: totalHours ?? this.totalHours,
      badges: badges ?? this.badges,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'profileImage': profileImage,
      'location': location,
      'skills': skills,
      'interests': interests,
      'totalHours': totalHours,
      'badges': badges,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromName(map['role'] as String?),
      phone: map['phone'] as String?,
      profileImage: map['profileImage'] as String?,
      location: map['location'] as String?,
      skills: _stringList(map['skills']),
      interests: _stringList(map['interests']),
      totalHours: (map['totalHours'] as num?)?.toInt() ?? 0,
      badges: _stringList(map['badges']),
      createdAt: _dateFromAny(map['createdAt']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }

  static DateTime? _dateFromAny(dynamic value) => dateTimeFromAny(value);
}