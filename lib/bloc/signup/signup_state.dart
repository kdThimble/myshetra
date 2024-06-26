part of 'signup_bloc.dart';

enum SignUpStatus {
  initial,
  loading,
  success,
  error,
  halfDone,
  organisationDone,
  locationDone,
  numberAvailable,
  numberNotAvailable
}

 class SignupState extends Equatable {
  const SignupState(
      {this.name = '',
      this.number = '',
      this.otp = '',
      this.gender = 'male',
      this.dateOfBirth = '',
      this.message = '',
      this.token,
      this.refreshToken,
      this.signUpStatus = SignUpStatus.initial});

  final String name;
  final String number;
  final String otp;
  final String gender;
  final String dateOfBirth;
  final String message;
  final String? token;
  final String? refreshToken;
  final SignUpStatus signUpStatus;

  SignupState copyWith({
  String? name,
   String? number,
   String? otp,
   String? gender,
   String? dateOfBirth,
   String? message,
   String? token,
   String? refreshToken,
   SignUpStatus? signUpStatus,
  }){
     return SignupState(
      name: name ?? this.name,
      gender: gender??this.gender,
      dateOfBirth: dateOfBirth??this.dateOfBirth,
      number: number ?? this.number,
      otp: otp ?? this.otp,
      message: message ?? this.message,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      signUpStatus: signUpStatus ?? this.signUpStatus,
    );
  }

  factory SignupState.fromMap(Map<String, dynamic> map) {
    return SignupState(
      name: map['name'] ?? '',
      number: map['number'] ?? '',
      otp: map['otp'] ?? '',
      gender: map['gender'] ?? 'male',
      dateOfBirth: map['dateOfBirth'] ?? '',
      message: map['message'] ?? '',
      token: map['token'],
      refreshToken: map['refreshToken'],
      signUpStatus: SignUpStatus.values.firstWhere(
          (e) => e.toString() == 'SignUpStatus.${map['signUpStatus']}',
          orElse: () => SignUpStatus.initial),
    );
  }


   Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'otp': otp,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'signUpStatus': signUpStatus.toString().split('.').last,
    };
  }


 @override
  List<Object?> get props => [
        name,
        number,
        otp,
        gender,
        dateOfBirth,
        message,
        token,
        refreshToken,
        signUpStatus,
      ];
}
