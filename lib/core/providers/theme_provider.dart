import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../auth_service.dart';
import '../../models/user_model.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _highContrast = false;
  double _fontSizeMultiplier = 1.0;

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  ThemeProvider() {
    _listenToAuth();
  }

  void _listenToAuth() {
    AuthService().userStream.listen((UserModel? user) {
      if (user != null) {
        _updateFromPreferences(user.preferences.preferredColor, user.preferences.highContrast, user.preferences.fontSizeMultiplier);
      }
    });
  }

  void _updateFromPreferences(String? preferredColor, bool highContrast, double fontSizeMultiplier) {
    _highContrast = highContrast;
    _fontSizeMultiplier = fontSizeMultiplier;

    if (preferredColor == 'Tema Claro') {
      _themeMode = ThemeMode.light;
    } else if (preferredColor == 'Tema Escuro') {
      _themeMode = ThemeMode.dark;
    } else if (preferredColor == 'Alto Contraste') {
      _themeMode = ThemeMode.dark;
      _highContrast = true;
    } else {

      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_highContrast) {
      return AppTheme.highContrastTheme;
    }
    return _themeMode == ThemeMode.light ? AppTheme.lightTheme : AppTheme.darkTheme;
  }
}
