import 'user_preferences.dart';

class UserModel {
  final String id;
  final String? firebaseUid;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Tenta extrair o ID de várias fontes comuns
    final userId = (map['id'] ?? map['uuid'] ?? map['userId'] ?? map['firebaseUid'] ?? map['firebase_uid'] ?? '').toString();
    
    // Se o email vier vazio, tenta buscar de campos alternativos
    final email = (map['email'] ?? map['userEmail'] ?? map['user_email'] ?? '').toString();

    return UserModel(
      id: userId,
      firebaseUid: (map['firebaseUid'] ?? map['firebase_uid'] ?? map['uid'] ?? map['firebase_id'] ?? '').toString(),
      email: email,
      name: (map['name'] ?? map['fullName'] ?? map['full_name'] ?? map['display_name'])?.toString(),
      phone: (map['phone'] ?? map['phoneNumber'] ?? map['phone_number'])?.toString(),
      photoUrl: map['photoUrl']?.toString() ?? map['photo_url']?.toString() ?? map['avatar_url']?.toString(),
      preferences: UserPreferences.fromMap({
        ...map,
        if (!map.containsKey('user_id') && !map.containsKey('userId')) 'user_id': userId,
      }),
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
      'firebase_uid': firebaseUid,
      'email': email,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
      'preferences': preferences.toMap(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasValidDatabaseId =>
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(id);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
