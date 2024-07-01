import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'map_page.dart';

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
            builder: (context) => MapPage(
            ),
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
      try {
        setState(() {
          selectedFilePath = image.path;
        });
        print(selectedFilePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image captured successfully'),
          ),
        );
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(croppedImage.path));
      } catch (error) {
        // Handle errors during upload
        print("Error during upload: $error");
      } finally {
        // Dismiss the loading overlay
        // await uploadImage(context, XFile(croppedImage.path));
      }
    }
  }

  Future<void> _openFilePicker(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Specify the allowed file type as an image
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path!;

      setState(() {
        selectedFilePath = result.files.single.path!;
      });
      try {
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(croppedImage.path));
      } catch (error) {
        // Handle errors during upload
        print("Error during upload: $error");
      } finally {
        // Dismiss the loading overlay
        print("fiunal");
        print(selectedFilePath);
        // await uploadImage(context, XFile(croppedImage.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // iOS style back button
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Implement skip logic
            },
            child: Text('Skip', style: TextStyle(color: Colors.black)),
          ),
        ],
        title: Text(''),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'If you hold any position, please type',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'and upload the proof for the same',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  controller: positioncontroller,
                  decoration: const InputDecoration(
                    contentPadding:
                    EdgeInsets.only(left: 15, top: 5, bottom: 5),
                    hintText: 'Type the position name here',
                    hintStyle: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w200),
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
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedFilePath == ""
                      ? const Center(
                    child: Text(
                      'Select file',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  )
                      : Image.file(
                    File(selectedFilePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey, // Use the color #3F1444
                        thickness: 1,
                      ),
                    ),
                    Center(
                      child: Text(
                        '  or  ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey, // Use the color #3F1444
                        thickness: 1,
                      ),
                    ),
                  ],
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Open camera & take Photo',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),
              Align(
                alignment: Alignment.bottomCenter,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF5252), // Background color
                  ),
                  onPressed: () {
                    // OrganizationProofScreen
                    _submitData();
                    // verifySignupOTP(
                    //   mobileNumber: mobileNumberController.text,
                    //   otp: otpcontroller.text,
                    //   name: nameController.text,
                    //   gender: gender,
                    //   dateOfBirth: dateOfBirthController.text,
                    // );
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}