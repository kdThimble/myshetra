import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Services/Authservices.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _currentTab = 'Users';
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search'),
          bottom: TabBar(
            tabs: [
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
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search $_currentTab',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _search,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(child: Text(_errorMessage.isEmpty ? 'No $_currentTab found' : _errorMessage))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  if (_currentTab == 'Users') {
                    return ListTile(
                      title: Text(_results[index]['user_name']),
                      subtitle: Text(_results[index]['handle_name']),
                    );
                  } else {
                    return ListTile(
                      title: Text(_results[index]['hashtag_name']),
                      subtitle: Text('Usage count: ${_results[index]['hashtag_usage_count']}'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

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