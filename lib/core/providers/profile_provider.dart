import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_profile', profile.id);
  }
}
