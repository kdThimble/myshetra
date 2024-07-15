// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:myshetra/Components/LinkText.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Controller/loadingController.dart';
import 'package:myshetra/Models/Authmodel.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:myshetra/Pages/LanguageSelectionScreen.dart';
import 'package:myshetra/Pages/Oranisation.dart';
import 'package:myshetra/Pages/Signup.dart';
import 'package:myshetra/Providers/AuthProvider.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/bloc/login/login_bloc.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Checkmobilenumber.dart';
import 'Otpscreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc _loginBlocs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loginBlocs = LoginBloc();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _loginBlocs.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: BlocProvider(
          create: (context) => _loginBlocs,
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _numberController = TextEditingController();
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _otp = '';

  bool _isOtpBottomSheetShown = false;
  // Track if the bottom sheet is shown
  void _showOtpBottomSheet(BuildContext context) {
    void _onTextFieldChanged(int index, String value) {
      if (value.isNotEmpty && index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else if (value.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
      _otp = _controllers.map((controller) => controller.text).join();
      context.read<LoginBloc>().add(OTPChanged(otp: _otp));
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
                Center(
                  child: Text(
                    'verify_login_otp_title'.tr,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(child: Text('verify_login_otp_sub_title'.tr)),
                Center(
                  child: Text(
                    '+91-${context.read<LoginBloc>().state.number}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      'change number?',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
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
                          context.read<LoginBloc>().add(VerifyOtp()),
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

  int attemptsLeft = 0;
  int otpValidity = 0;

  Future<void> generateSignupOTP(String mobileNumber) async {
    try {
      Get.find<LoadingController>().startLoading();
      var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateLoginOTP?mobile_number=${mobileNumber}'),
      );
      http.StreamedResponse response = await request.send();
      Get.find<LoadingController>().stopLoading();
        var responseData = await response.stream.bytesToString();
        var otpData = json.decode(responseData);

      if (response.statusCode == 200) {
      
        print("OTP DATA $otpData");

        // Assuming the OTP is part of the response, extract it
        String otp = otpData['otp'] ?? '';
        setState(() {
          attemptsLeft = otpData['data']['attempts_left'] ?? 0;
          otpValidity = otpData['data']['otp_validity'] ?? 0;
        });
        // ignore: use_build_context_synchronously
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: OtpScreen(
                  mobileNumber: mobileNumber,
                  otp: otp,
                  attemptsLeft: attemptsLeft.toString(),
                  otpValidity: otpValidity.toString(),
                  onOtpVerification: (otp) {
                    verifyLoginOTP(
                      mobileNumber: mobileNumber,
                      otp: otp,
                    );
                  },
                ),
              ),
            );
          },
        );
      } else {
        Get.snackbar('', '${otpData['message']}', backgroundColor:Colors.red, colorText: Colors.white );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong', backgroundColor:Colors.red, colorText: Colors.white );
      Get.find<LoadingController>().stopLoading();
    }
  }

  Future<void> verifyLoginOTP({
    required String mobileNumber,
    required String otp,
  }) async {
    Get.find<LoadingController>().startLoading();
    try {
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifyLoginOTP?mobile_number=${mobileNumber}&otp=${otp}'));
      request.bodyFields = {};
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
        } else {
          Get.snackbar('', '${jsonData['message']}', backgroundColor:Colors.red, colorText: Colors.white );
          if (kDebugMode) {
            print('Failed to authenticate');
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrganizationProofScreen(),
          ),
        );
      } else {
        Get.find<LoadingController>().stopLoading();
        Get.snackbar('', '${jsonData['message']}', backgroundColor:Colors.red, colorText: Colors.white );
      }
    } catch (e) {
      Get.find<LoadingController>().stopLoading();
      Get.snackbar('Error', 'Something went wrong', backgroundColor:Colors.red, colorText: Colors.white );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _numberController.dispose();
    _controllers.map((e) => e.dispose());
    _focusNodes.map((e) => e.dispose());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.success &&
            !_isOtpBottomSheetShown) {
          _isOtpBottomSheetShown = true;
          _showOtpBottomSheet(context);
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            current.loginStatus != previous.loginStatus,
        listener: (context, state) {
          // TODO: implement listener
        },
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(const LanguageSelectionPage());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey), // Border color
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
                    SizedBox(
                      width: width * 0.15,
                    ),
                    Text(
                      "app_header_title".tr,
                      style: TextStyle(
                        color: primaryColor, // Replace with your primaryColor
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        "login_screen_title".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "login_screen_sub_title".tr,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                        child: Text(
                          '+91',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                        ),
                      ),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (current, previous) =>
                            current.number == previous.number,
                        builder: (context, state) {
                          return Expanded(
                            child: TextField(
                                maxLength: 10,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                                controller: _numberController,
                                decoration: InputDecoration(
                                  counter: SizedBox.shrink(),
                                  contentPadding: EdgeInsets.only(top: 5),
                                  hintText:
                                      'login_screen_mobile_input_placeholder'
                                          .tr,
                                  hintStyle: const TextStyle(
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.phone,
                                key: const Key("value"),
                                onChanged: (value) => {
                                      context
                                          .read<LoginBloc>()
                                          .add(NumberChanged(number: value)),
                                    }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                SizedBox(
                  width: double.infinity,
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
                          primaryColor,
                        )),
                    onPressed: () =>
                        {generateSignupOTP(_numberController.text)},
                    // context.read<LoginBloc>().add(GenerateOtp()),
                    child: Obx(() => Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Get.find<LoadingController>().isLoading.value
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'initial_screen_login_button_text'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                        )),
                  ),
                ),
                SizedBox(height: height * 0.02),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style:
                        const TextStyle(fontSize: 18), // Apply the base style
                    children: [
                      TextSpan(
                        text: "login_screen_donot_have_account_question".tr,
                        style: TextStyle(color: greyColor),
                      ),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: 'login_screen_signup_hyperlink_text'.tr,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.32),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("signup_screen_signup_conditions_pretext".tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text(" "),
                        LinkText(
                            link:
                                "https://pub.dev/packages/url_launcher/example",
                            text:
                                "signup_screen_signup_conditions_terms_hyperlink"
                                    .tr),
                        const Text(",",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: height * 0.004),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinkText(
                            link:
                                "https://pub.dev/packages/url_launcher/example",
                            text:
                                "signup_screen_signup_conditions_policy_hyperlink"
                                    .tr),
                        const Text(" "),
                        Text("signup_screen_signup_conditions_separator".tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text(" "),
                        LinkText(
                            link:
                                "https://pub.dev/packages/url_launcher/example",
                            text:
                                "signup_screen_signup_conditions_cookie_use_hyperlink"
                                    .tr),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state.loginStatus == LoginStatus.loading) {
                      return const CircularProgressIndicator();
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
