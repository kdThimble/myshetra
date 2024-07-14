import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection(); // Check the initial connection status
  }

  void _checkInitialConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      isConnected.value = false;
    } else {
      isConnected.value = true;
    }

    if (!isConnected.value) {
      // _showNoInternetDialog();
      _showNoInternetSnackbar();
    } else {
      _closeNoInternetDialog();
      _closeNoInternetSnackbar();
    }
  }

  // void _showNoInternetDialog() {
  //   if (Get.isDialogOpen != true) {
  //     Get.defaultDialog(
  //       barrierDismissible: true,
  //       backgroundColor: Colors.white,
  //       title: 'No internet',
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SizedBox(height: 20),
  //           Image.asset(
  //               "assets/images/nointernet-transformed-removebg-preview-transformed.png"),
  //           SizedBox(height: 20),
  //           Text(
  //             'Please Connect to the internet',
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}

void _showNoInternetSnackbar() {
  if (!Get.isSnackbarOpen) {
    Get.rawSnackbar(
      borderColor: Colors.grey,
      borderRadius: 10,
      messageText: Container(
        height: Get.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No internet Connection',
                style: TextStyle(
                    color: Colors.red[400]!,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              SizedBox(height: 20),
              Image.asset(
                  "assets/images/nointernet-transformed-removebg-preview-transformed.png"),
              SizedBox(height: 20),
              Text(
                'Please Connect to the internet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
      duration: const Duration(days: 1),
      backgroundColor: Colors.white,
      barBlur: 5,
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}

void _closeNoInternetDialog() {
  if (Get.isDialogOpen == true) {
    Get.back();
  }
}

void _closeNoInternetSnackbar() {
  if (Get.isSnackbarOpen) {
    try {
      Get.closeAllSnackbars();
    } catch (e) {
      // Handle the case where snackbar is already disposed
    }
  }
}
