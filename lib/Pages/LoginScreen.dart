import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshetra/Components/LinkText.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/Signup.dart';
import 'package:myshetra/bloc/login/login_bloc.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:http/http.dart' as http;

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
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Verify login details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(child: Text('We have sent a verification code to')),
                Center(
                  child: Text(
                    '+91-${context.read<LoginBloc>().state.number}',
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
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Resend OTP'),
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
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey), // Border color
                          shape: BoxShape.circle, // Rounded shape
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
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
                      "My Shetra",
                      style: TextStyle(
                        color: primaryColor, // Replace with your primaryColor
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        "Login Your Account",
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
                        "Please enter your number to sign up in shetra account",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: EdgeInsets.symmetric(vertical: 5),
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
                              fontSize: 20.0, fontWeight: FontWeight.w100),
                        ),
                      ),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (current, previous) =>
                            current.number == previous.number,
                        builder: (context, state) {
                          return Expanded(
                            child: TextField(
                                style:
                                    TextStyle(fontSize: 20, color: greyColor),
                                controller: _numberController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter mobile number',
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w200),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.phone,
                                key: Key("value"),
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
                        context.read<LoginBloc>().add(GenerateOtp()),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 18), // Apply the base style
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: greyColor),
                      ),
                      TextSpan(
                        text: 'Signup',
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
                        const Text("By signing up, you agree to our ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        LinkText(
                            link:
                                "https://pub.dev/packages/url_launcher/example",
                            text: "Terms"),
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
                            text: " Privacy Policy"),
                        const Text(" and ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        LinkText(
                            link:
                                "https://pub.dev/packages/url_launcher/example",
                            text: "Cookie Use"),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state.loginStatus == LoginStatus.loading) {
                      return CircularProgressIndicator();
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
