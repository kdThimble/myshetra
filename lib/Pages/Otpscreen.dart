import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final Function(String) onOtpVerification;
  final String otp;

  OtpVerificationScreen(
      {required this.mobileNumber,
      required this.onOtpVerification,
      required this.otp});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
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

  @override
  Widget build(BuildContext context) {
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
                  'Valid up to 25 seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              // SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _verifyOtp,
                  child: Text('Resend OTP'),
                ),
              ),
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
