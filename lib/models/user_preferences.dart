class UserPreferences {
  final String? id;
  final String? userId;
  final String? preferredColor;
  final String? profileType;
  final List<String> neurodivergencies;
  final bool highContrast;
  final double fontSizeMultiplier;

  UserPreferences({
    this.id,
    this.userId,
    this.preferredColor,
    this.profileType,
    this.neurodivergencies = const [],
    this.highContrast = false,
    this.fontSizeMultiplier = 1.0,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    final preferencesData = map['preferences'];
    final bool isNested = preferencesData is Map;
    final data = isNested ? preferencesData : map;

    return UserPreferences(
      id: isNested ? data['id']?.toString() : null,
      userId: (data['user_id'] ?? data['userId'] ?? map['id'] ?? map['uuid'])?.toString(),
      preferredColor: (data['preferred_color'] ?? data['preferredColor'] ?? map['preferred_color'] ?? map['preferredColor'])?.toString(),
      profileType: (data['profile_type'] ?? data['profileType'] ?? map['profile_type'] ?? map['profileType'])?.toString(),
      neurodivergencies: data['neurodivergencies'] != null
          ? List<String>.from(data['neurodivergencies'])
          : (map['neurodivergencies'] != null ? List<String>.from(map['neurodivergencies']) : []),
      highContrast: data['high_contrast'] ?? data['highContrast'] ?? map['high_contrast'] ?? map['highContrast'] ?? false,
      fontSizeMultiplier: (data['font_size_multiplier'] ?? data['fontSizeMultiplier'] ?? map['font_size_multiplier'] ?? map['fontSizeMultiplier'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    final bool isUuid = id != null &&
        RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
            .hasMatch(id!);

    return {
      if (isUuid) 'id': id,
      if (userId != null) 'user_id': userId,
      'preferred_color': preferredColor,
      'profile_type': profileType,
      'neurodivergencies': neurodivergencies,
      'high_contrast': highContrast,
      'font_size_multiplier': fontSizeMultiplier,
    };
  }

  UserPreferences copyWith({
    String? id,
    String? userId,
    String? preferredColor,
    String? profileType,
    List<String>? neurodivergencies,
    bool? highContrast,
    double? fontSizeMultiplier,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferredColor: preferredColor ?? this.preferredColor,
      profileType: profileType ?? this.profileType,
      neurodivergencies: neurodivergencies ?? this.neurodivergencies,
      highContrast: highContrast ?? this.highContrast,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
    );
  }
}
