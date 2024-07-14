import 'package:get/get.dart';

class LoadingController extends GetxController {
  var isLoading = false.obs;

  void startLoading() {
    isLoading.value = true;
  }

  void stopLoading() {
    isLoading.value = false;
  }
}

class SignupController extends GetxController {
  var mobileNumber = ''.obs;
  var name = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = ''.obs;

  bool get isFormValid =>
      mobileNumber.isNotEmpty &&
          name.isNotEmpty &&
          gender.isNotEmpty &&
          dateOfBirth.isNotEmpty;
}
