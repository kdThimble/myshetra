import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Services/Authservices.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController handleNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  final authService = Get.find<AuthService>();


  Future<UserProfile?> fetchUserProfile() async {
    var headers = {
      'Authorization': '${authService.token}'
    };
    var url = Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getMyEditableProfile');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse JSON response into UserProfile object
      var jsonResponse = json.decode(response.body);
      return UserProfile.fromJson(jsonResponse['data']);
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  }
  File? _profileImage;
  File? _bannerImage;

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
    await _uploadProfileImage();  // Automatically call upload function
  }

  Future<void> _selectBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
    await _uploadBannerImage();  // Automatically call upload function

  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) {
      // Handle case where no image is selected
      return;
    }

    var headers = {
      'Authorization': '${authService.token}'
    };
    print(authService.token);
    var request = http.MultipartRequest('POST', Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserProfileImage'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('profile_image', _profileImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      // Handle success
    } else {
      print(response.reasonPhrase);
      // Handle failure
    }
  }

  Future<void> _uploadBannerImage() async {
    if (_bannerImage == null) {
      // Handle case where no image is selected
      return;
    }

    var headers = {
      'Authorization': '${authService.token}'
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserBannerImage'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('banner_image', _bannerImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      // Handle success
    } else {
      print(response.reasonPhrase);
      // Handle failure
    }
  }
    String ? profileimage;
  String ? bannerimage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserProfile().then((userProfile) {
      if (userProfile != null) {
        // Set retrieved data to text controllers
        nameController.text = userProfile.name;
        handleNameController.text = userProfile.handleName;
        bioController.text = userProfile.bioInfo;
        localityController.text = userProfile.localDivisionName;
        dobController.text = userProfile.dateOfBirth.toString();
        positionController.text = userProfile.currentPosition;
        organizationController.text = userProfile.userOrganization;
        profileimage = userProfile.profileImageUrl;
        bannerimage = userProfile.bannerImageUrl;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement save logic
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
              GestureDetector(
                onTap: ()=>_selectBannerImage(),
                child: Container(
                  height: 200.0,
                  color: Colors.grey, // Replace with your background image or color
                  child: Center(
                    child: _bannerImage != null
                        ? Image(
                      image: FileImage(_bannerImage!) as ImageProvider<Object>
                    )
                        : Image(
                      image: NetworkImage(bannerimage ?? "https://www.google.com/url?sa=i&url=https%3A%2F%2Ffeaturewallprints.com.au%2Fproduct%2Fupload-photo%2F&psig=AOvVaw1uAGlwR59OLPACApJPPhDJ&ust=1720865000875000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCJjtq-2foYcDFQAAAAAdAAAAABAE"),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
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
          // Profile avatar with camera icon
          Positioned(
            top: 150.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                // Implement logic to pick profile image
              },
              child: Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // Replace with your profile image or placeholder
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Placeholder for profile image
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.white, // Adjust as needed
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) as ImageProvider<Object> : NetworkImage('https://example.com/your-profile-image.jpg'),
                    ),
                    // Camera icon for changing profile image
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: ()=>_selectProfileImage(),
                        child: CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter $label',
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}



class UserProfile {
  final String bannerImageUrl;
  final String profileImageUrl;
  final String handleName;
  final String name;
  final String bioInfo;
  final DateTime dateOfBirth;
  final String userOrganization;
  final String organizationSymbol;
  final String organizationAbbreviation;
  final String currentPosition;
  final String localDivisionName;
  final String regionalDivisionName;
  final String nationalDivisionName;

  UserProfile({
    required this.bannerImageUrl,
    required this.profileImageUrl,
    required this.handleName,
    required this.name,
    required this.bioInfo,
    required this.dateOfBirth,
    required this.userOrganization,
    required this.organizationSymbol,
    required this.organizationAbbreviation,
    required this.currentPosition,
    required this.localDivisionName,
    required this.regionalDivisionName,
    required this.nationalDivisionName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bannerImageUrl: json['banner_image_url'],
      profileImageUrl: json['profile_image_url'],
      handleName: json['handle_name'],
      name: json['name'],
      bioInfo: json['bio_info'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      userOrganization: json['user_organization'],
      organizationSymbol: json['organization_symbol'],
      organizationAbbreviation: json['organization_abbreviation'],
      currentPosition: json['current_position'],
      localDivisionName: json['local_division_name'],
      regionalDivisionName: json['regional_division_name'],
      nationalDivisionName: json['national_division_name'],
    );
  }
}