part of 'signup_bloc.dart';

sealed class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class NumberChanged extends SignupEvent {
  const NumberChanged({required this.number});
  final String number;

  @override
  List<Object> get props => [number];
}

class OTPChanged extends SignupEvent {
  const OTPChanged({required this.otp});

  final String otp;

  @override
  List<Object> get props => [otp];
}

class NameChanged extends SignupEvent {
  const NameChanged({required this.name});
  final String name;

  @override
  List<Object> get props => [name];
}

class GenderChanged extends SignupEvent {
  const GenderChanged({required this.gender});

  final String gender;

  @override
  List<Object> get props => [gender];
}

class DOBChanged extends SignupEvent {
  const DOBChanged({required this.dateOfBirth});

  final String dateOfBirth;

  @override
  List<Object> get props => [dateOfBirth];
}

class CheckNumber extends SignupEvent {}

class VerifyOtp extends SignupEvent {}

class GenerateOtp extends SignupEvent {}
