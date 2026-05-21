class ApiConfig {
  static String get baseUrl {
    return "https://api-maoamiga.up.railway.app";
    // return "http://10.0.2.2:3000";
  }

  // Define a chave vinda do ambiente (--dart-define)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
