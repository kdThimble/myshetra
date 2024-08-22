import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Models/UserModel.dart';
import 'package:myshetra/Pages/HomePage/HomePage.dart';
import 'package:myshetra/Pages/HomePage/upload_post.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/Services/user_shared_pref.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:video_player/video_player.dart';

import 'package:mime/mime.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  UserProfile? profile;
  List<AssetEntity> images = [];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchImages();
  }

  Future<void> _loadUserProfile() async {
    UserProfilePreference prefs = UserProfilePreference();
    UserProfile? loadedProfile = await prefs.loadUserProfile();
    setState(() {
      profile = loadedProfile;
    });
  }

  Future<void> _fetchImages() async {
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: 0, size: 100);
      setState(() {
        images = media;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  TextEditingController Captioncontroller = TextEditingController();

  final authService = Get.find<AuthService>();
  Set<AssetEntity> selectedImages = {};
  final List<VideoPlayerController> _videoControllers = [];

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final file = File(photo.path);

      // Process the file if needed and add it to selectedImages
      AssetEntity? capturedAsset = await PhotoManager.editor
          .saveImageWithPath(photo.path, title: photo.name);
      if (capturedAsset != null) {
        setState(() {
          selectedImages.add(capturedAsset);
          images.insert(0,
              capturedAsset); // Optionally, add it to the gallery list as well
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: height * 0.03),
                Row(
                  children: [
                    SizedBox(width: width * 0.04),
                    GestureDetector(
                      onTap: () {
                        Get.to(const HomePage());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.17),
                    Text(
                      "Create Post",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (profile != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: width * 0.136,
                        backgroundColor: Colors.white,
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
                            profile?.bioInfo != ""
                                ? profile!.bioInfo!
                                : "No bio",
                            style: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )
                    ],
                  )
                else
                  const CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: Captioncontroller,
                    decoration: const InputDecoration(
                      labelText: 'Write a caption...',
                      hintText: 'Write a caption...',
                      contentPadding: EdgeInsets.all(10.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.56, // Adjust the initial height of the sheet
              minChildSize: 0.56, // Minimum height of the sheet
              maxChildSize: 0.68, // Maximum height of the sheet

              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(
                          0xFFD8DBE5), // Set the color of the top border
                      width: 1.0, // Set the width of the top border
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                          35.0), // Set the radius for the top-left corner
                      topRight: Radius.circular(
                          35.0), // Set the radius for the top-right corner
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.25,
                            height: 8,
                            decoration: BoxDecoration(
                                color: const Color(0xFFD8DBE5),
                                borderRadius: BorderRadius.circular(13)),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors
                                  .white, // Background color of the container
                              border: Border.all(
                                color: greyColor, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt_outlined,
                                color: greyColor,
                              ),
                              onPressed: _pickFromCamera,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // const Divider(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            controller: scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final image = images[index];
                              final isSelected = selectedImages.contains(image);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedImages.remove(image);
                                    } else {
                                      selectedImages.add(image);
                                    }
                                  });
                                },
                                child: Stack(
                                  children: [
                                    FutureBuilder<Uint8List?>(
                                      future: image.thumbnailData,
                                      builder: (context, snapshot) {
                                        final bytes = snapshot.data;
                                        if (bytes == null) {
                                          return Container(
                                              color: Colors.grey[300]);
                                        }
                                        return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.memory(
                                              bytes,
                                              fit: BoxFit.cover,
                                              width: width * 0.32,
                                              height: height * 0.15,
                                            ));
                                      },
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: MyButton(
                    onTap: () {
                      if (Captioncontroller.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Caption can not be empty",
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white);
                      } else {
                        if (selectedImages.isNotEmpty) {
                          // Navigate to the new screen with selected images
                          Get.to(SelectedImagesScreen(
                            images: selectedImages,
                            caption: Captioncontroller.text,
                          ));
                        }
                      }
                    },
                    text: "Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
