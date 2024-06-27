import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends HydratedBloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupState()) {
    on<NumberChanged>(_onNumberChanged);
    on<OTPChanged>(_onOTPChanged);
    on<GenerateOtp>(_generateLoginOTP);
    on<VerifyOtp>(_verifyOtp);
    on<CheckNumber>(_checkNumber);
    on<DOBChanged>(_onDOBChanged);
    on<GenderChanged>(_onGenderChanged);
    on<NameChanged>(_onNameChanged);
  }

  void _onNumberChanged(NumberChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(number: event.number));
  }

  void _onOTPChanged(OTPChanged event, Emitter<SignupState> emit) {
    print("OTP OTP OTP ${event.otp}");
    emit(state.copyWith(otp: event.otp));
    print("OTP*4 ${state.otp}");
  }

  void _onDOBChanged(DOBChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(dateOfBirth: event.dateOfBirth));
  }

  void _onNameChanged(NameChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onGenderChanged(GenderChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(gender: event.gender));
  }

  Future<void> _checkNumber(
      CheckNumber event, Emitter<SignupState> emit) async {
    try {
      emit(state.copyWith(signUpStatus: SignUpStatus.loading));
      final uri = Uri.https(
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateOTP',
        '',
        {
          'mobile_number': state.number,
        },
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = data['message'];
        emit(state.copyWith(
            signUpStatus: SignUpStatus.numberAvailable, message: message));
      } else {
        emit(state.copyWith(
            signUpStatus: SignUpStatus.numberNotAvailable,
            message: data['message']));
      }
    } catch (e) {
      emit(state.copyWith(
          signUpStatus: SignUpStatus.numberNotAvailable,
          message: "Something Went Wrong"));
    }
  }

  Future<void> _generateLoginOTP(
      GenerateOtp event, Emitter<SignupState> emit) async {
    try {
      emit(state.copyWith(signUpStatus: SignUpStatus.loading));
      print(state.number);

      final response = await http.post(
        Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/generateSignupOTP?mobile_number=${state.number}',
        ),
      );
      final data = jsonDecode(response.body);
      print("data is ${data.toString()}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data is ${data.toString()}");

        emit(state.copyWith(
          otpStatus: OTPStatus.otpSent,
        ));
      } else {
        emit(state.copyWith(otpStatus: OTPStatus.otpNotSent));
      }
    } catch (e) {
      emit(state.copyWith(otpStatus: OTPStatus.otpNotSent));
    }
  }

  Future<void> _verifyOtp(VerifyOtp event, Emitter<SignupState> emit) async {
    print("OTP ${state.otp.toString()}");
    print("Nam ${state.name}");
    print("Num ${state.number}");
    try {
      emit(state.copyWith(signUpStatus: SignUpStatus.loading));

      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/verifySignupOTP'));
      request.bodyFields = {
        'mobile_number': state.number,
        'otp': state.otp,
        'name': state.name,
        'gender': state.gender.toLowerCase(),
        'date_of_birth': state.dateOfBirth,
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);

      print("Data ${jsonData.toString()}");
      if (response.statusCode == 200) {
        final token = jsonData['token'];
        final refreshToken = jsonData['refreshToken'];
        emit(state.copyWith(
            signUpStatus: SignUpStatus.halfDone,
            otpStatus: OTPStatus.otpVerified,
            token: token,
            refreshToken: refreshToken));
      } else {
        emit(state.copyWith(
            signUpStatus: SignUpStatus.error,
            otpStatus: OTPStatus.otpNotVerfied,
            message: jsonData['message'] ?? "Wrong OTP"));
      }
    } catch (e) {
      print(e.toString());
      emit(state.copyWith(
          signUpStatus: SignUpStatus.error, message: "Error while sign up"));
    }
  }

  @override
  SignupState? fromJson(Map<String, dynamic> json) {
    return SignupState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SignupState state) {
    return state.toMap();
  }
}
