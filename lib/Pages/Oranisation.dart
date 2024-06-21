import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Positionproof.dart';

class OrganizationProofScreen extends StatefulWidget {
  @override
  State<OrganizationProofScreen> createState() => _OrganizationProofScreenState();
}

class _OrganizationProofScreenState extends State<OrganizationProofScreen> {

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'If you belong to any organization,',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'please select and upload the proof',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'for the same.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Organization',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: [
                DropdownMenuItem(child: Text('Porter'), value: 'Porter'),
                DropdownMenuItem(child: Text('Zomato'), value: 'Zomato'),
                DropdownMenuItem(child: Text('Swiggy'), value: 'Swiggy'),
                // Add more items as needed
              ],
              onChanged: (value) {
                // Handle dropdown value change
              },
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
                child: Center(
                  child: Text(
                    'Select file',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PositionProofScreen(
                      ),
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
                child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
