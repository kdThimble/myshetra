import 'package:flutter/material.dart';
import 'package:myshetra/Models/Authmodel.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthResponse? _authResponse;
  String? _otp;
  AuthResponse? get authResponse => _authResponse;
  String? get otp => _otp;

  void setAuthResponse(AuthResponse response) {
    _authResponse = response;
    notifyListeners();
  }

  void setOTP(String otp) {
    _otp = otp;
    notifyListeners();
  }
}
