import 'package:flutter/material.dart';

import 'SearchPage/Tagscreen.dart';

class PreviousScreen extends StatefulWidget {
  @override
  _PreviousScreenState createState() => _PreviousScreenState();
}

class _PreviousScreenState extends State<PreviousScreen> {
  List<dynamic> _selectedUsers = [];
  List<dynamic> _selectedHashtags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Added Scaffold here
      appBar: AppBar(
        title: Text('Previous Screen'), // Optional, you can remove the AppBar if not needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person_add_alt_1,
                  color: Colors.blue, // replace with your primaryColor
                ),
                title: const Text("Tag people"),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _selectedUsers = result['selectedUsers'] ?? [];
                      _selectedHashtags = result['selectedHashtags'] ?? [];
                    });
                  }
                },
              ),
            ),
            // Display selected users and hashtags
            if (_selectedUsers.isNotEmpty || _selectedHashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedUsers.isNotEmpty) ...[
                      const Text(
                        'Selected Users:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _selectedUsers
                            .map((user) => Chip(
                          label: Text(user['user_name']),
                          backgroundColor: Colors.lightBlue.shade100,
                        ))
                            .toList(),
                      ),
                    ],
                    if (_selectedHashtags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Selected Hashtags:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _selectedHashtags
                            .map((hashtag) => Chip(
                          label: Text('#${hashtag['hashtag_name']}'),
                          backgroundColor: Colors.lightGreen.shade100,
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
    );
  }
}
