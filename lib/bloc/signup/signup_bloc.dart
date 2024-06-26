import 'dart:convert';

import 'package:equatable/equatable.dart';
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
    emit(state.copyWith(otp: event.otp));
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
       if (response.statusCode == 200){
        
        final message = data['message'];
         emit(state.copyWith(
            signUpStatus: SignUpStatus.numberAvailable,
            
            message: message));
       } else {
        emit(state.copyWith(signUpStatus: SignUpStatus.numberNotAvailable,message: data['message']));
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
          signUpStatus: SignUpStatus.success,
        ));
      } else {
        emit(state.copyWith(signUpStatus: SignUpStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(signUpStatus: SignUpStatus.error));
    }
  }

      

  Future<void> _verifyOtp(VerifyOtp event, Emitter<SignupState> emit) async {}

  @override
  SignupState? fromJson(Map<String, dynamic> json) {
    return SignupState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SignupState state) {
    return state.toMap();
  }
}
