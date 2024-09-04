import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Services/Authservices.dart';
import 'package:myshetra/Controller/user_selector_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentTab = 'Users';
  List<dynamic> _results = [];

  final SelectionController selectionController =
  Get.put(SelectionController());
  bool _isLoading = false;
  String _errorMessage = '';
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Hashtags'),
            ],
            onTap: (index) {
              setState(() {
                _currentTab = index == 0 ? 'Users' : 'Hashtags';
                _results = [];
                _errorMessage = '';
                _searchController.clear();
              });
            },
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {
                'selectedUsers': selectionController.selectedUsers,
                'selectedHashtags': selectionController.selectedHashtags,
              });
            },
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _search,
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search $_currentTab',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            // Selected Items Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(() => Wrap(
                spacing: 8.0,
                children: _currentTab == 'Users'
                    ? selectionController.selectedUsers
                    .map((user) =>
                    _buildSelectedItem(user['user_name'], () {
                      selectionController.removeUser(user);
                    }))
                    .toList()
                    : selectionController.selectedHashtags
                    .map((hashtag) =>
                    _buildSelectedItem(hashtag['hashtag_name'], () {
                      selectionController.removeHashtag(hashtag);
                    }))
                    .toList(),
              )),
            ),
            // Search Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(
                  child: Text(_errorMessage.isEmpty
                      ? 'No $_currentTab found'
                      : _errorMessage))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  final isSelected = _currentTab == 'Users'
                      ? selectionController.selectedUsers
                      .contains(item)
                      : selectionController.selectedHashtags
                      .contains(item);

                  return ListTile(
                    title: Text(_currentTab == 'Users'
                        ? item['user_name']
                        : item['hashtag_name']),
                    subtitle: Text(_currentTab == 'Users'
                        ? item['handle_name']
                        : 'Usage count: ${item['hashtag_usage_count']}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_box)
                        : const Icon(Icons.check_box_outline_blank),
                    onTap: () {
                      setState(() {
                        if (_currentTab == 'Users') {
                          if (isSelected) {
                            selectionController.removeUser(item);
                          } else {
                            selectionController.addUser(item);
                          }
                        } else {
                          if (isSelected) {
                            selectionController.removeHashtag(item);
                          } else {
                            selectionController.addHashtag(item);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItem(String text, VoidCallback onRemove) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.lightBlue.shade100,
      deleteIcon: const Icon(Icons.clear, size: 18),
      onDeleted: onRemove,
    );
  }

  void _search(String text) async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _results = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
      _errorMessage = '';
    });

    var headers = {
      'Authorization': authService.token.value,
    };
    var uri = _currentTab == 'Users'
        ? 'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/searchUsersForUserMention?search_query=${_searchController.text}'
        : 'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/searchHashTagsForTagging?search_query=${_searchController.text}';

    var request = http.Request('POST', Uri.parse(uri));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        setState(() {
          if (_currentTab == 'Users') {
            _results = jsonResponse['data']['users'];
          } else {
            _results = jsonResponse['data']['hashtags'];
          }
          if (_results.isEmpty) {
            _errorMessage = 'No $_currentTab found';
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
