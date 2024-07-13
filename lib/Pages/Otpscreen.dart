import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final Function(String) onOtpVerification;
  final String otp;
  final String attemptsLeft;
  final String  otpValidity;
  OtpScreen(
      {required this.mobileNumber,
      required this.onOtpVerification,
      required this.otp,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print("OTP , $_otp");
      print("OTP2 , ${widget.otp}");
      if (true) {
        print("inside if");
        widget.onOtpVerification(_otp);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Otp Does not matched'),
            duration: Duration(seconds: 2),
          ),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP RESENT SUCCESFULLY !'),
          backgroundColor: Colors.transparent,
        ),
      );
      // Assuming the OTP is part of the response, extract it
      String otp = otpData['otp'] ?? '';
      // setState(() {
      //   attemptsLeft = otpData['data']['attempts_left'] ?? 0;
      //   otpValidity = otpData['data']['otp_validity'] ?? 0;
      // });
      // print("otpValidity:$otpValidity");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _startTimer() {
    print("start");
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    final otpValidityInMinutes = (int.parse(widget.otpValidity) / 60).truncate();
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
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 12,
              ),
              Center(
                  child: Text(
                'Verify login details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              Center(child: Text('We have sent a verification code to')),
              Center(
                child: Text(
                  '+91-${widget.mobileNumber}',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'change number?',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 53,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      // maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (value) => _onTextFieldChanged(index, value),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Valid up to $_remainingTimeInSeconds seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    generateSignupOTP(widget.mobileNumber);
                  },
                  child: Text('Resend OTP',   style: TextStyle(fontSize: 12, fontWeight:FontWeight.bold ,color: Colors.black),),
                ),
              ),
              Center(
                child: Text(
                  'You have ${widget.attemptsLeft} Attempts left',
                  style: TextStyle(fontSize: 12, fontWeight:FontWeight.bold ,color: Color(0xFFFF5252)),
                ),
              ),
              // SizedBox(height: 10),
              // SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _verifyOtp,
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
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
