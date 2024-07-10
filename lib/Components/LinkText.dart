import 'package:flutter/material.dart';
import 'package:myshetra/Components/WebView.dart';
import 'package:myshetra/helpers/colors.dart';
// import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  final String link;
  final String text;

  LinkText({required this.link, required this.text});

  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(link);
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WebViewPage(
              title: text,
              url: link,
            ),
          ),
        );
        // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        //   throw Exception('Could not launch $uri');
        // }
      },
      child: Text(
        text,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      ),
    );
  }
}
