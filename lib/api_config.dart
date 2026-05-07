import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return "https://api-maoamiga.up.railway.app";
    } else {
      if (Platform.isAndroid) {
        return "https://api-maoamiga.up.railway.app";
      } else {
        return "https://api-maoamiga.up.railway.app";
      }
    }
  }
}