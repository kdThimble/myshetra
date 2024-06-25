part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, error }

 class LoginState extends Equatable {
 const LoginState(
      {this.number = '',
      this.otp = '',
      this.message = '',
      this.token,
      this.refreshToken,
      this.loginStatus = LoginStatus.initial});

  final String number;
  final String otp;
  final String message;
  final String? token;
  final String? refreshToken;
  final LoginStatus loginStatus;

  LoginState copyWith({
    String? number,
    String? otp,
    String? message,
    String? token,
    String? refreshToken,
    LoginStatus? loginStatus, 
  }) {
    return LoginState(
      number: number ?? this.number,
      otp: otp ?? this.otp,
      message: message ?? this.message,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      loginStatus: loginStatus ?? this.loginStatus,
    );
  }
  factory LoginState.fromMap(Map<String, dynamic> map) {
    return LoginState(
      number: map['number'] as String,
      otp: map['otp'] as String,
      token: map['token'] as String?,
      loginStatus: LoginStatus.values.firstWhere(
        (status) => status.name == map['loginStatus'],
        orElse: () => LoginStatus.initial,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'otp': otp,
      'token': token,
      'refreshToken':refreshToken,
      'loginStatus': loginStatus.name,
    };
  }
  
  @override
  List<Object> get props => [number,otp,message,loginStatus];
}


