// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myshetra/Models/Authmodel.dart';

import 'package:myshetra/Pages/Otpscreen.dart';
import 'package:myshetra/Pages/Positionproof.dart';
import 'package:myshetra/Providers/AuthProvider.dart';
import 'package:myshetra/bloc/signup/signup_bloc.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/Authservices.dart';
import 'Oranisation.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late SignupBloc _signupBloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _signupBloc = SignupBloc();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _signupBloc.close();
    super.dispose();
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
        body: BlocProvider(
          create: (context) => _signupBloc,
          child: const SignUpForm(),
        ));
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _otp = '';
  var numberText = "";
  bool isAvailable = false;
  bool _isOtpBottomSheetShown = false;
  // Track if the bottom sheet is shown
  void _showOtpBottomSheet(BuildContext context) {
    void _onTextFieldChanged(int index, String value) {
      // Move to the next field if the current one is filled
      if (value.isNotEmpty && index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else if (value.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }

      // Update the OTP
      setState(() {
        _otp = _controllers.map((controller) => controller.text).join();
      });

      // Dispatch the OTPChanged event to the Bloc
      context.read<SignupBloc>().add(OTPChanged(otp: _otp));
      print("OTP OTP $_otp");
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Verify login details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Center(
                    child: Text('We have sent a verification code to')),
                Center(
                  child: Text(
                    '+91-${context.read<SignupBloc>().state.number}',
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
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
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
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Valid up to 25 seconds',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Resend OTP'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () =>
                          context.read<SignupBloc>().add(VerifyOtp()),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
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
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) {
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
                  context.read<SignupBloc>().add(DOBChanged(
                      dateOfBirth:
                          DateFormat('yyyy-MM-dd').format(newDateTime)));
                },
              ),
            );
          },
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

  String _mobileNumber = '';
  @override
  void initState() {
    super.initState();
    _mobileNumberController.addListener(_checkMobileNumber);
  }

  void _checkMobileNumber() {
    if (_mobileNumberController.text.length == 10) {
      _checkMobileNumberAvailability();
    } else {
      print("not fullfilled length = ${_mobileNumberController.text.length}");
    }
  }

  void _checkMobileNumberAvailability() async {
    print("in function");
    String mobileNumber = _mobileNumberController.text;
    var request = http.Request(
      'GET',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/checkMobileAlreadyRegistered?mobile_number=$mobileNumber'),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      bool status = responseData['statusDetails']['status'];
      String message = responseData['message'];
      print("response ${responseData}");
      if (status) {
        setState(() {
          numberText = "Mobile number available";
          isAvailable = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Number is  available',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ));
      } else {
        setState(() {
          numberText = "Mobile number is not available";
          isAvailable = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number is not available',
                style: TextStyle(color: Colors.red)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to check number availability. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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

      // Assuming the OTP is part of the response, extract it
      String otp = otpData['otp'] ?? '';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: OtpScreen(
                mobileNumber: _mobileNumberController.text,
                otp: otp,
                onOtpVerification: (otp2) {
                  verifySignupOTP(
                      mobileNumber: mobileNumber,
                      otp: otp2,
                      name: nameController.text,
                      gender: gender,
                      dateOfBirth: dateOfBirthController.text);
                },
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifySignupOTP'));
    request.bodyFields = {
      'mobile_number': mobileNumber,
      'otp': otp,
      'name': name,
      'gender': gender.toLowerCase(),
      'date_of_birth': dateOfBirth,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var jsonData = json.decode(responseBody);
    print("Response code: ${jsonData}");
    final authResponse = AuthResponse.fromJson(jsonData['data']);

    if (response.statusCode == 200) {
      print(responseBody);
      if (authResponse.refreshToken != null && authResponse.token != null) {
        // Save the tokens to secure storage or a state management solution
        Provider.of<AuthProvider>(context, listen: false)
            .setAuthResponse(authResponse);
        Get.find<AuthService>().setAuthResponse(authResponse.token, authResponse.refreshToken);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authResponse.token);
        await prefs.setString('refreshToken', authResponse.refreshToken);
      } else {
        print('Failed to authenticate');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrganizationProofScreen(),
        ),
      );
    } else {
      print("ERROR");
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify OTP. Please try again.'),
        ),
      );
    }
  }

  var gender = "Male";
  var DateOfBirth = "";
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.otpStatus == OTPStatus.otpSent && _isOtpBottomSheetShown) {
          _isOtpBottomSheetShown = true;
          _showOtpBottomSheet(context);
        } else if (state.otpStatus == OTPStatus.otpVerified) {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => PositionProofScreen())));
        } else if (state.otpStatus == OTPStatus.otpVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to verify OTP. Please try again.'),
            ),
          );
          setState(() {
            _isOtpBottomSheetShown = true;
          });
        }
      },
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: SingleChildScrollView(
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
                    const SizedBox(
                      height: 30,
                    ),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return Container(
                          margin: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 15, top: 5, bottom: 5),
                                hintText: 'Full Name',
                                hintStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w200),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.name,
                              onChanged: (value) => {
                                    context
                                        .read<SignupBloc>()
                                        .add(NameChanged(name: value)),
                                  }),
                        );
                      },
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12),
                            child: Text(
                              '+91',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w100),
                            ),
                          ),
                          BlocBuilder<SignupBloc, SignupState>(
                            builder: (context, state) {
                              return Expanded(
                                child: TextField(
                                    controller: _mobileNumberController,
                                    onEditingComplete: _checkMobileNumber,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter mobile number',
                                      hintStyle: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w200),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.phone,
                                    onChanged: (value) => {
                                          context.read<SignupBloc>().add(
                                              NumberChanged(number: value)),
                                          if (value.length == 10)
                                            {
                                              context
                                                  .read<SignupBloc>()
                                                  .add(CheckNumber()),
                                            }
                                        }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        numberText,
                        style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return Container(
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
                            hint: const Text("Gender"),
                            onChanged: (value) {
                              setState(() {
                                gender = value!;
                              });
                              context.read<SignupBloc>().add(
                                  GenderChanged(gender: value!.toLowerCase()));
                            },
                            items:
                                <String>['Male', 'Female'].map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                          ),
                        );
                      },
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
                          Expanded(
                            child: TextField(
                              controller: dateOfBirthController,
                              decoration: const InputDecoration(
                                hintText: 'Enter date of birth',
                                hintStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w200),
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
                    const SizedBox(height: 180),
                    const Align(
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
                          primary: const Color(0xFFFF5252), // Background color
                        ),
                        onPressed: () {
                          // context.read<SignupBloc>().add(GenerateOtp());
                          generateSignupOTP(_mobileNumberController.text);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Next',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22), // Text color
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
