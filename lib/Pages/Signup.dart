// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myshetra/Controller/loadingController.dart';
import 'package:myshetra/Models/Authmodel.dart';
import 'package:myshetra/Pages/LanguageSelectionScreen.dart';
import 'package:myshetra/Pages/LoginScreen.dart';

import 'package:myshetra/Pages/Otpscreen.dart';
import 'package:myshetra/Pages/Positionproof.dart';
import 'package:myshetra/Pages/map_page.dart';
import 'package:myshetra/Providers/AuthProvider.dart';
import 'package:myshetra/bloc/signup/signup_bloc.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/Authservices.dart';

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

    return Scaffold(
        appBar: AppBar(
          leading: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const LanguageSelectionPage());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey), // Border color
                    shape: BoxShape.circle, // Rounded shape
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.arrow_back, // Back icon
                      color: Colors.black, // Icon color
                    ),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          title: Text(
            "app_header_title".tr,
            style: TextStyle(
              color: primaryColor,
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
  final SignupController signupController = Get.put(SignupController());
  final LoadingController loadingController = Get.put(LoadingController());
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
                    'Verify Signup details',
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
                        keyboardType: TextInputType.number,
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
    DateTime initialDate = DateTime.now();
    if (dateOfBirthController.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd').parse(dateOfBirthController.text);
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate;
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                'create_account_dob_modal_text'
                    .tr, // You may need to add .tr if using GetX for translations
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: DatePickerWidget(
                  initialDate: initialDate, // Set the initial date
                  locale: DateTimePickerLocale.en_us,
                  pickerTheme: DateTimePickerTheme(
                    backgroundColor: Colors.white.withOpacity(0.0),
                    showTitle: false,
                    itemTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    cancelTextStyle: TextStyle(color: Colors.black),
                    confirmTextStyle: TextStyle(color: Colors.black),
                    itemHeight: 40,
                  ),
                  dateFormat: 'dd-MMMM-yyyy',
                  onChange: (date, _) {
                    selectedDate = date;
                  },
                  onConfirm: (date, _) {
                    if (date.year < 1940 || date.year > 2006) {
                      Fluttertoast.showToast(
                          msg: 'Birthdate must be between 1940 and 2006.',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.TOP);
                    } else {
                      setState(() {
                        dateOfBirthController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF0E3D8B)), // Change button color
                    elevation:
                        MaterialStateProperty.resolveWith<double>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return 10; // Increase elevation when pressed
                      }
                      return 5; // Default elevation
                    }),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0)), // Add padding
                    minimumSize: MaterialStateProperty.all<Size>(
                        const Size(100, 40)), // Set width to full
                  ),
                  onPressed: () {
                    if (selectedDate.year < 1940 || selectedDate.year > 2006) {
                      Fluttertoast.showToast(
                          msg: 'Birthdate must be between 1940 and 2006.',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.TOP);
                    } else {
                      setState(() {
                        dateOfBirthController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

      print("response ${responseData}");
      if (status) {
        setState(() {
          numberText = "mobile_number_available".tr;
          isAvailable = true;
        });
      } else {
        setState(() {
          numberText = "mobile_not_number_available".tr;
          isAvailable = false;
        });
      }
    } else {
      setState(() {
        numberText = "mobile_not_number_available".tr;
        isAvailable = false;
      });
    }
  }

  int attemptsLeft = 0;
  int otpValidity = 0;
  Future<void> generateSignupOTP(String mobileNumber) async {
    print("OTP number $mobileNumber");
    loadingController.startLoading();
    if (isAvailable) {
      var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateSignupOTP?mobile_number=$mobileNumber'),
      );

      http.StreamedResponse response = await request.send();
      print("response otp $response");
      var responseData = await response.stream.bytesToString();
      var otpData = json.decode(responseData);
      print("OTP DATA $otpData");

      if (response.statusCode == 200) {
        Get.find<LoadingController>().stopLoading();
        Get.to(OtpScreen(
          title: "verify_login_otp_title".tr,
          mobileNumber: _mobileNumberController.text,
          attemptsLeft: otpData['data']['attempts_left'].toString(),
          otpValidity: otpData['data']['otp_validity'].toString(),
          onOtpVerification: (otp2) {
            verifySignupOTP(
              mobileNumber: mobileNumber,
              otp: otp2,
              name: nameController.text,
              gender: gender,
              dateOfBirth: dateOfBirthController.text,
            );
          },
        ));
      } else {
        loadingController.stopLoading();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      loadingController.stopLoading();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Mobile number is not available'),
          backgroundColor: Colors.red,
        ),
      );
      // Get.snackbar("Error", "Mobile number is not available");
    }
  }

  Future<void> verifySignupOTP({
    required String mobileNumber,
    required String otp,
    required String name,
    required String gender,
    required String dateOfBirth,
  }) async {
    print("Inside try");
    Get.find<LoadingController>().startLoading();
    try {
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

      Get.find<LoadingController>().stopLoading();

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonData['data']);
        print(responseBody);
        if (authResponse.refreshToken != null && authResponse.token != null) {
          // Save the tokens to secure storage or a state management solution
          Provider.of<AuthProvider>(context, listen: false)
              .setAuthResponse(authResponse);
          Get.find<AuthService>()
              .setAuthResponse(authResponse.token, authResponse.refreshToken);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', authResponse.token);
          await prefs.setString('refreshToken', authResponse.refreshToken);
          prefs.setString('issignupcompleted', 'true'); // Save the name
        } else {
          // Get.snackbar('Error', 'Failed to authenticate');
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(
              content: Text('Failed to authenticate'),
              backgroundColor: Colors.red,
            ),
          );
          print('Failed to authenticate');
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(),
          ),
          (route) => false,
        );
      } else {
        print("ERROR");
        print(response.reasonPhrase);
        Get.snackbar("Error", " ${jsonData['message'].toString()}",
            backgroundColor: Colors.red, colorText: Colors.white);
        //     ScaffoldMessenger.of(Get.context!).showSnackBar(
        //   const SnackBar(
        //     content: Text(jsonData['message'].toString()),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } catch (e) {
      Get.find<LoadingController>().stopLoading();
      // Get.snackbar(
      //     "Error", "Failed to verify OTP. Please try again. ${e.toString()}");
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify OTP. Please try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  var gender;
  var DateOfBirth = "";
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    _mobileNumberController.addListener(() {
      signupController.mobileNumber.value = _mobileNumberController.text;
    });
    nameController.addListener(() {
      signupController.name.value = nameController.text;
    });
    dateOfBirthController.addListener(() {
      signupController.dateOfBirth.value = dateOfBirthController.text;
    });
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "create_account_title".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "create_account_sub_title".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height * 0.019,
                        fontWeight: FontWeight.normal,
                        color: greyColor),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                BlocBuilder<SignupBloc, SignupState>(
                  builder: (context, state) {
                    return TextField(
                        controller: nameController,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                        decoration: InputDecoration(
                            label: Text(
                              'create_account_full_name_placeholder'.tr,
                              style: TextStyle(fontSize: 20),
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 15, top: 15, bottom: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        keyboardType: TextInputType.name,
                        onChanged: (value) => {
                              context
                                  .read<SignupBloc>()
                                  .add(NameChanged(name: value)),
                            });
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(bottom: 10.0, right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                        )),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return Expanded(
                          child: TextField(
                              controller: _mobileNumberController,
                              maxLength: 10,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black),
                              onEditingComplete: _checkMobileNumber,
                              decoration: InputDecoration(
                                  counter: const SizedBox(
                                    height: 0,
                                  ),
                                  label: Text(
                                    'create_account_mobile_number_placeholder'
                                        .tr,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, top: 15, bottom: 15),
                                  hintStyle: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w200),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) => {
                                    context
                                        .read<SignupBloc>()
                                        .add(NumberChanged(number: value)),
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
                Padding(
                  padding: const EdgeInsets.only(right: 0.0, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      numberText,
                      style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.00,
                ),
                BlocBuilder<SignupBloc, SignupState>(
                  builder: (context, state) {
                    return DropdownButtonFormField<String>(
                      elevation: 3,
                      isExpanded: true,
                      decoration: InputDecoration(
                        label: Text(
                          "create_account_gender_select_placeholder".tr,
                          style: TextStyle(color: greyColor, fontSize: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                        context
                            .read<SignupBloc>()
                            .add(GenderChanged(gender: value!.toLowerCase()));
                      },
                      items: <String>['Male', 'Female'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(
                  height: height * 0.035,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dateOfBirthController,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              left: 15, top: 15, bottom: 15, right: 15),
                          prefixIcon: Icon(
                            Icons.calendar_month_outlined,
                            color: greyColor,
                          ),
                          label: Text(
                            'create_account_dob_select_placeholder'.tr,
                            style: TextStyle(fontSize: 20),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Obx(() {
                  final bool isFormValid = nameController.text.isNotEmpty &&
                      _mobileNumberController.text.isNotEmpty &&
                      dateOfBirthController.text.isNotEmpty &&
                      gender != null;

                  return SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isFormValid
                                ? primaryColor
                                : Colors.grey, // Change to your primary color
                          ),
                        ),
                        onPressed: isFormValid
                            ? () {
                                generateSignupOTP(_mobileNumberController.text);
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: loadingController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'create_account_button_text'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: height * 0.02),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 18), // Apply the base style
                      children: [
                        TextSpan(
                          text:
                              "signup_screen_already_have_account_question".tr,
                          style: TextStyle(color: greyColor),
                        ),
                        TextSpan(
                          text: " ".tr,
                          style: TextStyle(color: greyColor),
                        ),
                        TextSpan(
                          text: 'signup_screen_login_hyperlink_text'.tr,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
