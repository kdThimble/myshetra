import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myshetra/Models/OrganisationModel.dart';

import 'Positionproof.dart';

class OrganizationProofScreen extends StatefulWidget {

  @override
  State<OrganizationProofScreen> createState() =>
      _OrganizationProofScreenState();
}

class _OrganizationProofScreenState extends State<OrganizationProofScreen> {
  String? _selectedValue;
  late Future<OrganisationModel> _futureOrganisationModel;
  OrganisationModel? _organisationModel;
  @override
  void initState() {
    super.initState();
    fetchOrganisationData();
  }

  Future<OrganisationModel> getPostApi() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getAllOrganization'),
        headers: {
          'Authorization':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiI5MjA1MTU0MzM2IiwidXNlcl9pZCI6IjY2NzliOTA5NTdiMWE0YmE0ZDk4MTJkMCIsInVzZXJfdHlwZSI6ImdlbmVyYWxfdXNlciIsImV4cCI6MTcxOTMzOTY1N30.zT2PDrQAhZBe0X_HUyM5DdhY8o0OBi_69GqIgIZk7j0',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return OrganisationModel.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (error) {
      throw Exception('error fetching data');
    }
    throw Exception('error fetching data');
  }

  void fetchOrganisationData() async {
    _organisationModel = await getPostApi();
    setState(() {});
  }


  Future<void> _openCamera(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
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

      try {
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(croppedImage.path));
      } catch (error) {
        // Handle errors during upload
        print("Error during upload: $error");
      } finally {
        // Dismiss the loading overlay
        print("fiunal");
        // await uploadImage(context, XFile(croppedImage.path));
      }
    }
  }

  var newData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // iOS style back button
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Implement skip logic
            },
            child: const Text('Skip', style: TextStyle(color: Colors.black)),
          ),
        ],
        title: const Text(''),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'If you belong to any organization,',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'please select and upload the proof',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'for the same.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              _organisationModel == null
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton(
                value: _selectedValue,
                hint: Text('Select value'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _organisationModel!.organizations!.map((item) {
                  return DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),
              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(
              //     hintText: 'Organization',
              //     border: OutlineInputBorder(),
              //     contentPadding: EdgeInsets.symmetric(horizontal: 10),
              //   ),
              //   items: const [
              //     DropdownMenuItem(child: Text('Porter'), value: 'Porter'),
              //     DropdownMenuItem(child: Text('Zomato'), value: 'Zomato'),
              //     DropdownMenuItem(child: Text('Swiggy'), value: 'Swiggy'),
              //     // Add more items as needed
              //   ],
              //   onChanged: (value) {
              //     // Handle dropdown value change
              //   },
              // ),
          
              const SizedBox(height: 20),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Select file',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const Row(
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Implement file picker logic
                  _openCamera(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Open camera & take Photo',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              const Align(
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
                    primary: const Color(0xFFFF5252), // Background color
                  ),
                  onPressed: () {
                    // OrganizationProofScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PositionProofScreen(),
                      ),
                    );
                    // verifySignupOTP(
                    //   mobileNumber: mobileNumberController.text,
                    //   otp: otpcontroller.text,
                    //   name: nameController.text,
                    //   gender: gender,
                    //   dateOfBirth: dateOfBirthController.text,
                    // );
                  },
                  child: const Text(
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
