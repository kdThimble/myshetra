import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:myshetra/Pages/LanguageSelectionScreen.dart';
import 'package:myshetra/Pages/Oranisation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                token != null ? HomePage() : LanguageSelectionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color(0xFF0D3D8B),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('app_header_title'.tr,
                      style: TextStyle(
                          fontSize: width * 0.12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 10),
                  Text('initial_screen_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
            Positioned(
              top: height * 0.22,
              left: width * 0.1,
              child: Image.asset("assets/images/splashmap.png"),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset("assets/images/splashbg.png"),
            ),
          ],
        ));
  }
}
