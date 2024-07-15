import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/HomePage.dart';

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
    var headers = {'Authorization': '${authService.token}'};
    var url = Uri.parse(
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getMyEditableProfile');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse JSON response into UserProfile object
      var jsonResponse = json.decode(response.body);
      print("object $jsonResponse");
      Get.snackbar("Hurrah", "Profile fetched successfully");
      return UserProfile.fromJson(jsonResponse['data']);
    } else {
      Get.snackbar('', 'Failed to fetch user profile', backgroundColor:Colors.red, colorText: Colors.white );
      print(
          'Request failed with status: ${json.decode(response.body)['message']}');
      print("REfresg token ${authService.refreshToken} ");
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
    await _uploadProfileImage(); // Automatically call upload function
  }

  Future<void> _selectBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
    await _uploadBannerImage(); // Automatically call upload function
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) {
      // Handle case where no image is selected
      return;
    }

    var headers = {'Authorization': '${authService.token}'};
    print(authService.token);
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserProfileImage'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(
        'profile_image', _profileImage!.path));

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

    var headers = {'Authorization': '${authService.token}'};
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateUserBannerImage'));
    request.headers.addAll(headers);
    request.files.add(
        await http.MultipartFile.fromPath('banner_image', _bannerImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      // Handle success
    } else {
      print(response.reasonPhrase);
      // Handle failure
    }
  }

  String? profileimage;
  String? bannerimage;
  void SetUserProfile() async {
    // Set retrieved data to text controllers
    UserProfile user = await fetchUserProfile() as UserProfile;
    print(user);
    nameController.text = user.name ?? "";
    handleNameController.text = user.handleName ?? "";
    bioController.text = user.bioInfo ?? "";
    localityController.text = user.localDivisionName ?? "";
    dobController.text = user.dateOfBirth.toString() ?? "";
    positionController.text = user.currentPosition ?? "";
    organizationController.text = user.userOrganization ?? "";
    profileimage = user.profileImageUrl ?? "";
    bannerimage = user.bannerImageUrl ?? "";
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    SetUserProfile();
    // fetchUserProfile().then((userProfile) {
    //   print("userProfile: $userProfile");
    //   if (userProfile != null) {
    //     // Set retrieved data to text controllers
    //     nameController.text = userProfile.name;
    //     handleNameController.text = userProfile.handleName;
    //     bioController.text = userProfile.bioInfo;
    //     localityController.text = userProfile.localDivisionName;
    //     dobController.text = userProfile.dateOfBirth.toString();
    //     positionController.text = userProfile.currentPosition;
    //     organizationController.text = userProfile.userOrganization;
    //     profileimage = userProfile.profileImageUrl;
    //     bannerimage = userProfile.bannerImageUrl;
    //   }
    // });

    print("profileimage: $profileimage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              // Implement save logic
              Get.to(HomePage());
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
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
                height: 280.0,
                color:
                    Colors.grey, // Replace with your background image or color
                child: Stack(
                  children: [
                    Center(
                      child: _bannerImage != null
                          ? Image(
                              image: FileImage(_bannerImage!)
                                  as ImageProvider<Object>)
                          : Image(
                              image: NetworkImage(
                                  "https://static.vecteezy.com/system/resources/previews/002/909/206/original/abstract-background-for-landing-pages-banner-placeholder-cover-book-and-print-geometric-pettern-on-screen-gradient-colors-design-vector.jpg"),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          _selectBannerImage();
                          print("Camera icon pressed");
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileField(
                            'edit_profile_name_ttitle'.tr, nameController),
                        _buildProfileField('edit_profile_header_name_ttitle'.tr,
                            handleNameController),
                        _buildProfileField('Bio', bioController),
                        _buildProfileField('Locality', localityController),
                        _buildProfileField(
                            'edit_profile_dob_title'.tr, dobController),
                        _buildProfileField('edit_profile_position_title'.tr,
                            positionController),
                        _buildProfileField('edit_profile_organization_title'.tr,
                            organizationController),
                        MyButton(
                            onTap: () {
                              // Implement save logic
                              Get.to(HomePage());
                            },
                            text: "Save"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Profile avatar with camera icon
          Positioned(
            top: 220.0,
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
                  color: Colors
                      .black, // Replace with your profile image or placeholder
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Placeholder for profile image
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.white, // Adjust as needed
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider<Object>
                          : NetworkImage(
                              'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph'),
                    ),
                    // Camera icon for changing profile image
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _selectProfileImage(),
                        child: CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt_outlined,
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
  final String? bannerImageUrl;
  final String? profileImageUrl;
  final String? handleName;
  final String? name;
  final String? bioInfo;
  final DateTime? dateOfBirth;
  final String? userOrganization;
  final String? organizationSymbol;
  final String? organizationAbbreviation;
  final String? currentPosition;
  final String? localDivisionName;
  final String? regionalDivisionName;
  final String? nationalDivisionName;

  UserProfile({
    this.bannerImageUrl,
    this.profileImageUrl,
    this.handleName,
    this.name,
    this.bioInfo,
    this.dateOfBirth,
    this.userOrganization,
    this.organizationSymbol,
    this.organizationAbbreviation,
    this.currentPosition,
    this.localDivisionName,
    this.regionalDivisionName,
    this.nationalDivisionName,
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
