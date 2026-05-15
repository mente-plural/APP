import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../auth_service.dart';

enum UserProfile {
  paraMim,
  tutorFamiliar,
  aprenderMais;

  String get id {
    switch (this) {
      case UserProfile.paraMim:
        return 'FOR_ME';
      case UserProfile.tutorFamiliar:
        return 'TUTOR';
      case UserProfile.aprenderMais:
        return 'LEARN_MORE';
    }
  }

  static UserProfile fromId(String id) {
    return UserProfile.values.firstWhere(
            (e) => e.id == id,
        orElse: () => UserProfile.paraMim
    );
  }
}

class ProfileProvider with ChangeNotifier {
  UserProfile? _selectedProfile;

  UserProfile? get selectedProfile => _selectedProfile;

  ProfileProvider() {
    _loadProfile();
    _listenToAuth();
  }

  void _listenToAuth() {
    AuthService().userStream.listen((UserModel? user) {
      if (user != null) {

        if (user.preferences.profileType != null) {
          final profile = UserProfile.fromId(user.preferences.profileType!);
          if (_selectedProfile != profile) {
            _selectedProfile = profile;
            _saveToPrefs(profile.id);
            notifyListeners();
          }
        }
      } else {

        if (_selectedProfile != null) {
          _selectedProfile = null;
          _clearPrefs();
          notifyListeners();
        }
      }
    });
  }

  Future<void> _saveToPrefs(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_profile', id);
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_profile');
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString('selected_profile');
    if (profileId != null) {
      _selectedProfile = UserProfile.fromId(profileId);
      notifyListeners();
    }
  }

  Future<void> setProfile(UserProfile profile) async {
    _selectedProfile = profile;
    notifyListeners();
    await _saveToPrefs(profile.id);
  }
}
