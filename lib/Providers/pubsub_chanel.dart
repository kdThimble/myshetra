import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:myshetra/Services/Authservices.dart';

class PubSubService {
  final authService = Get.find<AuthService>();
  final String channelUrl =
      'https://seal-app-eq6ra.ondigitalocean.app/myshetra/pubsub/subscribeChannel?channel=post_creation';

  // Flag to control polling
  bool _isPolling = false;

  // Function to start polling
  void startListening() {
    _isPolling = true;
    _pollChannel();
  }

  // Function to stop polling
  void stopListening() {
    _isPolling = false;
  }

  // Long polling function
  Future<void> _pollChannel() async {
    while (_isPolling) {
      try {
        print("in polling");
        final response = await http.get(Uri.parse(channelUrl),
            headers: {'Authorization': '${authService.token}'});
        print("Response of polling ${response.body}");
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Received data: $data');

          // Process the data or notify listeners
          // ...
        } else {
          print('Failed to subscribe: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }

      // Wait a short time before making another request to avoid spamming the server
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
