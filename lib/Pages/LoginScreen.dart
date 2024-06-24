import 'package:flutter/material.dart';
import 'package:myshetra/Components/LinkText.dart';
import 'package:myshetra/Pages/Signup.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:http/http.dart' as http;

import 'Checkmobilenumber.dart';
import 'Otpscreen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mobileNumberController = TextEditingController();



  Future<void> generateLoginOTP(String mobile, BuildContext context) async {
    try {
      var url = Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateLoginOTP?mobile_number=$mobile');
      var request = http.Request('POST', url);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());

        // Navigate to OTP screen as modal bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return OtpVerificationScreen(
              otp: "",
              mobileNumber: mobileNumberController.text, onOtpVerification: (String ) {  },
            );
          },
        );
      } else {
        print(response.reasonPhrase);
        // Handle error (e.g., show a snackbar with an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      // Handle exception (e.g., show a snackbar with an exception message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Text(
                    "Drive with Confidence \n Your Local Car Repair   Expert at Your Fingertips!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                        child: Text(
                          '+91',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w100),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: mobileNumberController,
                          decoration: const InputDecoration(
                            hintText: 'Enter mobile number',
                            hintStyle: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w200),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      generateLoginOTP(mobileNumberController.text ,  context);

                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                const Row(
                  children: [
                    Expanded(
                        child: Divider(
                      color: Color(0xFFD9D9D9),
                    )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "or",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 19),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      color: Color(0xFFD9D9D9),
                    )),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Add your login logic here
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          // side: BorderSide(color: Colors.black),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFFF5252)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("By signing up, you agree to our "),
                        LinkText(
                            link: "https://pub.dev/packages/url_launcher/example",
                            text: "Terms"),
                        const Text(","),
                        LinkText(
                            link: "https://pub.dev/packages/url_launcher/example",
                            text: " Privacy Policy"),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.004,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("and "),
                        LinkText(
                            link: "https://pub.dev/packages/url_launcher/example",
                            text: "Cookie Use"),
                      ],
                    )
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
