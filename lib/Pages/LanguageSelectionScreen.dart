// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myshetra/Pages/AuthPage.dart';
import 'package:myshetra/Pages/LoginScreen.dart';
import 'package:myshetra/Pages/Oranisation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myshetra/helpers/colors.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'en';
  String _selectedCountryCode = 'US';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('locale') ?? 'en';
      _selectedCountryCode = prefs.getString('countryCode') ?? 'US';
    });
  }

  Future<void> _saveSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _selectedLanguage);
    await prefs.setString('countryCode', _selectedCountryCode);
    Get.updateLocale(Locale(_selectedLanguage, _selectedCountryCode));
    // ignore: use_build_context_synchronously
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          children: [
            Container(
              height: height * 0.46,
              width: width,
              decoration: BoxDecoration(
                color: bgColor,
                image: const DecorationImage(
                  image: AssetImage('assets/images/Group1.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'choose_language_snackbar_title'.tr,
                      style: TextStyle(
                        fontSize: width * 0.057,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'choose_language_snackbar_sub_title'.tr,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF858585),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: RadioListTile(
                          title: Text(
                            'English',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.05,
                            ),
                          ),
                          value: 'en',
                          groupValue: _selectedLanguage,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tileColor: _selectedLanguage == 'en'
                              ? const Color(0xFFAFD9FF)
                              : const Color(0xFFEFEFEF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Colors
                                    .grey), // Set the border color to gray
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value as String;
                              _selectedCountryCode = 'US';
                              _saveSelectedLanguage();
                            });
                          },
                          selectedTileColor: blueColor),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: RadioListTile(
                        title: Text(
                          'हिंदी',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.05,
                          ),
                        ),
                        value: 'hi',
                        groupValue: _selectedLanguage,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value as String;
                            _selectedCountryCode = 'IN';
                            _saveSelectedLanguage();
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: _selectedLanguage == 'hi'
                            ? const Color(0xFFAFD9FF)
                            : const Color(0xFFEFEFEF),
                        selectedTileColor: blueColor.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AuthPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              primaryColor), // Change button color
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Make the button rounded
                            ),
                          ),
                          elevation: MaterialStateProperty.resolveWith<double>(
                              (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return 10; // Increase elevation when pressed
                            }
                            return 5; // Default elevation
                          }),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(1)), // Add padding
                          minimumSize: MaterialStateProperty.all<Size>(
                              const Size(
                                  double.infinity, 65)), // Set width to full
                          // side: MaterialStateProperty.all<BorderSide>(
                          //     BorderSide(color: Colors.blue)), // Add border
                        ),
                        child: Text(
                          'Choose',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.06,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
