import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}



class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController handleNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController organizationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement skip logic
            },
            child: Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background container for cover photo
          Column(
            children: <Widget>[
              Container(
                height: 200.0,
                color: Colors.grey, // Replace with your background image or color
                child: Center(
                  child: Text('Background image goes here'),
                ),
              ),
              SizedBox(height: 50,),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileField('Name', nameController),
                        _buildProfileField('Handle Name', handleNameController),
                        _buildProfileField('Bio', bioController),
                        _buildProfileField('Locality', localityController),
                        _buildProfileField('Date of Birth', dobController),
                        _buildProfileField('Position', positionController),
                        _buildProfileField('Organization', organizationController),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Profile image partially inside the background container
          Positioned(
            top: 150.0, // Adjust this value as needed
            left: 20.0, // Adjust this value as needed
            child: Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Replace with your profile image or placeholder
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $label',
                  // Optional: Add underline border directly to the input
                  // enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}


