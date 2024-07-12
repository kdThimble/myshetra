import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myshetra/Pages/Signup.dart';

import '../helpers/colors.dart';
import 'LoginScreen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
              height: height * 0.4,
              width: width,
              decoration: BoxDecoration(
                color: bgColor,
                image: DecorationImage(
                  image: AssetImage('assets/images/Group1.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        'Welcome to My Shetra',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet consectetur. Sagittis massa faucibus volutpat viverra ut. Pharetra iaculis amet faucibus praesent eros faucibus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF858585),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Spacer(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF0E3D8B)), // Change button color
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
                                  double.infinity, 50)), // Set width to full
                          // side: MaterialStateProperty.all<BorderSide>(
                          //     BorderSide(color: Colors.blue)), // Add border
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'initial_screen_signup_button_text'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.06,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent), // Change button color
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFF0E3D8B)),
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
                                  double.infinity, 50)), // Set width to full
                          // side: MaterialStateProperty.all<BorderSide>(
                          //     BorderSide(color: Colors.blue)), // Add border
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'initial_screen_login_button_text'.tr,
                            style: TextStyle(
                              color: Color(0xFF0E3D8B),
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.06,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
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
