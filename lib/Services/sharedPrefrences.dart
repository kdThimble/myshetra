import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String LanguageKey = 'language';
  static const String TOKENKEY = "token";
  static const String REFRESH_TOKEN = "refreshToken";

  Future<void> saveLanguage(String language) async {
    print("language Selected $language");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LanguageKey, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LanguageKey) ??
        'en'; // Default language if not found
  }
}
