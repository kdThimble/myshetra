import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myshetra/Components/MyButton.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final Function(String) onOtpVerification;
  final String otp;
  final String attemptsLeft;
  final String otpValidity;
  OtpScreen(
      {required this.mobileNumber,
      required this.onOtpVerification,
      this.otp = '',
      required this.attemptsLeft,
      required this.otpValidity});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _otp = '';

  void _onTextFieldChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _verifyOtp() {
    _otp = _controllers.map((controller) => controller.text).join();
    if (_otp.isEmpty || _otp.length < 6) {
      Get.snackbar(
        "Error",
        "Please enter the OTP",
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please enter the OTP'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    } else {
      print("OTP , $_otp");

      if (true) {
        print("inside if");
        widget.onOtpVerification(_otp);
      }
    }
  }

  Future<void> generateSignupOTP(String mobileNumber) async {
    print("OTP number $mobileNumber");
    var request = http.Request(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateSignupOTP?mobile_number=$mobileNumber'),
    );

    http.StreamedResponse response = await request.send();
    print("response otp $response");

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var otpData = json.decode(responseData);
      print("OTP DATA $otpData");
      Get.snackbar(
        "Success",
        "OTP sent successfully",
      );

      // Assuming the OTP is part of the response, extract it
      String otp = otpData['otp'] ?? '';
      // setState(() {
      //   attemptsLeft = otpData['data']['attempts_left'] ?? 0;
      //   otpValidity = otpData['data']['otp_validity'] ?? 0;
      // });
      // print("otpValidity:$otpValidity");
    } else {
      Get.snackbar(
        "Error",
        "Please enter the OTP",
      );
    }
  }

  void _startTimer() {
    print("start");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  late int _remainingTimeInSeconds;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    final otpValidityInMinutes =
        (int.parse(widget.otpValidity) / 60).truncate();
    _remainingTimeInSeconds = otpValidityInMinutes * 60;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.otpValidity);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Center(
                  child: Text(
                'Verify login details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              const Center(child: Text('We have sent a verification code to')),
              Center(
                child: Text(
                  '+91-${widget.mobileNumber}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'change number?',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 53,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF0E3D8B), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black45, width: 2.0),
                        ),
                      ),
                      onChanged: (value) => _onTextFieldChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Valid up to $_remainingTimeInSeconds seconds',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    generateSignupOTP(widget.mobileNumber);
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'You have ${widget.attemptsLeft} Attempts left',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5252)),
                ),
              ),
              // SizedBox(height: 10),
              // SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyButton(onTap: _verifyOtp, text: "Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
