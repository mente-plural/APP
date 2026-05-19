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
    // Detecta se os dados estão aninhados em 'preferences' ou na raiz
    final preferencesData = map['preferences'];
    final Map<String, dynamic> data = (preferencesData is Map) 
        ? Map<String, dynamic>.from(preferencesData) 
        : Map<String, dynamic>.from(map);

    // Função auxiliar para extrair strings limpando valores "null" ou vazios
    String? cleanString(dynamic value) {
      if (value == null) return null;
      final s = value.toString().trim();
      return (s.isEmpty || s == 'null') ? null : s;
    }

    // Busca valores tentando camelCase e snake_case tanto no mapa local quanto no raiz
    dynamic findValue(String camel, String snake) {
      return data[camel] ?? data[snake] ?? map[camel] ?? map[snake];
    }

    return UserPreferences(
      id: cleanString(data['id']),
      userId: cleanString(findValue('userId', 'user_id')),
      preferredColor: cleanString(findValue('preferredColor', 'preferred_color')),
      profileType: cleanString(findValue('profileType', 'profile_type')),
      neurodivergencies: _parseNeuro(data['neurodivergencies'] ?? map['neurodivergencies']),
      highContrast: findValue('highContrast', 'high_contrast') ?? false,
      fontSizeMultiplier: (findValue('fontSizeMultiplier', 'font_size_multiplier') ?? 1.0).toDouble(),
    );
  }

  static List<String> _parseNeuro(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty && e != 'null').toList();
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      // Somente envia se o valor for válido para o Enum do backend
      if (preferredColor != null && preferredColor != 'null' && preferredColor!.isNotEmpty)
        'preferredColor': preferredColor,
      if (profileType != null && profileType != 'null' && profileType!.isNotEmpty)
        'profileType': profileType,
      'neurodivergencies': neurodivergencies,
      'highContrast': highContrast,
      'fontSizeMultiplier': fontSizeMultiplier,
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
