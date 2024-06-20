// ignore: file_names
import 'package:flutter/material.dart';
import 'package:myshetra/Pages/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myshetra/helpers/colors.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Shetra",
          style: TextStyle(
            color: blueColor,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose your preferred language',
              style: TextStyle(
                fontSize: width * 0.057,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                  contentPadding: const EdgeInsets.all(8),
                  tileColor: _selectedLanguage == 'en'
                      ? const Color(0xFFAFD9FF)
                      : const Color(0xFFEFEFEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value as String;
                      _saveSelectedLanguage();
                    });
                  },
                  selectedTileColor: blueColor),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                contentPadding: const EdgeInsets.all(8),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value as String;
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
            SizedBox(height: height * 0.1),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ElevatedButton(
                onPressed: _saveSelectedLanguage,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFFFF5252)), // Change button color
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Make the button rounded
                    ),
                  ),
                  elevation:
                      MaterialStateProperty.resolveWith<double>((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return 10; // Increase elevation when pressed
                    }
                    return 5; // Default elevation
                  }),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(1)), // Add padding
                  minimumSize: MaterialStateProperty.all<Size>(
                      const Size(double.infinity, 50)), // Set width to full
                  // side: MaterialStateProperty.all<BorderSide>(
                  //     BorderSide(color: Colors.blue)), // Add border
                ),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.06,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
