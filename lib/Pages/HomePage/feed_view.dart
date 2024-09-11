import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myshetra/Components/post_card.dart';
import 'package:myshetra/Models/post_model.dart';
import 'package:myshetra/Services/Authservices.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final authService = Get.find<AuthService>();
  Map<String, dynamic> jsonResponse = {};
  Future<void> getUserAreaFeeds() async {
    print("in function");
    const String url =
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/post/getContentForUserArea';

    try {
      final response = await http.get(Uri.parse(url),
          headers: {'Authorization': '${authService.token}'});
      print("token ${authService.token}");
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
        print('Request successful:');
        print("jsonResponse $jsonResponse");
        setState(() {});
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserAreaFeeds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Step 2: Parse the response string into a Map

    // Step 3: Convert the JSON response to the ApiResponse model
    ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse["data"]);
    print("post ${apiResponse.posts[0].title}");
    print("Length ${apiResponse.posts.length}");
    return Scaffold(
      body: apiResponse.posts.isNotEmpty
          ? ListView.builder(
              itemCount: apiResponse.posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: apiResponse.posts[index]);
              },
            )
          : const Text("No post"),
    );
  }
}
