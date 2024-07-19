import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/helpers/colors.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String title;
  final Function(String) onOtpVerification;
  final String otp;
  final String attemptsLeft;
  final String otpValidity;
  OtpScreen(
      {required this.mobileNumber,
      required this.onOtpVerification,
      this.otp = '',
      this.title = 'Verify login Details',
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
  String attemptsLeft = '';

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
      Fluttertoast.showToast(
          msg: "Please enter the OTP",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
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
    if (attemptsLeft == '0') {
      Fluttertoast.showToast(
          msg: "You have exceeded the number of attempts Try again later",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
      return;
    }
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

      Fluttertoast.showToast(
          msg: "OTP sent successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);

      // Assuming the OTP is part of the response, extract it
      String otp = otpData['otp'] ?? '';
      print("OTP data $otpData");
      setState(() {
        attemptsLeft = otpData['data']['attempts_left'].toString();
        print(attemptsLeft);
      });
      // setState(() {
      //   attemptsLeft = otpData['data']['attempts_left'] ?? 0;
      //   otpValidity = otpData['data']['otp_validity'] ?? 0;
      // });
      // print("otpValidity:$otpValidity");
    } else {
      // Get.snackbar("Error", "Please enter the OTP",
      //     backgroundColor: Colors.red, colorText: Colors.white);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter the OTP"),
          backgroundColor: Colors.red,
        ),
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
    attemptsLeft = widget.attemptsLeft;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.otpValidity);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: greyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/Group1.png",
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.45,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.47,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Center(
                            child: Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        )),
                        Center(child: Text('verify_login_otp_sub_title'.tr)),
                        Center(
                          child: Text(
                            '+91-${widget.mobileNumber}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:  Center(
                            child: Text(
                              'change_number'.tr,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
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
                                maxLength: 1,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Color(0xFF0E3D8B), width: 2.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.black45, width: 2.0),
                                  ),
                                ),
                                onChanged: (value) =>
                                    _onTextFieldChanged(index, value),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'valid_up_to'.trParams({'time': '$_remainingTimeInSeconds'}),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              generateSignupOTP(widget.mobileNumber);
                            },
                            child: Text(
                              'resend_otp'.tr,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'attempts_left'.trParams({'attempts': '$attemptsLeft'}),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5252)),
                          ),
                        ),
                        // SizedBox(height: 10),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyButton(onTap: _verifyOtp, text: "Submit"),
                        ),
                      ],
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
