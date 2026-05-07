import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return "https://api-maoamiga.up.railway.app";
    } else {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:3000";
      } else {
        return "http://localhost:3000";
      }
    }
  }
}