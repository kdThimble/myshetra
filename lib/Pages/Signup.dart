import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myshetra/Pages/LoginScreen.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'Oranisation.dart';


class SignUpPage extends StatefulWidget {
  final String mobileNumber;
  final String otp;

  SignUpPage({required this.mobileNumber, required this.otp});


  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController otpcontroller = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.0,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            minimumDate: DateTime(1900),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
               dateOfBirthController.text =
                    DateFormat('yyyy-MM-dd').format(newDateTime);
              });
            },
          ),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> verifySignupOTP({
    required String mobileNumber,
    required String otp,
    required String name,
    required String gender,
    required String dateOfBirth,
  }) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request('POST', Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifySignupOTP'));
    request.bodyFields = {
      'mobile_number': mobileNumber,
      'otp': otp,
      'name': name,
      'gender': gender,
      'date_of_birth': dateOfBirth,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrganizationProofScreen(
          ),
        ),
      );
      // Navigate to the next screen or show success message
    } else {
      print(response.reasonPhrase);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP. Please try again.')),
      );
    }
  }

  var gender = "Male";
  var DateOfBirth = "";
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      mobileNumberController.text = widget.mobileNumber;
      otpcontroller.text = widget.otp;
    });
    super.initState();
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
          child: Center(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Create your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: height * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(left: 15, top: 5, bottom: 5),
                        hintText: 'Full Name',
                        hintStyle: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w200),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.name,
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
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: otpcontroller,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.only(left: 15, top: 5, bottom: 5),
                        hintText: 'Otp',
                        hintStyle: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w200),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      elevation: 0,
                      isExpanded: true,
                      underline: Container(),
                      value: gender,
                      hint: Text("Gender"),
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                      items: <String>['Male', 'Female'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                          child: Text(
                            'DOB',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w100),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: dateOfBirthController,
                            decoration: const InputDecoration(
                              hintText: 'Enter date of birth',
                              hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w200),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 180),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFF5252), // Background color
                      ),
                      onPressed: () {
                        // OrganizationProofScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrganizationProofScreen(
                            ),
                          ),
                        );
                        // verifySignupOTP(
                        //   mobileNumber: mobileNumberController.text,
                        //   otp: otpcontroller.text,
                        //   name: nameController.text,
                        //   gender: gender,
                        //   dateOfBirth: dateOfBirthController.text,
                        // );
                      },
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white), // Text color
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
