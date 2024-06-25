part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class NumberChanged extends LoginEvent {
  const NumberChanged({required this.number});
  final String number;

  @override
  List<Object> get props => [number];
}

class OTPChanged extends LoginEvent {
  const OTPChanged({required this.otp});

  final String otp;

  @override
  List<Object> get props => [otp];
}

class LoginApi extends LoginEvent {}

class VerifyOtp extends LoginEvent {}

class GenerateOtp extends LoginEvent {}
