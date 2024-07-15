import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Controller/loadingController.dart';
import 'package:myshetra/Models/OrganisationModel.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:path_provider/path_provider.dart';

import 'Positionproof.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class OrganizationProofScreen extends StatefulWidget {
  @override
  State<OrganizationProofScreen> createState() =>
      _OrganizationProofScreenState();
}

class _OrganizationProofScreenState extends State<OrganizationProofScreen> {
  String? _selectedValue;
  String? id;
  late Future<OrganisationModel> _futureOrganisationModel;
  OrganisationModel? _organisationModel;
  final authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    fetchOrganisationData();
  }

  var selectedFilePath = "";
  var selectedFilePath1 = "";
  Future<void> _submitData() async {
    if (_selectedValue != null && selectedFilePath != "") {
      Get.find<LoadingController>().startLoading();
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserOrganization'), // Replace with your API endpoint
        );
        request.headers['Authorization'] =
            '${authService.token}'; // Replace with your auth token
        request.fields['organization_id'] = organisationid!;

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PositionProofScreen(),
            ),
          );
        } else if (response.statusCode == 400) {
          // Parse the response data to get the error message
          var jsonResponse = json.decode(responseData);
          String errorMessage = jsonResponse['message'];
          Get.snackbar("", errorMessage, backgroundColor:Colors.red, colorText: Colors.white );
          // Show SnackBar with the error message
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(errorMessage),
          //   ),
          // );

          print('Error: $errorMessage');
        } else {
          // Handle other error responses
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
        Get.snackbar("", "Error while uploading data", backgroundColor:Colors.red, colorText: Colors.white );
        Get.find<LoadingController>().stopLoading();
      }
    } else {
      // Handle validation error
      Get.snackbar("Error", "Please select an organization and an image", backgroundColor:Colors.red, colorText: Colors.white );
    }
  }

  Future<OrganisationModel> getPostApi() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getAllOrganization'),
        headers: {
          'Authorization': '${authService.token}',
          'Content-Type': 'application/json',
        },
      );
      print(authService.token);
      if (response.statusCode == 200) {
        return OrganisationModel.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (error) {
      Get.snackbar("Error", "Error while fetching data", backgroundColor:Colors.red, colorText: Colors.white );
      throw Exception('error fetching data');
    }
    Get.snackbar("Error", "Error while fetching data", backgroundColor:Colors.red, colorText: Colors.white );
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
      final compressedImage = await _compressImage(File(image.path));
      if (compressedImage != null) {
        setState(() {
          selectedFilePath = compressedImage.path;
        });
        print(selectedFilePath);
        Get.snackbar("", "Image Captured Successfully", backgroundColor:Colors.green, colorText: Colors.white );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Image captured and compressed successfully'),
        //   ),
        // );
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
      Get.find<LoadingController>().startLoading();
      final filePath = result.files.single.path!;
      final compressedImage = await _compressImage(File(filePath));
      if (compressedImage != null) {
        setState(() {
          selectedFilePath = compressedImage.path;
        });
        print(selectedFilePath);
        Get.snackbar("", "Image Uploaded Successfully", backgroundColor:Colors.green, colorText: Colors.white );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Image selected and compressed successfully'),
        //   ),
        // );
        // Call uploadImage function with the selected image
        // await uploadImage(context, XFile(compressedImage.path));
      } else {
        Get.snackbar("", "Could not upload Image ", backgroundColor:Colors.red, colorText: Colors.white );
        // Handle compression failure
        print("Compression failed");
      }
      Get.find<LoadingController>().stopLoading();
    }
  }

  Future<File?> _compressImage(File file) async {
    Get.find<LoadingController>().startLoading();
    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.path, 'compressed_${path.basename(file.path)}');
    int quality = 100;
    XFile? compressedXFile;

    while (quality > 20) {
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

  var newData;
  String organisationid = '';
  @override
  void dispose() {
    // Reset the state variables
    selectedFilePath = "";
    selectedFilePath1 = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // fetchOrganisationData();
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'select_organization_title'.tr,
                  style: TextStyle(
                      fontSize: width * 0.07, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'select_organization_sub_title'.tr,
                  style: TextStyle(fontSize: 18, color: greyColor),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'select_organization_select_placeholder'.tr,
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),
              _organisationModel == null
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      // margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton(
                        value: _selectedValue,
                        hint: const Text('Select value'),
                        underline: Container(),
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
                            _selectedValue = value?.toString();
                            organisationid = _selectedValue!;
                          });
                        },
                      ),
                    ),
              // DropdownButtonFormField<String>(

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  _openFilePicker(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(10),
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
              const SizedBox(height: 20),

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

              MyButton(
                  onTap: _submitData,
                  text: "choose_location_snackbar_button_text".tr),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PositionProofScreen(),
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
          ),
        ),
      ),
    );
  }
}
