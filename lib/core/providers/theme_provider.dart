import 'dart:async';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../models/user_model.dart';
import '../auth/auth_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _highContrast = false;
  double _fontSizeMultiplier = 1.0;
  String? _preferredColor;
  StreamSubscription? _authSubscription;

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  ThemeProvider() {
    _listenToAuth();
  }

  void _listenToAuth() {
    _authSubscription = AuthService().userStream.listen((UserModel? user) {
      if (user != null) {
        _updateFromPreferences(
          user.preferences.preferredColor,
          user.preferences.highContrast,
          user.preferences.fontSizeMultiplier,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _updateFromPreferences(String? preferredColor, bool highContrast, double fontSizeMultiplier) {
    _highContrast = highContrast;
    _fontSizeMultiplier = fontSizeMultiplier;
    _preferredColor = preferredColor;

    // Se preferência for um tema específico, ajustamos o modo
    if (preferredColor == 'Tema Claro') {
      _themeMode = ThemeMode.light;
    } else if (preferredColor == 'Tema Escuro') {
      _themeMode = ThemeMode.dark;
    }

    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_highContrast) {
      return AppTheme.highContrastTheme(fontSizeMultiplier: _fontSizeMultiplier);
    }
    
    if (_themeMode == ThemeMode.light) {
      return AppTheme.lightTheme(
        preferredColor: _preferredColor,
        fontSizeMultiplier: _fontSizeMultiplier,
      );
    }
    
    return AppTheme.darkTheme(
      preferredColor: _preferredColor,
      fontSizeMultiplier: _fontSizeMultiplier,
    );
  }
}
