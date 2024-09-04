import 'package:get/get.dart';

class SelectionController extends GetxController {
  var selectedUsers = <dynamic>[].obs;
  var selectedHashtags = <dynamic>[].obs;

  void addUser(dynamic user) {
    selectedUsers.add(user);
  }

  void removeUser(dynamic user) {
    selectedUsers.remove(user);
  }

  void addHashtag(dynamic hashtag) {
    selectedHashtags.add(hashtag);
  }

  void removeHashtag(dynamic hashtag) {
    selectedHashtags.remove(hashtag);
  }
}
