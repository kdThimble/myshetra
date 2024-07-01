import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxController {
  var token = ''.obs;
  var refreshToken = ''.obs;

  void setAuthResponse(String newToken, String newRefreshToken) {
    token.value = newToken;
    refreshToken.value = newRefreshToken;
    saveTokensToStorage(newToken, newRefreshToken);
  }

  Future<void> saveTokensToStorage(String newToken, String newRefreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    await prefs.setString('refreshToken', newRefreshToken);
  }

  Future<void> loadTokensFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('token') ?? '';
    refreshToken.value = prefs.getString('refreshToken') ?? '';
  }

  String getToken() {
    return token.value;
  }

  String getRefreshToken() {
    return refreshToken.value;
  }
}
