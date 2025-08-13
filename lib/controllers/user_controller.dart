import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stolity_desktop_application/Constants.dart';

class UserController {
  // Method to get files with sorting
  Future<List<FileModel>> getFilesWithSorting(
      BuildContext context, String sortType) async {
    
    Uri url;

    switch (sortType) {
      case "By Name (A-Z)":
        url = Uri.parse(Constants.filterbynameasc);
        break;
      case "By Name (Z-A)":
        url = Uri.parse(Constants.filterbynamedesc);
        break;
      case "By Size (Ascending)":
        url = Uri.parse(Constants.filterbysizeasc);
        break;
      case "By Size (Descending)":
        url = Uri.parse(Constants
            .filterysizedesc); 
        break;
      case "By Date (Oldest)":
        url = Uri.parse(Constants.filterbydateasc);
        break;
      case "By Date (Newest)":
        url = Uri.parse(Constants.filterbydatedesc);
        break;
      default:
        url = Uri.parse(Constants.Getfiles);
        break;
    }

    if (kDebugMode) {
      print('Using URL: $url for sort type: $sortType');
    }

    return _fetchFiles(context, url);
  }

//************************************************************************************************************************* */  
Future<List<FileModel>> searchFiles(
      BuildContext context, String searchQuery) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      final url = Uri.parse("${Constants.searchfile}$searchQuery");
      
      if (kDebugMode) {
        print('Searching with URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Search Response: ${response.body}');
        }

        final dynamic decodedResponse = jsonDecode(response.body);
        List<dynamic> fileList;

        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('result') &&
              decodedResponse['result'] is List) {
            fileList = decodedResponse['result'];
          } else {
            _showErrorDialog(
                context, 'Invalid data format: Expected "result" field');
            return [];
          }
        } else if (decodedResponse is List) {
          fileList = decodedResponse;
        } else {
          _showErrorDialog(context, 'Unexpected response format');
          return [];
        }

        return fileList.map((json) => FileModel.fromJson(json)).toList();
      } else {
        _showErrorDialog(context, 'Search error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in searchFiles: $e');
      }
      _showErrorDialog(context, 'Error during search: ${e.toString()}');
      return [];
    }
  }

//************************************************************************************************************************* */
  
  Future<List<FileModel>> getFilesByFileTypes(
      BuildContext context, List<String> fileTypes) async {
 
    String typesQuery = fileTypes.join(',');
 
    Uri url = Uri.parse("${Constants.filterbytype}$typesQuery");

    if (kDebugMode) {
      print('Fetching files with types: $typesQuery');
      print('Using URL: $url');
    }

    return _fetchFiles(context, url);
  }


Future<bool> deleteFiles(BuildContext context, List<FileModel> filesToDelete) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  bool allDeleted = true;

  for (FileModel file in filesToDelete) {
    try {
      bool deleteResult = await _deleteSingleFile(context, file, accessToken);
      if (!deleteResult) {
        allDeleted = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting ${file.fileName}: $e');
      }
      allDeleted = false;
    }
  }

  return allDeleted;
}

// Delete single file or folder
Future<bool> _deleteSingleFile(BuildContext context, FileModel file, String? accessToken) async {
  try {
    if (file.isFolder) {
      // Delete folder
      final url = Uri.parse(Constants.deletefolder);
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
        body: jsonEncode({
          'folderName': [file.fileName]
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Folder ${file.fileName} deleted successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Error deleting folder: ${response.statusCode}');
        }
        return false;
      }
    } else {
      // Delete file
      final url = Uri.parse(Constants.deletefile);
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
        body: jsonEncode({
          'keys': [file.fileName]
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('File ${file.fileName} deleted successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Error deleting file: ${response.statusCode}');
        }
        return false;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in _deleteSingleFile: $e');
    }
    return false;
  }
}

  
  Future<List<FileModel>> getFiles(BuildContext context) async {
    final url = Uri.parse(Constants.Getfiles);
    return _fetchFiles(context, url);
  }

  // Helper method to fetch files from any URL
  Future<List<FileModel>> _fetchFiles(BuildContext context, Uri url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response: ${response.body}');
        }

        // Handle different response formats
        final dynamic decodedResponse = jsonDecode(response.body);
        List<dynamic> fileList;

        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('result') &&
              decodedResponse['result'] is List) {
            fileList = decodedResponse['result'];
          } else {
            _showErrorDialog(
                context, 'Invalid data format: Expected "result" field');
            return [];
          }
        } else if (decodedResponse is List) {
          fileList = decodedResponse;
        } else {
          _showErrorDialog(context, 'Unexpected response format');
          return [];
        }

        return fileList.map((json) => FileModel.fromJson(json)).toList();
      } else {
        _showErrorDialog(context, 'Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _fetchFiles: $e');
      }
      _showErrorDialog(context, 'Error connecting to server: ${e.toString()}');
      return [];
    }

    
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class FileModel {
  final String fileName;
  final String fileSize;
  final String fileType;
  final String uploadDateTime;
  final String url;
  final bool isFolder;
  final String icon;

  FileModel({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.uploadDateTime,
    required this.url,
    required this.isFolder,
    required this.icon,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? '',
      fileType: json['fileType'] ?? '',
      uploadDateTime: json['uploadDateTime'] ?? '',
      url: json['url'] ?? '',
      isFolder: json['isFolder'] ?? false,
      icon: json['icon'] ?? '',
    );
  }
}

class FolderContents {
  final String folderPath;
  final List<FileModel> files;
  final List<String> folders; // names/paths of subfolders
  FolderContents({required this.folderPath, required this.files, required this.folders});
}

extension FolderApi on UserController {
  Future<FolderContents> getFolderContents(BuildContext context, String folderPath) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final url = Uri.parse('${Constants.getFolder}${Uri.encodeQueryComponent(folderPath)}');
      if (kDebugMode) {
        print('[FOLDER] GET: $url');
      }
      final response = await http.get(url, headers: {
        if (accessToken != null && accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      });
      if (kDebugMode) {
        print('[FOLDER] Status: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          // API returned a list of file objects
          final files = decoded.map<FileModel>((j) => FileModel.fromJson(j as Map<String, dynamic>)).toList();
          return FolderContents(folderPath: folderPath, files: files, folders: []);
        } else if (decoded is Map<String, dynamic>) {
          final filesJson = (decoded['files'] as List? ?? []);
          final files = filesJson.map((j) => FileModel.fromJson(j as Map<String, dynamic>)).toList();
          final folders = (decoded['folders'] as List? ?? []).map((e) => e.toString()).toList();
          return FolderContents(folderPath: decoded['folderPath']?.toString() ?? folderPath, files: files, folders: folders);
        } else {
          return FolderContents(folderPath: folderPath, files: [], folders: []);
        }
      }
      return FolderContents(folderPath: folderPath, files: [], folders: []);
    } catch (e) {
      if (kDebugMode) {
        print('[FOLDER] Exception: $e');
      }
      return FolderContents(folderPath: folderPath, files: [], folders: []);
    }
  }
}
