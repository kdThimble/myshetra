import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:video_player/video_player.dart';

import '../Services/Authservices.dart';

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:mime/mime.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final authService = Get.find<AuthService>();
  var Response;
  List<File> selectedFiles = [];
  List<VideoPlayerController> _videoControllers = [];
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
      'Authorization': '${authService.token.value}', // Ensure "Bearer" prefix
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
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlsFromFileMetaData'),
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

  Future<void> _uploadFileToPreSignedUrl(String url, File file, String mimeType, String contentType, int fileSize) async {
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

      await _uploadFileToPreSignedUrl(url, file, mimeType, contentType, fileSize);
      await _confirmFileUploads(Response);
    }
  }
  Future<void> _confirmFileUploads(Map<String, dynamic> confirmationData) async {
    try {
      var response = await http.post(
        Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/confirmFileUploads'),
        headers: {
          'Authorization': '${authService.token.value}', // Ensure "Bearer" prefix
          'Content-Type': 'application/json',
        },
        body: jsonEncode(confirmationData),
      );

      if (response.statusCode == 200) {
        print('File uploads confirmed successfully.');
      } else {
        print('Failed to confirm file uploads. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error confirming file uploads: $e');
    }
  }
  // Future<bool> uploadFiles(List<File> files) async {
  //   var headers = {
  //     'Authorization': '${authService.token}',
  //   };
  //   if (files.length > 5) {
  //     print('Cannot upload more than 5 files.');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Cannot upload more than 5 files '),backgroundColor: Colors.red,),
  //     );
  //     return false;
  //   }
  //
  //   var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlToUploadFile'));
  //
  //   for (var file in files) {
  //     request.files.add(await http.MultipartFile.fromPath('files_to_upload', file.path));
  //   }
  //
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //     return true;
  //   } else {
  //     print(response.reasonPhrase);
  //     return false;
  //   }
  // }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        selectedFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? videoFile = await picker.pickVideo(source: ImageSource.gallery);

    if (videoFile != null) {
      File video = File(videoFile.path);
      setState(() {
        selectedFiles.add(video);
      });

      // Initialize video controller
      final VideoPlayerController videoController = VideoPlayerController.file(video)
        ..initialize().then((_) {
          setState(() {}); // Ensure the UI updates after the video is initialized
        });
      _videoControllers.add(videoController);
    }
  }

  // void _uploadFiles() async {
  //   bool success = await uploadFiles(selectedFiles);
  //
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Files uploaded successfully!' ) ,backgroundColor: Colors.green,),
  //     );
  //     Get.to( HomePage());
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to upload files')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Files')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pickVideo,
                child: Text('Pick Video'),
              ),
            ],
          ),
          selectedFiles.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                final file = selectedFiles[index];
                final isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov');

                if (isVideo) {
                  final controller = _videoControllers[_videoControllers.length > index ? index : 0];
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  return Image.file(file);
                }
              },
            ),
          )
              : Text('No files selected'),
          ElevatedButton(
            onPressed: selectedFiles.isNotEmpty
                ? () => _uploadFiles(selectedFiles)
                : null,
            child: Text('Upload Files'),
          ),
        ],
      ),
    );
  }
}