import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myshetra/Pages/Signup.dart';

import '../helpers/colors.dart';

class CheckMobileScreen extends StatefulWidget {
  @override
  _CheckMobileScreenState createState() => _CheckMobileScreenState();
}

class _CheckMobileScreenState extends State<CheckMobileScreen> {
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isLoading = false;

  Future<void> checkMobileAlreadyRegistered(String mobileNumber) async {
    setState(() {
      _isLoading = true;
    });

    var request = http.Request(
      'GET',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/checkMobileAlreadyRegistered?mobile_number=$mobileNumber'),
    );

    http.StreamedResponse response = await request.send();

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      bool status = responseData['statusDetails']['status'];
      String message = responseData['message'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: status ? Colors.green : Colors.red,
        ),
      );

      if (status) {
        generateSignupOTP(mobileNumber);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check mobile number. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> generateSignupOTP(String mobileNumber) async {
    var request = http.Request(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateSignupOTP?mobile_number=$mobileNumber'),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var otpData = json.decode(responseData);

      // Assuming the OTP is part of the response, extract it
      String otp = otpData['otp'] ?? '';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpPage(
            // mobileNumber: mobileNumber,
            // otp: otp,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate OTP. Please try again.'),
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
          "app_header_title".tr,
          style: TextStyle(
            color: blueColor,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Enter mobile number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF5252), // Background color
              ),
              onPressed: () {
                checkMobileAlreadyRegistered(
                    _mobileNumberController.text);
              },
              child: Text(
                'Create Account',
                style: TextStyle(color: Colors.white), // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}