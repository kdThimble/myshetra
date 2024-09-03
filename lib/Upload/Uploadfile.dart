import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:myshetra/Pages/HomePage/HomePage.dart';

import 'package:video_player/video_player.dart';

import '../Services/Authservices.dart';

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:mime/mime.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
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
      fields['files[$i][checksum]'] = _generateChecksum(file); // Assuming this function exists
      fields['files[$i][orderID]'] = i.toString();
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlsFromFileMetaData'),
    );

    request.fields.addAll(fields);
    print("body of files");
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
      print("Error1234: ${response.reasonPhrase}");
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
      // await confirmPostFilesUploads(Response);
    }
  }

  // Future<void> _confirmFileUploads(Map<String, dynamic> confirmationData) async {
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/confirmPostFilesUploads'),
  //       headers: {
  //         'Authorization': '${authService.token.value}', // Ensure "Bearer" prefix
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(confirmationData),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('File uploads confirmed successfully.');
  //     } else {
  //       print('Failed to confirm file uploads. Status code: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error confirming file uploads: $e');
  //   }
  // }
  @override
  void initState() {
    super.initState();
    _loadFilesFromGallery();
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
      print('Error567: ${response.statusCode}');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Files')),
      body: Column(
        children: [
          Expanded(
            child: selectedFiles.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = selectedFiles[index];
                      final isVideo = file.path.endsWith('.mp4') ||
                          file.path.endsWith('.mov');

                      if (isVideo) {
                        final controller = _videoControllers[
                            _videoControllers.length > index ? index : 0];
                        return AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        );
                      } else {
                        return Image.file(file);
                      }
                    },
                  )
                : const Center(child: Text('No files selected')),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Hashtags',
                hintText: '#example',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: Captioncontroller,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: selectedFiles.isNotEmpty
                ? () => _uploadFiles(selectedFiles)
                : null,
            child: const Text('Upload Files'),
          ),
        ],
      ),
    );
  }
}
