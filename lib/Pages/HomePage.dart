import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/AuthPage.dart';
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Pages/map_page.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Authmodel.dart';
import '../Providers/AuthProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = Get.find<AuthService>();

  Future<void> logout() async {
    print(authService.token);
    var headers = {
      'Authorization':
          '${authService.token}', // Authorization header with the token
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/signOut'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      print(responseData);

      // Delete token and refreshToken from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refreshToken');
      prefs.setString('issignupcompleted', 'false'); // Save the name

      Get.to(AuthPage());
    } else {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      print(responseData);
      print(response.statusCode);
      print(response.toString());

      Fluttertoast.showToast(
          msg: response.reasonPhrase ?? "Server Error",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
    }
  }
  Future<void> refreshAuthToken() async {
    print("swxaL:${authService.refreshToken}");
    var headers = {
      'Refresh-Token':
      '${authService.refreshToken}', // Authorization header with the token
    };

    var request = http.Request('POST', Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/refreshToken'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var jsonData = json.decode(responseBody);
    print("Response code: ${jsonData}");

    // Get.find<LoadingController>().stopLoading();

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonData['data']);
      print(responseBody);
      if (authResponse.refreshToken != null && authResponse.token != null) {
        // Save the tokens to secure storage or a state management solution
        Provider.of<AuthProvider>(context, listen: false)
            .setAuthResponse(authResponse);
        Get.find<AuthService>()
            .setAuthResponse(authResponse.token, authResponse.refreshToken);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authResponse.token);
        await prefs.setString('refreshToken', authResponse.refreshToken);
      } else {
        // Get.snackbar('Error', 'Failed to authenticate');
        print('Failed to authenticate');
      }
    }
     else {
      print('Failed to refresh token: ${response.reasonPhrase}');
      // Handle the error
    }
  }
  // Call the API here
  @override
  void initState() {
    // TODO: implement initState
    refreshAuthToken();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          const Center(
            child: Text('This is the home page'),
          ),
          SizedBox(
            height: 20,
          ),
          MyButton(
              onTap: () {
                Get.to(EditProfilePage());
              },
              text: "Edit Profile"),
          MyButton(
              onTap: () {
                Get.to(MapPage(ishomescreen:true));
              },
              text: "Change Location"),
          MyButton(
              onTap: () {
                logout();
              },
              text: "Logout")
        ],
      ),
    );
  }
}
