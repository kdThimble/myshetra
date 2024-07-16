import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<NumberChanged>(_onNumberChanged);
    on<OTPChanged>(_onOTPChanged);
    on<LoginApi>(_loginApi);
    on<GenerateOtp>(_generateLoginOTP);
    on<VerifyOtp>(_verifyOtp);
  }

  void _onNumberChanged(NumberChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(number: event.number));
  }

  void _onOTPChanged(OTPChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _loginApi(LoginApi event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(loginStatus: LoginStatus.loading));
      final uri = Uri.https(
        'seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifyLoginOTP',
        '',
        {
          'mobile_number': state.number,
          'otp': state.otp,
        },
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final refreshToken = data['refreshToken'];
        emit(state.copyWith(loginStatus: LoginStatus.success, token: token));
        emit(state.copyWith(
            loginStatus: LoginStatus.success, refreshToken: refreshToken));
      } else {
        emit(state.copyWith(loginStatus: LoginStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(loginStatus: LoginStatus.error));
    }
  }

  Future<void> _verifyOtp(VerifyOtp event, Emitter<LoginState> emit) async {
    print("OTP ${state.otp}");
    try {
      emit(state.copyWith(loginStatus: LoginStatus.loading));

      final uri = Uri.https(
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifyLoginOTP',
        '',
        {
          'mobile_number': state.number,
          'otp': state.otp,
        },
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final refreshToken = data['refreshToken'];
        emit(state.copyWith(
            loginStatus: LoginStatus.success,
            token: token,
            refreshToken: refreshToken));
      } else {
        emit(state.copyWith(loginStatus: LoginStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(loginStatus: LoginStatus.error));
    }
  }

  Future<void> _generateLoginOTP(
      GenerateOtp event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(loginStatus: LoginStatus.loading));
      print(state.number);

      final response = await http.post(
        Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateLoginOTP?mobile_number=${state.number}',
        ),
      );
      final data = jsonDecode(response.body);
      print("data is ${data.toString()}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data is ${data.toString()}");

        emit(state.copyWith(
          loginStatus: LoginStatus.success,
        ));
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('${data['message']}'),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        Get.snackbar('', '${data['message']}', backgroundColor:Colors.red, colorText: Colors.white );
        emit(state.copyWith(loginStatus: LoginStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(loginStatus: LoginStatus.error));
    }
  }

  @override
  LoginState? fromJson(Map<String, dynamic> json) {
    return LoginState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(LoginState state) {
    return state.toMap();
  }
}
