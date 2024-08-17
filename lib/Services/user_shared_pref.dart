import 'dart:convert'; // Import this package
import 'package:myshetra/Models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePreference {
  static const String _userProfileKey = 'user_profile';

  Future<void> saveUserProfile(UserProfile profile) async {
    print("Saving the object");
    final prefs = await SharedPreferences.getInstance();
    String profileJson =
        jsonEncode(profile.toJson()); // Convert Map to JSON string
    prefs.setString(_userProfileKey, profileJson);
    print(prefs.getString(_userProfileKey)); // Save JSON string
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? profileJson = prefs.getString(_userProfileKey);
    if (profileJson != null) {
      return UserProfile.fromJson(
          jsonDecode(profileJson)); // Convert JSON string back to Map
    }
    return null;
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userProfileKey);
  }
}
