import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/AuthPage.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Services/Authservices.dart';
import '../helpers/colors.dart';
import 'Oranisation.dart';
import 'Positionproof.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

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

  Future<void> refreshAuthToken() async {
    print("swxaL:${authService.refreshToken}");
    print("tokem:${authService.token}");
    setState(() {
      isloading = true;
    });
    var headers = {
      'Refresh-Token':
          '${authService.refreshToken}', // Authorization header with the token
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/refreshToken'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var jsonData = json.decode(responseBody);
    print("Response code: $jsonData");

    // Get.find<LoadingController>().stopLoading();

    if (response.statusCode == 200) {
      // final authResponse = AuthResponse.fromJson(jsonData['data']);
      final token = jsonData['data']['token'];
      print(responseBody);
      if (token != null) {
        // Save the tokens to secure storage or a state management solution
        // Provider.of<AuthProvider>(context, listen: false)
        //     .setAuthResponse(authResponse);
        Get.find<AuthService>().saveToken(token);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        print("authResponse.token:$token");
        await prefs.setString('token', token);
        SetUserProfile();
      } else {
        // Get.snackbar('Error', 'Failed to authenticate');
        print('Failed to authenticate');
        SetUserProfile();
      }
    } else if (response.statusCode == 500) {
      Fluttertoast.showToast(
          msg: "Session expired, please login again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.find<AuthService>().clearAuthResponse();
      Get.to(const AuthPage());
    } else {
      print('Failed to refresh token: ${response.reasonPhrase}');
      SetUserProfile();
      // Handle the error
    }
  }

  Future<UserProfile?> fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('issignupcompleted', 'false');
    var headers = {'Authorization': '${authService.token}'};
    var url = Uri.parse(
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getMyEditableProfile');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse JSON response into UserProfile object
      var jsonResponse = json.decode(response.body);
      print("object $jsonResponse");
      // Get.snackbar("Hurrah", "Profile fetched successfully");
      Fluttertoast.showToast(
          msg: "Profile fetched successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      //  ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Profile fetched successfully'),
      //         backgroundColor: Colors.green,
      //       ),
      //     );
      return UserProfile.fromJson(jsonResponse['data']);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to fetch user profile",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to fetch user profile'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      // Get.snackbar('', 'Failed to fetch user profile',
      //     backgroundColor: Colors.red, colorText: Colors.white);
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
      Fluttertoast.showToast(
          msg: "Profile Picture Updated",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
      // Handle success
    } else {
      print(response.reasonPhrase);
      Fluttertoast.showToast(
          msg: "Could nor update Profile Picture",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
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
      Fluttertoast.showToast(
          msg: "Banner Picture Updated",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
      // Handle success
    } else {
      print(response.reasonPhrase);
      Fluttertoast.showToast(
          msg: "Could nor update Banner Picture",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
      // Handle failure
    }
  }

  String? profileimage;
  String? bannerimage;
  String profileimage1 = '';
  String bannerimage1 = '';
  bool isloading = false;
  String formatDateString(String dateStr) {
    // Parse the date string to DateTime
    DateTime parsedDate = DateTime.parse(dateStr);
    // Format the DateTime to the desired format
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    return formattedDate;
  }

  void SetUserProfile() async {
    // Set retrieved data to text controllers

    UserProfile user = await fetchUserProfile() as UserProfile;
    print(user);
    print("image:${user.profileImageUrl}");
    setState(() {
      nameController.text = user.name ?? "";
      handleNameController.text = user.handleName ?? "";
      bioController.text = user.bioInfo ?? "";
      // localityController.text = user.localDivisionName ?? "";
      dobController.text = user.dateOfBirth != null
          ? formatDateString(user.dateOfBirth.toString())
          : "";
      positionController.text = user.currentPosition ?? "";
      organizationController.text = user.userOrganization ?? "";
      profileimage1 = user.profileImageUrl ?? "";
      bannerimage1 = user.bannerImageUrl ?? "";
    });
    print("profileunage:$profileimage1");
    setState(() {
      isloading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshAuthToken();

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

  Future<void> updateProfile(String handlename, name, bio, dob) async {
    var headers = {'Authorization': '${authService.token}'};
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/updateMyProfile'));
    request.fields.addAll({
      'handle_name': handlename,
      'name': name,
      'bio_info': bio,
      'date_of_birth': dob
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      var responseJson = json.decode(responseString);
      Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.to(const HomePage());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (dobController.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd').parse(dobController.text);
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate;
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Text(
                'create_account_dob_modal_text'
                    .tr, // You may need to add .tr if using GetX for translations
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: DatePickerWidget(
                  initialDate: initialDate, // Set the initial date
                  locale: DateTimePickerLocale.en_us,
                  pickerTheme: DateTimePickerTheme(
                    backgroundColor: Colors.white.withOpacity(0.0),
                    showTitle: false,
                    itemTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    cancelTextStyle: const TextStyle(color: Colors.black),
                    confirmTextStyle: const TextStyle(color: Colors.black),
                    itemHeight: 40,
                  ),
                  dateFormat: 'dd-MMMM-yyyy',
                  onChange: (date, _) {
                    selectedDate = date;
                  },
                  onConfirm: (date, _) {
                    if (date.year < 1940 || date.year > 2006) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Birthdate must be between 1940 and 2006.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      setState(() {
                        dobController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF0E3D8B)), // Change button color
                    elevation:
                        MaterialStateProperty.resolveWith<double>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return 10; // Increase elevation when pressed
                      }
                      return 5; // Default elevation
                    }),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0)), // Add padding
                    minimumSize: MaterialStateProperty.all<Size>(
                        const Size(100, 40)), // Set width to full
                  ),
                  onPressed: () {
                    if (selectedDate.year < 1940 || selectedDate.year > 2006) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Birthdate must be between 1940 and 2006.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      setState(() {
                        dobController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'edit_profile_header_title'.tr,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isloading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        height: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => const SizedBox(
                            height: 16,
                            child: SizedBox.expand(
                                child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: Colors.grey)))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 220, 231, 240),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: primaryColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20),
                        child: Row(
                          children: [
                            // Icon(Icons.add, color: primaryColor, weight: 26),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        height: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => const SizedBox(
                            height: 16,
                            child: SizedBox.expand(
                                child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: Colors.grey)))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 220, 231, 240),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: primaryColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20),
                        child: Row(
                          children: [
                            // Icon(Icons.add, color: primaryColor, weight: 26),
                            const SizedBox(width: 8),
                            Container(
                              width: 150,
                              height: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        height: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => const SizedBox(
                            height: 16,
                            child: SizedBox.expand(
                                child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: Colors.grey)))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Background container for cover photo
                Column(
                  children: <Widget>[
                    Container(
                      height: 280.0,
                      color: Colors
                          .grey, // Replace with your background image or color
                      child: Stack(
                        children: [
                          Center(
                            child: _bannerImage != null
                                ? Image(image: FileImage(_bannerImage!))
                                : bannerimage1 !=
                                        "https://dev-my-shetra.blr1.cdn.digitaloceanspaces.com/admin_files/FallBackBannerImage.png"
                                    ? Image.network(
                                        bannerimage1,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.network(
                                        "https://static.vecteezy.com/system/resources/previews/002/909/206/original/abstract-background-for-landing-pages-banner-placeholder-cover-book-and-print-geometric-pettern-on-screen-gradient-colors-design-vector.jpg",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(
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
                    const SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileField('edit_profile_name_ttitle'.tr,
                                  nameController),
                              _buildProfileField(
                                  'edit_profile_header_name_ttitle'.tr,
                                  handleNameController),
                              _buildProfileField(
                                  'edit_profile_name_bio'.tr, bioController),
                              // _buildProfileField('Locality', localityController),
                              _buildProfileFieldWithSuffix(
                                  'edit_profile_dob_title'.tr, dobController,
                                  () {
                                // Add your change text functionality for DOB here
                                _selectDate(context);
                                print("Change");
                              }),
                              _buildProfileFieldWithSuffix(
                                  'edit_profile_position_title'.tr,
                                  positionController, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PositionProofScreen(
                                      ishomescreen: true,
                                    ),
                                  ),
                                );
                                // Add your change text functionality for Position here
                                print("Change");
                              }),
                              _buildProfileFieldWithSuffix(
                                  'edit_profile_organization_title'.tr,
                                  organizationController, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrganizationProofScreen(
                                            ishomescreen: true),
                                  ),
                                );
                                // Add your change text functionality for Organization here
                                print("Change");
                              }),
                              MyButton(
                                  onTap: () {
                                    // Implement save logic
                                    updateProfile(
                                        handleNameController.text,
                                        nameController.text,
                                        bioController.text,
                                        dobController.text);
                                  },
                                  text: "select_save_button_text".tr),
                              const SizedBox(height: 20),
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
                      decoration: const BoxDecoration(
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
                                ? FileImage(_profileImage!)
                                    as ImageProvider<Object>
                                : profileimage1 !=
                                        "https://dev-my-shetra.blr1.cdn.digitaloceanspaces.com/admin_files/FallBackProfileImage.jpeg"
                                    ? NetworkImage(profileimage1)
                                    : const NetworkImage(
                                        'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph'),
                          ),
                          // Camera icon for changing profile image
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _selectProfileImage(),
                              child: const CircleAvatar(
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
        // Text(
        //   '$label: ',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProfileField1(String label, TextEditingController controller,
      {Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   '$label: ',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: label,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 20),
            suffixIcon: suffix,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProfileFieldWithSuffix(
      String label, TextEditingController controller, VoidCallback onPressed) {
    return _buildProfileField1(
      label,
      controller,
      suffix: TextButton(
        onPressed: onPressed,
        child: Text('select_change_button_text'.tr),
      ),
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
