import 'package:get/get.dart';
import 'package:myshetra/Controller/networkController.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
