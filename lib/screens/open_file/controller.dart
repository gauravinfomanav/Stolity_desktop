import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/screens/open_file/fileviewer.dart';


class FileOpenController {
  Future<void> fetchAndOpenFile(BuildContext context, String fileName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Construct the URL
      final url = Uri.parse("${Constants.getfiledata}$fileName");

      // Get the access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        // Close the loading dialog
        Navigator.pop(context);
        throw Exception('No access token found. Please log in.');
      }

      // Make the HTTP request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // Close the loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Open file in our custom viewer instead of system default
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileViewer(
              filePath: filePath,
              fileName: fileName,
            ),
          ),
        );
      } else {
        print('Error fetching file: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching file: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Make sure to close the loading dialog if there's an error
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while fetching the file: $e'),
        ),
      );
    }
  }
}