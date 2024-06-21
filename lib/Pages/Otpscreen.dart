import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  OtpScreen({required this.mobileNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  void _onTextFieldChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    String inviteCode = _controllers.map((controller) => controller.text).join();
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
            SizedBox(height: 12,),
            Center(child: Text('Verify login details' , style: TextStyle(fontSize: 24 ,fontWeight: FontWeight.bold),)),
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
                style: TextStyle(color: Colors.blue , fontWeight: FontWeight.bold),
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
                        borderRadius: BorderRadius.circular(10)
                      ),
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
                onPressed: () {
                  // Implement resend OTP logic here
                  print('Resend OTP');
                },
                child: Text('Resend OTP'),
              ),
            ),
            // SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Add your login logic here
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => CheckMobileScreen()),
                    // );
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
