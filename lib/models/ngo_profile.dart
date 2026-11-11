import '../core/utils/date_utils.dart';

class NgoProfile {
  const NgoProfile({
    required this.uid,
    required this.name,
    this.description,
    this.logo,
    this.website,
    this.address,
    this.city,
    this.email,
    this.phone,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String? description;
  final String? logo;
  final String? website;
  final String? address;
  final String? city;
  final String? email;
  final String? phone;
  final DateTime? createdAt;

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    final String buffer = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return buffer.isEmpty ? '?' : buffer.toUpperCase();
  }

  NgoProfile copyWith({
    String? uid,
    String? name,
    String? description,
    String? logo,
    String? website,
    String? address,
    String? city,
    String? email,
    String? phone,
  }) {
    return NgoProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'logo': logo,
      'website': website,
      'address': address,
      'city': city,
      'email': email,
      'phone': phone,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  factory NgoProfile.fromMap(Map<String, dynamic> map) {
    return NgoProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      logo: map['logo'] as String?,
      website: map['website'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      createdAt: dateTimeFromAny(map['createdAt']),
    );
  }
}