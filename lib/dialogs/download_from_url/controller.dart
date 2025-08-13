import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';

class DownloadFromUrlController {
  static Future<void> downloadFileFromUrl(
      BuildContext context, String fileUrl, String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    Uri url = Uri.parse(Constants.downloadfromurl);

    Map<String, dynamic> body = {
      "folderPath": "",
      "isPrivate": "public-read",
      "name": fileName,
      "url": fileUrl,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('Download Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  static String extractFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file';
  }
}
