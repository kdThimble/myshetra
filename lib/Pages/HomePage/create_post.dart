import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:myshetra/Models/UserModel.dart';
import 'package:myshetra/Pages/HomePage/HomePage.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/Services/user_shared_pref.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:video_player/video_player.dart';

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:mime/mime.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  UserProfile? profile;
  List<AssetEntity> images = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchImages();
    // _loadFilesFromGallery();
  }

  File? _profileImage;

  Future<void> _loadUserProfile() async {
    UserProfilePreference prefs = UserProfilePreference();
    UserProfile? loadedProfile = await prefs.loadUserProfile();
    setState(() {
      profile = loadedProfile;
    });
  }

  Future<void> _fetchImages() async {
    // Request permissions
    var result = await PhotoManager.requestPermissionExtend();

    if (result.isAuth) {
      // Fetch gallery images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: 0, size: 100);

      setState(() {
        images = media;
      });
    } else {
      // Handle permission denial
      PhotoManager.openSetting();
    }
  }

  final authService = Get.find<AuthService>();
  var Response;
  List<File> selectedFiles = [];
  final List<VideoPlayerController> _videoControllers = [];
  void _extractFileDetails(File file) {
    String fileName = file.path.split('/').last;
    int fileSize = file.lengthSync();
    String mimeType = lookupMimeType(file.path) ?? '';

    print('File Name: $fileName');
    print('File Size: $fileSize bytes');
    print('MIME Type: $mimeType');
  }

  String _generateChecksum(File file) {
    var bytes = file.readAsBytesSync();
    var checksum = md5.convert(bytes);
    return checksum.toString();
  }

  Future<List<dynamic>> _getPreSignedUrls(List<File> files) async {
    print("token: ${authService.token.value}");

    var headers = {
      'Authorization': authService.token.value, // Ensure "Bearer" prefix
      'Content-Type': 'application/json',
    };

    var fields = <String, String>{};

    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      fields['files[$i][fileName]'] = file.path.split('/').last;
      fields['files[$i][size]'] = file.lengthSync().toString();
      fields['files[$i][mimeType]'] = lookupMimeType(file.path) ?? '';
      fields['files[$i][contentType]'] = lookupMimeType(file.path) ?? '';
      fields['files[$i][checksum]'] =
          _generateChecksum(file); // Assuming this function exists
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlsFromFileMetaData'),
    );

    request.fields.addAll(fields);
    print(fields);
    request.headers.addAll(headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      print("Response: $decodedResponse");
      setState(() {
        Response = decodedResponse['data']['response'];
      });
      return decodedResponse['data']['response']['files'];
    } else {
      print("Error: ${response.reasonPhrase}");
      return [];
    }
  }

  Future<void> _uploadFileToPreSignedUrl(String url, File file, String mimeType,
      String contentType, int fileSize) async {
    var headers = {
      'Content-Type': mimeType,
      'x-amz-meta-contenttype': contentType,
      'x-amz-meta-filesize': fileSize.toString(),
    };

    var request = http.Request('PUT', Uri.parse(url));
    request.bodyBytes = file.readAsBytesSync();
    request.headers.addAll(headers);

    var response = await request.send();

    // Convert StreamedResponse to a full Response
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('Failed to upload file: ${response.reasonPhrase}');
    }

    print('Response Status: ${response.statusCode}');
    print('Response Reason: ${response.reasonPhrase}');
    print('Response Body: $responseBody');
  }

  Future<void> _uploadFiles(List<File> files) async {
    var preSignedUrls = await _getPreSignedUrls(files);
    print(Response);
    if (preSignedUrls.isEmpty) {
      print('No pre-signed URLs received. Aborting upload.');
      return;
    }

    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      var url = preSignedUrls[i]['signed_url'];
      var mimeType = lookupMimeType(file.path) ?? '';
      var contentType = lookupMimeType(file.path) ?? '';
      var fileSize = file.lengthSync();

      await _uploadFileToPreSignedUrl(
          url, file, mimeType, contentType, fileSize);
      await confirmPostFilesUploads(Response);
    }
  }

  // Function to load images and videos from the gallery
  void _loadFilesFromGallery() async {
    final picker = ImagePicker();

    // Pick multiple images
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      selectedFiles.addAll(images.map((image) => File(image.path)).toList());
    });

    // Pick a video
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedFiles.add(File(video.path));
        _initializeVideoController(File(video.path));
      });
    }
  }

  // Function to initialize video controllers
  void _initializeVideoController(File videoFile) {
    final controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {}); // Refresh UI after initializing
      });
    _videoControllers.add(controller);
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      selectedFiles.addAll(images.map((image) => File(image.path)).toList());
    });
  }

  void _pickVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedFiles.add(File(video.path));
        _initializeVideoController(File(video.path));
      });
    }
  }

  Future<void> confirmPostFilesUploads(
      Map<String, dynamic> responseData) async {
    // Extract data from the response
    String postId = responseData['post_id'];
    List<Map<String, dynamic>> files =
        List<Map<String, dynamic>>.from(responseData['files']);

    // Define headers
    var headers = {
      'Authorization': authService.token.value, // Ensure "Bearer" prefix
      'Content-Type': 'multipart/form-data',
    };

    // Create the request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/confirmPostFilesUploads'),
    );

    // Add fields to the request
    request.fields['post_id'] = postId;
    request.fields['content'] = Captioncontroller.text;
    request.fields['user_mentions[0][token]'] = '{user1}';
    request.fields['user_mentions[0][user_id]'] =
        '397948bb-80d0-499b-9d6e-778886075eae';
    request.fields['hashtags[0]'] = 'hashtag';

    // Add files to the request dynamically
    for (int i = 0; i < files.length; i++) {
      request.fields['files[$i][file_id]'] = files[i]['file_id'];
      request.fields['files[$i][unique_name]'] = files[i]['unique_name'];
      request.fields['files[$i][checksum]'] = files[i]['metadata']['checksum'];
    }

    // Add headers to the request
    request.headers.addAll(headers);
    // request.fields.addAll(fields);
    print('Request Fields: ${request.fields}');
    print('Request Headers: ${request.headers}');
    // Send the request
    http.StreamedResponse response = await request.send();
    print(request);
    // Handle the response
    if (response.statusCode == 200) {
      print('Success: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Files uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Get.to(const HomePage());
      print(await response.stream.bytesToString());
    } else {
      print('Error: ${response.statusCode}');
      print('Response Reason: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.reasonPhrase}')),
      );
      String responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');
    }
  }

  final TextEditingController Captioncontroller = TextEditingController();

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
            ],
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TextField(
                controller: Captioncontroller,
                decoration: const InputDecoration(
                  labelText: 'Write a caption...',
                  hintText: 'Write a caption...',
                  contentPadding: EdgeInsets.all(10.0),
                  border: InputBorder.none,

                  // border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Hashtags',
                  hintText: '#example',
                  contentPadding: EdgeInsets.all(10.0),
                  border: InputBorder.none,
                ),
              ),
            ),
            images.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns in grid view
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Uint8List?>(
                        future: images[index].thumbnailData,
                        builder: (context, snapshot) {
                          final bytes = snapshot.data;
                          if (bytes == null) {
                            return Container(color: Colors.grey[300]);
                          }
                          return Image.memory(bytes, fit: BoxFit.cover);
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
