import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Controller/loadingController.dart';
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class PositionProofScreen extends StatefulWidget {
  final bool ishomescreen;
  const PositionProofScreen({Key? key, this.ishomescreen = false})
      : super(key: key);
  @override
  State<PositionProofScreen> createState() => _PositionProofScreenState();
}

class _PositionProofScreenState extends State<PositionProofScreen> {
  TextEditingController positioncontroller = TextEditingController();
  var selectedFilePath = "";
  final authService = Get.find<AuthService>();

  Future<void> _submitData() async {
    if (positioncontroller.text.isEmpty) {
      // Get.snackbar("Incomplete Form", "Please enter position name", backgroundColor:Colors.red, colorText: Colors.white );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter position name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFilePath == "") {
      // Get.snackbar("Incomplete Form", "Please select a file", backgroundColor:Colors.red, colorText: Colors.white );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      Get.find<LoadingController>().startLoading();
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

      Get.find<LoadingController>().stopLoading();
      if (response.statusCode == 200) {
        // Handle successful response
        widget.ishomescreen
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
      } else if (response.statusCode == 400) {
        // Parse the response data to get the error message
        var jsonResponse = json.decode(responseData);
        String errorMessage = jsonResponse['message'];

        // Show SnackBar with the error message
        // Get.snackbar("", errorMessage, backgroundColor:Colors.red, colorText: Colors.white );
        Fluttertoast.showToast(
            msg: errorMessage,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            gravity: ToastGravity.TOP);

        print('Error: $errorMessage');
      } else {
        // Get.snackbar("", "Some Server Error", backgroundColor:Colors.red, colorText: Colors.white );
        Fluttertoast.showToast(
            msg: "Some Server Error",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            gravity: ToastGravity.TOP);

        // Handle other error responses
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Get.snackbar("Error", "Some Server Error", backgroundColor:Colors.red, colorText: Colors.white );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some Server Error'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $error');
      Get.find<LoadingController>().stopLoading();
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
        Get.snackbar("", "Some  Error Occured",
            backgroundColor: Colors.red, colorText: Colors.white);
        // Handle compression failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some  Error Occured'),
            backgroundColor: Colors.red,
          ),
        );
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
    Get.find<LoadingController>().startLoading();
    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.path, 'compressed_${path.basename(file.path)}');
    int quality = 100;
    XFile? compressedXFile;

    while (quality > 0) {
      compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressedXFile != null &&
          await compressedXFile.length() <= 5 * 1024) {
        break;
      }
      quality -= 5;
    }
    Get.find<LoadingController>().stopLoading();
    return compressedXFile != null ? File(compressedXFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
          "app_header_title".tr,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.006),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'enter_position_title'.tr,
                  style: TextStyle(
                      fontSize: width * 0.07, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: height * 0.009),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'enter_position_sub_title'.tr,
                  style: TextStyle(fontSize: 18, color: greyColor),
                ),
              ),
              SizedBox(height: height * 0.012),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Position name ',
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: height * 0.017),
              Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  controller: positioncontroller,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(left: 5, top: 5, bottom: 5),
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  _openFilePicker(context);
                },
                child: Container(
                  width: double.infinity,
                  height: height * 0.2,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedFilePath == ""
                      ? Center(child: Image.asset("assets/images/Content.png"))
                      : Image.file(
                          File(selectedFilePath),
                          fit: BoxFit.cover,
                        ),
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
                    padding: EdgeInsets.symmetric(vertical: height * 0.03),
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
              !widget.ishomescreen
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        positioncontroller.text.isEmpty &&
                                selectedFilePath == ""
                            ? MyButton1(
                                onTap: () {},
                                text: "choose_location_snackbar_button_text".tr)
                            : MyButton(
                                onTap: _submitData,
                                text:
                                    "choose_location_snackbar_button_text".tr),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white), // Change button color
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color(0xFF0E3D8B)),
                                  borderRadius: BorderRadius.circular(
                                      10), // Make the button rounded
                                ),
                              ),
                              elevation:
                                  MaterialStateProperty.resolveWith<double>(
                                      (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return 10; // Increase elevation when pressed
                                }
                                return 5; // Default elevation
                              }),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(1)), // Add padding
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(double.infinity,
                                      30)), // Set width to full
                              // side: MaterialStateProperty.all<BorderSide>(
                              //     BorderSide(color: Colors.blue)), // Add border
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                "enter_position_skip_button_text".tr,
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
                    )
                  : Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        MyButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PositionProofScreen(),
                                ),
                              );
                            },
                            text: "select_organization_update_button_text".tr),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
