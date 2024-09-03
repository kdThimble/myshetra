import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myshetra/Components/post_card.dart';
import 'package:myshetra/Models/post_model.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  @override
  Widget build(BuildContext context) {
    String responseString = '''
  {
    "page": 1,
    "pageSize": 10,
    "totalPosts": 9,
    "posts": [
      {
        "ID": 11,
        "Title": "hello post23",
        "SubTitle": "",
        "Content": "",
        "AddedBy": "00000000-0000-0000-0000-000000000000",
        "UpdatedBy": "00000000-0000-0000-0000-000000000000",
        "CreatedAt": "2024-08-19T10:44:24.806495Z",
        "UpdatedAt": "0001-01-01T00:00:00Z",
        "Tagging": [],
        "Media": [
          {
            "ID": 2,
            "FilePath": "https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=1024x1024&w=0&k=20&c=z8_rWaI8x4zApNEEG9DnWlGXyDIXe-OmsAyQ5fGPVV8=",
            "MediaType": "PHOTO",
            "CreatedAt": "2024-08-19T10:28:16.151155Z",
            "AddedBy": "00000000-0000-0000-0000-000000000000",
            "UpdatedBy": "00000000-0000-0000-0000-000000000000"
          },
          {
            "ID": 3,
            "FilePath": "dmeo.jpg",
            "MediaType": "PHOTO",
            "CreatedAt": "2024-08-19T10:33:11.247568Z",
            "AddedBy": "00000000-0000-0000-0000-000000000000",
            "UpdatedBy": "00000000-0000-0000-0000-000000000000"
          }
        ],
        "PostInteractions": {
          "ID": 0,
          "PostID": 0,
          "Likes": 0,
          "Views": 0,
          "Comments": 0,
          "Shares": 0,
          "CreatedAt": "0001-01-01T00:00:00Z",
          "UpdatedAt": "0001-01-01T00:00:00Z"
        }
      },
      {
        "ID": 11,
        "Title": "hello post23",
        "SubTitle": "",
        "Content": "",
        "AddedBy": "00000000-0000-0000-0000-000000000000",
        "UpdatedBy": "00000000-0000-0000-0000-000000000000",
        "CreatedAt": "2024-08-19T10:44:24.806495Z",
        "UpdatedAt": "0001-01-01T00:00:00Z",
        "Tagging": [],
        "Media": [
          {
            "ID": 2,
            "FilePath": "https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=1024x1024&w=0&k=20&c=z8_rWaI8x4zApNEEG9DnWlGXyDIXe-OmsAyQ5fGPVV8=",
            "MediaType": "PHOTO",
            "CreatedAt": "2024-08-19T10:28:16.151155Z",
            "AddedBy": "00000000-0000-0000-0000-000000000000",
            "UpdatedBy": "00000000-0000-0000-0000-000000000000"
          },
          {
            "ID": 3,
            "FilePath": "dmeo.jpg",
            "MediaType": "PHOTO",
            "CreatedAt": "2024-08-19T10:33:11.247568Z",
            "AddedBy": "00000000-0000-0000-0000-000000000000",
            "UpdatedBy": "00000000-0000-0000-0000-000000000000"
          }
        ],
        "PostInteractions": {
          "ID": 0,
          "PostID": 0,
          "Likes": 0,
          "Views": 0,
          "Comments": 0,
          "Shares": 0,
          "CreatedAt": "0001-01-01T00:00:00Z",
          "UpdatedAt": "0001-01-01T00:00:00Z"
        }
      }
    ]
  }
  ''';

    // Step 2: Parse the response string into a Map
    Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    // Step 3: Convert the JSON response to the ApiResponse model
    ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);
    print("post ${apiResponse.posts[0].title}");
    print("Length ${apiResponse.posts.length}");
    return Scaffold(
      body: ListView.builder(
        itemCount: apiResponse.posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: apiResponse.posts[index]);
        },
      ),
    );
  }
}
