import 'package:flutter/material.dart';
import 'package:myshetra/Models/Authmodel.dart';
import 'package:provider/provider.dart';


class AuthProvider extends ChangeNotifier {
  AuthResponse? _authResponse;

  AuthResponse? get authResponse => _authResponse;

  void setAuthResponse(AuthResponse response) {
    _authResponse = response;
    notifyListeners();
  }
}
