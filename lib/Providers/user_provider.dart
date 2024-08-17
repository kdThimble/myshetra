import 'package:flutter/material.dart';
import 'package:myshetra/Models/UserModel.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners(); // Notify listeners to rebuild UI
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
