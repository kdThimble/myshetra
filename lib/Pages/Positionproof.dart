import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myshetra/helpers/colors.dart';
import 'map_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;


class PositionProofScreen extends StatefulWidget {
  @override
  State<PositionProofScreen> createState() => _PositionProofScreenState();
}

class _PositionProofScreenState extends State<PositionProofScreen> {
  TextEditingController positioncontroller = TextEditingController();
  var selectedFilePath = "";
  final authService = Get.find<AuthService>();

  Future<void> _submitData() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserPosition'), // Replace with your API endpoint
      );
      request.headers['Authorization'] =
          '${authService.token}'; // Replace with your auth token
      request.fields['position_name'] = positioncontroller.text;

      // Adding the file
      final file = await http.MultipartFile.fromPath(
        'supporting_documents', // Ensure this matches the server's expected field name
        selectedFilePath,
        filename: selectedFilePath,
      );
      request.files.add(file);

      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      print("responseData");
      print(responseData);
      if (response.statusCode == 200) {
        // Handle successful response
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(),
          ),
        );
      } else if (response.statusCode == 400) {
        // Parse the response data to get the error message
        var jsonResponse = json.decode(responseData);
        String errorMessage = jsonResponse['message'];

        // Show SnackBar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );

        print('Error: $errorMessage');
      } else {
        // Handle other error responses
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _openCamera(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final compressedImage = await _compressImage(File(image.path));
      if (compressedImage != null) {
        setState(() {
          selectedFilePath = compressedImage.path;
        });
        print(selectedFilePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image captured and compressed successfully'),
          ),
        );
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(compressedImage.path));
      } else {
        // Handle compression failure
        print("Compression failed");
      }
    }
  }

  Future<void> _openFilePicker(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path!;
      final compressedImage = await _compressImage(File(filePath));
      if (compressedImage != null) {
        setState(() {
          selectedFilePath = compressedImage.path;
        });
        print(selectedFilePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected and compressed successfully'),
          ),
        );
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(compressedImage.path));
      } else {
        // Handle compression failure
        print("Compression failed");
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, 'compressed_${path.basename(file.path)}');
    int quality = 100;
    XFile? compressedXFile;

    while (quality > 0) {
      compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressedXFile != null && await compressedXFile.length() <= 5 * 1024) {
        break;
      }
      quality -= 5;
    }

    return compressedXFile != null ? File(compressedXFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
          ],
        ),
        centerTitle: true,
        title: Text(
          "My Shetra",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Position Detail',
                  style: TextStyle(
                      fontSize: width * 0.07, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'If you hold any position, please type,and upload the proof for the same',
                  style: TextStyle(fontSize: 18, color: greyColor),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Position name ',
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: TextField(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  controller: positioncontroller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
                    hintText: 'Enter Here',
                    hintStyle: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  _openFilePicker(context);
                  // FilePickerResult? result =
                  // await FilePicker.platform.pickFiles();
                  //
                  // if (result != null) {
                  //   // Handle file picked
                  //   print('File picked: ${result.files.first.path}');
                  // } else {
                  //   // User canceled the picker
                  //   print('User canceled file picker');
                  // }
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedFilePath == ""
                      ? Center(child: Image.asset("assets/images/Content.png"))
                      : Image.file(
                          File(selectedFilePath!),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Implement file picker logic
                  _openCamera(context);
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset("assets/images/CameraIcon.png"),
                          const Text(
                            'Open camera & take Photo',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(
                height: 5,
              ),
              MyButton(onTap: _submitData, text: "Next"),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // Change button color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF0E3D8B)),
                        borderRadius: BorderRadius.circular(
                            10), // Make the button rounded
                      ),
                    ),
                    elevation:
                        MaterialStateProperty.resolveWith<double>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return 10; // Increase elevation when pressed
                      }
                      return 5; // Default elevation
                    }),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(1)), // Add padding
                    minimumSize: MaterialStateProperty.all<Size>(
                        const Size(double.infinity, 40)), // Set width to full
                    // side: MaterialStateProperty.all<BorderSide>(
                    //     BorderSide(color: Colors.blue)), // Add border
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: const Color(0xFF0E3D8B),
                        fontWeight: FontWeight.bold,
                        fontSize: Get.width * 0.06,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
