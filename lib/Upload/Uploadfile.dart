import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:video_player/video_player.dart';

import '../Services/Authservices.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final authService = Get.find<AuthService>();
  List<File> selectedFiles = [];
  List<VideoPlayerController> _videoControllers = [];
  Future<bool> uploadFiles(List<File> files) async {
    var headers = {
      'Authorization': '${authService.token}',
    };
    if (files.length > 5) {
      print('Cannot upload more than 5 files.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot upload more than 5 files '),backgroundColor: Colors.red,),
      );
      return false;
    }

    var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlToUploadFile'));

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files_to_upload', file.path));
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

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

  void _uploadFiles() async {
    bool success = await uploadFiles(selectedFiles);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files uploaded successfully!' ) ,backgroundColor: Colors.green,),
      );
      Get.to( HomePage());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload files')),
      );
    }
  }

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
            onPressed: selectedFiles.isNotEmpty ? _uploadFiles : null,
            child: Text('Upload Files'),
          ),
        ],
      ),
    );
  }
}