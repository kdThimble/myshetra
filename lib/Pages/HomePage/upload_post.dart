import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Controller/user_selector_controller.dart';
import 'package:myshetra/Models/UserModel.dart';
import 'package:myshetra/Pages/HomePage/HomePage.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/Services/user_shared_pref.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_mentions/flutter_mentions.dart';

import '../SearchPage/Tagscreen.dart';

class SelectedImagesScreen extends StatefulWidget {
  final Set<AssetEntity> images;
  String caption;

  SelectedImagesScreen({required this.images, required this.caption, Key? key})
      : super(key: key);

  @override
  _SelectedImagesScreenState createState() => _SelectedImagesScreenState();
}

class _SelectedImagesScreenState extends State<SelectedImagesScreen> {
  Set<AssetEntity> selectedImages = {};
  List<File> selectedFiles = []; // Store picked files here
  final List<VideoPlayerController> _videoControllers = [];
  UserProfile? profile;
  List<String> issueNames = [];
  List<Map<String, dynamic>> representatives = [];
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    selectedImages = widget.images;
    captionController.text = widget.caption;
    _loadUserProfile();
    fetchIssueData();
  }

  Future<Map<String, dynamic>> fetchIssueStatus() async {
    var headers = {
      'Authorization': authService.token.value,
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/post/getIssueStatus'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      return json.decode(responseString);
    } else {
      throw Exception('Failed to load issue status');
    }
  }

  Future<void> fetchIssueData() async {
    try {
      final data = await fetchIssueStatus();
      setState(() {
        // Extract issue names without indices
        issueNames = (data['data']['issues'] as List<dynamic>)
            .map((issue) => issue['name'] as String)
            .toSet()
            .toList(); // Convert to Set first to remove any duplicates
        print("issuenames");
        print(issueNames);

        // Set the initial dropdown value to the first unique item
        dropdownValue = issueNames.isNotEmpty ? issueNames[0] : null;

        // Extract representatives
        representatives = (data['data']['representatives'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (e) {
      print('Error fetching issue status: $e');
    }
  }

  File? _profileImage;

  Future<void> _loadUserProfile() async {
    UserProfilePreference prefs = UserProfilePreference();
    UserProfile? loadedProfile = await prefs.loadUserProfile();
    setState(() {
      profile = loadedProfile;
    });
  }

  // Function to initialize video controllers
  void _initializeVideoController(File videoFile) {
    final controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {}); // Refresh UI after initializing
      });
    _videoControllers.add(controller);
  }

  void _unselectImage(AssetEntity image) {
    setState(() {
      selectedImages.remove(image);
    });
  }

  void _unselectFile(File file) {
    setState(() {
      selectedFiles.remove(file);
    });
  }

  final authService = Get.find<AuthService>();
  var Response;
  Future<List<File>> _convertToFiles(List<AssetEntity> assets) async {
    List<File> files = [];
    for (var asset in assets) {
      File? file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }
    return files;
  }

  void printMentions() async {
    final searchScreenController = Get.find<SelectionController>();

    // Get user mentions and hashtags from the controller
    List<Map<String, dynamic>> userMentions =
        searchScreenController.selectedUsers.map((user) {
      return {
        'token': '@${user["user_name"]}',
        'user_id': user["user_id"],
      };
    }).toList();

    List<String> hashtags =
        searchScreenController.selectedHashtags.map((hashtag) {
      return '${hashtag['hashtag_name']}';
    }).toList();
    print("User ${userMentions[0].toString()}");
    print("Hashtag ${hashtags[0]}");
  }

  final searchScreenController = Get.put(SelectionController());

  Future<void> _uploadSelectedFiles() async {
    // Convert selected AssetEntity images to File objects
    List<File> convertedFiles = await _convertToFiles(selectedImages.toList());

    // Combine converted AssetEntity files with selectedFiles (picked from ImagePicker)
    List<File> allFilesToUpload = [...convertedFiles, ...selectedFiles];

    // Call _uploadFiles with the combined list of files
    await _uploadFiles(allFilesToUpload);
  }

  String _generateChecksum(File file) {
    var bytes = file.readAsBytesSync();
    var checksum = md5.convert(bytes);
    return checksum.toString();
  }

  String postId = '';
  String _replaceMentionsInContent(
      String content, List<Map<String, dynamic>> userMentions) {
    // Use a regular expression to find all occurrences of @ followed by words or spaces
    final mentionRegex = RegExp(r'@(\w+[\w\s]*)', caseSensitive: false);

    // Store all the matches of mentions
    final matches = mentionRegex.allMatches(content);

    // List to store the replacements
    final replacements = <String, String>{};

    // Replace each mention with the corresponding user token
    for (int i = 0; i < matches.length; i++) {
      final match = matches.elementAt(i);
      final mention = match.group(0);

      if (mention != null) {
        // Get the user mention token (e.g., @user1) or use a placeholder if not enough users are provided
        final userIndex = i < userMentions.length ? i : userMentions.length - 1;
        final userToken =
            '@user${userIndex + 1}'; // Generate user token as @user1, @user2, etc.

        // Map mention to user token
        replacements[mention] = userToken;
      }
    }

    // Replace all mentions in content with the corresponding user tokens
    var updatedContent = content;
    replacements.forEach((mention, userToken) {
      updatedContent = updatedContent.replaceAll(mention, userToken);
    });

    return updatedContent;
  }

  Future<List<dynamic>> _getPreSignedUrls(
      List<File> files, String content) async {
    print("token: ${authService.token.value}");

    var headers = {
      'Authorization': authService.token.value, // Ensure "Bearer" prefix
      'Content-Type': 'application/json',
    };

    var fields = <String, String>{};
    final searchScreenController = Get.find<SelectionController>();

    // Get user mentions and hashtags from the controller
    List<Map<String, dynamic>> userMentions =
        searchScreenController.selectedUsers.map((user) {
      return {
        'token': '@${user["user_name"]}',
        'user_id': user["user_id"],
      };
    }).toList();

    List<String> hashtags =
        searchScreenController.selectedHashtags.map((hashtag) {
      return '${hashtag['hashtag_name']}';
    }).toList();
    final updatedContent = _replaceMentionsInContent(content, userMentions);

    // Add files information
    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      fields['files[$i][fileName]'] = file.path.split('/').last;
      fields['files[$i][size]'] = file.lengthSync().toString();
      fields['files[$i][mimeType]'] = lookupMimeType(file.path) ?? '';
      fields['files[$i][contentType]'] = lookupMimeType(file.path) ?? '';
      fields['files[$i][checksum]'] =
          _generateChecksum(file); // Assuming this function exists
      fields['files[$i][orderID]'] = i.toString();
    }

    // Add content
    fields['content'] = updatedContent;

    // Add user mentions to the form data
    for (int i = 0; i < userMentions.length; i++) {
      String formattedToken = '{user${i + 1}}';

      fields['user_mentions[$i][token]'] = formattedToken;
      fields['user_mentions[$i][user_id]'] = userMentions[i]['user_id']!;
    }

    // Add hashtags to the form data
    for (int i = 0; i < hashtags.length; i++) {
      fields['hashtags[$i]'] = hashtags[i];
    }

    // Create the request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getPreSignedUrlsFromFileMetaData'),
    );

    request.fields.addAll(fields);
    print("body of presigned");
    print(fields);
    request.headers.addAll(headers);

    // Send the request
    var response = await request.send();

    // Check the response status
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      print("Response: $decodedResponse");
      setState(() {
        Response = decodedResponse['data']['response'];
        postId = Response['post_id'];
      });
      return decodedResponse['data']['response']['files'];
    } else {
      // Handle error response
      var responseBody = await response.stream.bytesToString();
      var errorResponse = jsonDecode(responseBody);
      print("Error: ${errorResponse['message']}");
      // Optionally, show a dialog or message with the error
      // _showErrorDialog(errorResponse['message']);
      return [];
    }
  }

  Future<void> _uploadFiles(List<File> files) async {
    var preSignedUrls = await _getPreSignedUrls(files, captionController.text);
    print(Response);
    if (preSignedUrls.isEmpty) {
      print('No pre-signed URLs received. Aborting upload.');
      return;
    }

    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      var url = preSignedUrls[i]['signed_url'];
      var mimeType = lookupMimeType(file.path) ?? '';
      var contentType = lookupMimeType(file.path) ?? '';
      var fileSize = file.lengthSync();

      await _uploadFileToPreSignedUrl(
          url, file, mimeType, contentType, fileSize);
    }
    // await _callWebSocketBeforeConfirming();
    await confirmPostFilesUploads(Response, captionController.text);
  }

  Future<void> _callWebSocketBeforeConfirming() async {
    var headers = {'Authorization': authService.token.value};

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/pubsub/subscribeChannel?channel=post_creation&post_id=$postId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      print('WebSocket call passed: $responseBody');
      print(responseBody);
    } else {
      print('WebSocket call failed: ${response.reasonPhrase}');
    }
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedFiles.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  void _pickVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        selectedFiles.add(File(video.path));
        _initializeVideoController(File(video.path));
      });
    }
  }

  Future<void> _uploadFileToPreSignedUrl(String url, File file, String mimeType,
      String contentType, int fileSize) async {
    var headers = {
      'Content-Type': mimeType,
      'x-amz-meta-contenttype': contentType,
      'x-amz-meta-filesize': fileSize.toString(),
    };

    var request = http.Request('PUT', Uri.parse(url));
    request.bodyBytes = file.readAsBytesSync();
    request.headers.addAll(headers);

    var response = await request.send();

    // Convert StreamedResponse to a full Response
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('Failed to upload file: ${response.reasonPhrase}');
    }

    print('Response Status: ${response.statusCode}');
    print('Response Reason: ${response.reasonPhrase}');
    print('Response Body: $responseBody');
  }

  Future<void> confirmPostFilesUploads(
      Map<String, dynamic> responseData, String content) async {
    // Extract data from the response
    String postId = responseData['post_id'];
    List<Map<String, dynamic>> files =
        List<Map<String, dynamic>>.from(responseData['files']);

    // Define headers
    var headers = {
      'Authorization': authService.token.value, // Ensure "Bearer" prefix
      'Content-Type': 'multipart/form-data',
    };

    // Create the request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/confirmPostFilesUploads'),
    );

    // Add fields to the request
    request.fields['post_id'] = postId;
    request.fields['content'] = captionController.text;

    List<String> hashtags =
        searchScreenController.selectedHashtags.map((hashtag) {
      return '${hashtag['hashtag_name']}';
    }).toList();

    List<Map<String, dynamic>> userMentions =
        searchScreenController.selectedUsers.map((user) {
      return {
        'token': '@${user["user_name"]}',
        'user_id': user["user_id"],
      };
    }).toList();

    final updatedContent = _replaceMentionsInContent(content, userMentions);

    // Add files information
    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      request.fields['files[$i][file_id]'] = files[i]['file_id'];
      request.fields['files[$i][unique_name]'] = files[i]['unique_name'];
      request.fields['files[$i][checksum]'] = files[i]['metadata']['checksum'];
      request.fields['files[$i][order_id]'] =
          files[i]['metadata']['order_id'].toString();
    }

    // Add content
    request.fields['content'] = updatedContent;

    // Add user mentions to the form data
    for (int i = 0; i < userMentions.length; i++) {
      String formattedToken = '{user${i + 1}}';

      request.fields['user_mentions[$i][token]'] = formattedToken;
      request.fields['user_mentions[$i][user_id]'] =
          userMentions[i]['user_id']!;
    }

    // Add hashtags to the form data
    for (int i = 0; i < hashtags.length; i++) {
      request.fields['hashtags[$i]'] = hashtags[i];
    }
    // Add files to the request dynamically

    // Add headers to the request
    request.headers.addAll(headers);
    // request.fields.addAll(fields);
    print('Request Fields: ${request.fields}');
    print('Request Headers: ${request.headers}');
    // Send the request
    http.StreamedResponse response = await request.send();
    print(request);
    // Handle the response
    if (response.statusCode == 200) {
      print('Success: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Files uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Get.to(const HomePage());
      print(await response.stream.bytesToString());
    } else {
      print('Error: ${response.statusCode}');
      print('Response Reason: ${response.reasonPhrase}');
      var responseBody = await response.stream.bytesToString();
      var errorResponse = jsonDecode(responseBody);
      print("Error: ${errorResponse['message']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.reasonPhrase}')),
      );
      // String responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');
    }
  }

  bool _isMentioning = false;
  List<dynamic> _results = [];
  String _searchQuery = '';
  void onChng(String text) {
    print("In on change");
  }

  void _onChanged(String text) {
    final atIndex = text.lastIndexOf('@');
    print("in on changed");
    if (atIndex != -1) {
      setState(() {
        _isMentioning = true;
        _searchQuery = text.substring(atIndex + 1);
      });
      _search(_searchQuery);
    } else {
      setState(() {
        _isMentioning = false;
        _results = [];
      });
    }
  }

  void _search(String text) async {
    if (text.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _results = [];
    });
    print("In search");

    var headers = {
      'Authorization': authService.token.value,
    };
    var uri =
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/searchUsersForUserMention?search_query=$text';

    var request = http.Request('POST', Uri.parse(uri));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        setState(() {
          _results = jsonResponse['data']['users'];
        });

        print("userr :${_results[0]}");
      } else {}
    } catch (e) {
      setState(() {
        _results = [];
      });
    }
  }

  void _onSuggestionTap(dynamic user) {
    searchScreenController.addUser(user);
    setState(() {});
    final atIndex = captionController.text.lastIndexOf('@');
    if (atIndex != -1) {
      final newText =
          captionController.text.substring(0, atIndex + 1) + user['user_name'];
      captionController.text = newText;
      captionController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }

    setState(() {
      _isMentioning = false;
      _results = [];
    });
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController captionController = TextEditingController();

  var width, height;
  List<dynamic> _selectedUsers = [];
  List<dynamic> _selectedHashtags = [];
  // Method to build the combined text
  String _buildCombinedText() {
    final captionText = captionController.text;

    // Join selected users and hashtags
    final selectedUsersText = _selectedUsers
        .map((user) => '@${user['user_name']}')
        .join(' '); // Add a space after each user

    final selectedHashtagsText = _selectedHashtags
        .map((hashtag) => '${hashtag['hashtag_name']}')
        .join(' '); // Add a space after each hashtag
    print("hashtag n users");
    print(selectedUsersText);
    print(selectedHashtagsText);
    // Combine the caption with selected users and hashtags
    return '$captionText $selectedUsersText $selectedHashtagsText';
  }

  @override
  Widget build(BuildContext context) {
    List<AssetEntity> imagesList = selectedImages.toList();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the default back button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
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
              Text(
                "Create Post",
                style: TextStyle(
                  color: Colors.black, // Replace with your primaryColor
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
              SizedBox(width: width * 0.1), // Add spacing to balance the title
            ],
          ),
        ),
        body: Column(
          children: [
            // SizedBox(height: height * 0.01),
            if (profile != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: width * 0.1,
                      backgroundColor: Colors.white, // Adjust as needed
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider<Object>
                          : profile?.profileImageUrl !=
                                  "https://dev-my-shetra.blr1.cdn.digitaloceanspaces.com/admin_files/FallBackProfileImage.jpeg"
                              ? NetworkImage(profile?.profileImageUrl ??
                                  "https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph")
                              : const NetworkImage(
                                  'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph'),
                    ),
                    SizedBox(width: width * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name?.capitalize ?? "User",
                          style: TextStyle(
                            fontSize: height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          profile?.bioInfo != "" ? profile!.bioInfo! : "No bio",
                          style: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: captionController,
                maxLength: 256,
                onChanged: (value) =>
                    _onChanged(value), // Ensure this is properly connected
                decoration: const InputDecoration(
                  labelText: 'Write a Caption...',
                  hintText: 'Write a Caption...',
                  contentPadding: EdgeInsets.all(8.0),
                  border: InputBorder.none,
                  counterText: '', // Hide counter
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 10.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_buildCombinedText().length}/256",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            if (_isMentioning)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ListTile(
                      title: Text(result['user_name']),
                      subtitle: Text('@${result['handle_name']}'),
                      onTap: () => _onSuggestionTap(result),
                    );
                  },
                ),
              ),

            // Display selected users and hashtags

            // Display selected users and hashtags
            // if (_selectedUsers.isNotEmpty || _selectedHashtags.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 10.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Wrap(
            //           spacing: 8.0,
            //           children: [
            //             if (_selectedUsers.isNotEmpty)
            //               ..._selectedUsers.map((user) => Chip(
            //                 label: Text('@${user['user_name']}'),
            //               )),
            //             if (_selectedHashtags.isNotEmpty)
            //               ..._selectedHashtags.map((hashtag) => Chip(
            //                 label: Text('${hashtag['hashtag_name']}'),
            //               )),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns in grid view
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: imagesList.length + selectedFiles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == imagesList.length + selectedFiles.length) {
                      // Last container for adding a new image
                      return GestureDetector(
                        onTap: _pickImages, // Open image picker when tapped
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            Icons.add,
                            color: primaryColor,
                            size: height * 0.04,
                          ),
                        ),
                      );
                    } else if (index < imagesList.length) {
                      // Display images from AssetEntity
                      return Stack(
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: imagesList[index].thumbnailData,
                            builder: (context, snapshot) {
                              final bytes = snapshot.data;
                              if (bytes == null) {
                                return Container(color: Colors.grey[300]);
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  width: width * 0.28,
                                  height: height * 0.16,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                _unselectImage(imagesList[index]);
                              },
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Display images from File
                      final fileIndex = index - imagesList.length;
                      final file = selectedFiles[fileIndex];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              width: width * 0.28,
                              height: height * 0.16,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                _unselectFile(file);
                              },
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: height * 0.45, // Adjust the height as needed (40-50%)
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      tabs: [
                        Tab(text: "Post"),
                        Tab(text: "Issues"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // First tab content
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.person_add_alt_1,
                                            color: Colors
                                                .blue, // replace with your primaryColor
                                          ),
                                          title: const Text("Tag people"),
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SearchScreen(),
                                              ),
                                            );

                                            if (result != null) {
                                              setState(() {
                                                _selectedUsers =
                                                    result['selectedUsers'] ??
                                                        [];
                                                _selectedHashtags = result[
                                                        'selectedHashtags'] ??
                                                    [];
                                                // Update the TextField with combined text
                                                captionController.text =
                                                    _buildCombinedText();
                                                // Move the cursor to the end of the text
                                                captionController.selection =
                                                    TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: captionController
                                                          .text.length),
                                                );
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      // Display selected users and hashtags
                                      if (_selectedUsers.isNotEmpty ||
                                          _selectedHashtags.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (_selectedUsers
                                                  .isNotEmpty) ...[
                                                // const Text(
                                                //   'Selected Users:',
                                                //   style: TextStyle(fontWeight: FontWeight.bold),
                                                // ),
                                                Wrap(
                                                  spacing: 8.0,
                                                  children: _selectedUsers
                                                      .map((user) => Chip(
                                                            label: Text(user[
                                                                'user_name']),
                                                            backgroundColor:
                                                                Colors.lightBlue
                                                                    .shade100,
                                                          ))
                                                      .toList(),
                                                ),
                                              ],
                                              if (_selectedHashtags
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 10),
                                                // const Text(
                                                //   'Selected Hashtags:',
                                                //   style: TextStyle(fontWeight: FontWeight.bold),
                                                // ),
                                                Wrap(
                                                  spacing: 8.0,
                                                  children: _selectedHashtags
                                                      .map((hashtag) => Chip(
                                                            label: Text(
                                                                '${hashtag['hashtag_name']}'),
                                                            backgroundColor:
                                                                Colors
                                                                    .lightGreen
                                                                    .shade100,
                                                          ))
                                                      .toList(),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MyButton(
                                    onTap: _uploadSelectedFiles,
                                    text: "Share",
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    "*Post will be visible in your ward only*",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Second tab content
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Complaints",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                issueNames.isNotEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButton<String>(
                                          value: dropdownValue,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          isExpanded: true,
                                          onChanged: issueNames.isEmpty
                                              ? null
                                              : (String? newValue) {
                                                  setState(() {
                                                    dropdownValue = newValue!;
                                                  });
                                                },
                                          items: issueNames
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(value),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 80,
                                        child: Center(
                                            child: Text(
                                          "No issues Found in your Area",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ))),

                                const SizedBox(height: 20),
                                representatives.isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                          itemCount: representatives.length,
                                          itemBuilder: (context, index) {
                                            final representative =
                                                representatives[index];
                                            return _buildRepresentativeTile(
                                                representative);
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: MyButton(
                                    onTap: _uploadSelectedFiles,
                                    text: "Share",
                                  ),
                                ),
                                // const Center(
                                //   child: Text(
                                //     "*Post will be visible in your ward only*",
                                //     style: TextStyle(
                                //         fontWeight: FontWeight.bold, fontSize: 17),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRepresentativeTile(Map<String, dynamic> representative) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(representative['org_symbol_url']),
        ),
        title: Text(representative['name']),
        subtitle: Text(representative['user_role_label']),
        trailing: Text(representative['org_abbreviation_name']),
      ),
    );
  }

  Widget _buildPostTab() {
    return Column(
      children: [
        // Tag People Container
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {}
            // _tagPeople
            ,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: primaryColor),
                  const SizedBox(width: 10),
                  Text("Tag People", style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
          ),
        ),
        // Post Creation UI
      ],
    );
  }

  Widget _buildIssuesTab() {
    return Column(
      children: [
        // Dropdown for selecting issue
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: DropdownButton<String>(
            hint: const Text("Select an issue"),
            items: ["Issue 1", "Issue 2", "Issue 3"]
                .map((issue) => DropdownMenuItem(
                      value: issue,
                      child: Text(issue),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                // Handle dropdown change
              });
            },
          ),
        ),
        // List of Containers based on the selected issue
        Expanded(
          child: ListView(
            children: const [
              ListTile(
                title: Text("Issue Detail 1"),
                subtitle: Text("Details of Issue 1"),
              ),
              ListTile(
                title: Text("Issue Detail 2"),
                subtitle: Text("Details of Issue 2"),
              ),
              ListTile(
                title: Text("Issue Detail 3"),
                subtitle: Text("Details of Issue 3"),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Other Widget methods like _buildHeader(), _buildProfileRow(), _buildCaptionInput(), _buildImagesGrid(), _buildShareButton(), _buildWardNotice() remain the same as in your code.
}
