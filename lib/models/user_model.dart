class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      firebaseUid: map['firebaseUid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['created_at'] is String 
          ? DateTime.parse(map['created_at']) 
          : map['created_at'] as DateTime,
      updatedAt: map['updated_at'] is String 
          ? DateTime.parse(map['updated_at']) 
          : map['updated_at'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
