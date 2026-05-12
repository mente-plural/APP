class UserModel {
  final String id;
  final String? firebaseUid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final String? profileType;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    this.profileType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? map['uuid'] ?? '').toString(),
      firebaseUid: map['firebaseUid']?.toString(),
      email: (map['email'] ?? '').toString(),
      name: map['name']?.toString(),
      phone: map['phone']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      profileType:
          map['profile_type']?.toString() ?? map['profileType']?.toString(),
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDate(map['updated_at'] ?? map['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'profile_type': profileType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? profileType,
  }) {
    return UserModel(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      profileType: profileType ?? this.profileType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
