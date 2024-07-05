import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
   RxString locale = ''.obs;
     RxString countryCode = ''.obs;
     
Future<void> getLocaleFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final storedLocale = prefs.getString('locale');
  final storedCountryCode = prefs.getString('countryCode');
    locale.value = storedLocale ?? 'en';
    countryCode.value = storedCountryCode ?? 'US';
  
}


  Future<void> setLocale(String newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', newLocale);
    locale.value = newLocale;
  }

  void setCountryCode(String newCountryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('countryCode', newCountryCode);
    countryCode.value = newCountryCode;
  }
}
