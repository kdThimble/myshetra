import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myshetra/Models/UserModel.dart';
import 'package:myshetra/Pages/AuthPage.dart';
import 'package:myshetra/Pages/HomePage/HomePage.dart';
import 'package:myshetra/Services/user_shared_pref.dart';
import 'package:myshetra/helpers/colors.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  File? _profileImage;

  Future<void> _loadUserProfile() async {
    UserProfilePreference prefs = UserProfilePreference();
    UserProfile? loadedProfile = await prefs.loadUserProfile();
    setState(() {
      profile = loadedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    print("Profile ${profile?.handleName}");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.03,
            ),
            Row(
              children: [
                SizedBox(
                  width: width * 0.04,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(const HomePage());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey), // Border color
                      shape: BoxShape.circle, // Rounded shape
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back, // Back icon
                        color: Colors.black, // Icon color
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.17,
                ),
                Text(
                  "Create Post",
                  style: TextStyle(
                    color: Colors.black, // Replace with your primaryColor
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // You can now use the loaded profile data here
            if (profile != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.136,
                    backgroundColor: Colors.white, // Adjust as needed
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider<Object>
                        : profile?.profileImageUrl !=
                                "https://dev-my-shetra.blr1.cdn.digitaloceanspaces.com/admin_files/FallBackProfileImage.jpeg"
                            ? NetworkImage(profile?.profileImageUrl ??
                                "https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph")
                            : const NetworkImage(
                                'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph'),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name?.capitalize ?? "User",
                        style: TextStyle(
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile?.bioInfo != "" ? profile!.bioInfo! : "No bio",
                        style: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  )
                ],
              ) // Example usage of profile data
            ] else ...[
              const CircularProgressIndicator(), // Show loading indicator while profile is being loaded
            ]
          ],
        ),
      ),
    );
  }
}
