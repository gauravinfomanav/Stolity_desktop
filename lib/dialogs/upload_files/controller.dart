import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/components/stolity_snackbar.dart';
import 'package:stolity_desktop_application/components/upload_progress_overlay.dart';

class FolderController {
  static Future<void> createFolder(
      BuildContext context, String folderName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    const String uploadFileUrl = "${Constants.baseUrl}create-folder";

    Map<String, dynamic> body = {
      "folderName": folderName,
    };

    try {
      final response = await http.post(
        Uri.parse(uploadFileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken ?? ''}',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('Create Folder Response: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        showStolitySnack(context, "Folder '$folderName' created successfully!");
        Navigator.of(context).pop('refresh');
      } else {
        showStolitySnack(context, "Failed to create folder: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating folder: $e');
      }
      showStolitySnack(context, "Error creating folder: ${e.toString()}");
    }
  }
}



class UploadController {
  static Future<void> uploadFilesOrFolder(
    BuildContext context,
    List<File> files,
    String folderPath,
    bool isPrivate,
    Function(String id, String message)? onUploadStart,
    Function(String id, int progress)? onUploadProgress,
    Function(String id)? onUploadComplete,
  ) async {
    if (files.isEmpty) {
      showStolitySnack(context, "Please select files or a folder to upload.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      if (folderPath.isNotEmpty) {
        // Upload folder
        await _uploadFolder(
          files,
          folderPath,
          isPrivate,
          accessToken,
          onUploadStart,
          onUploadProgress,
          onUploadComplete,
        );
      } else {
        // Upload individual files
        await _uploadFiles(
          files,
          isPrivate,
          accessToken,
          onUploadStart,
          onUploadProgress,
          onUploadComplete,
        );
      }

      showStolitySnack(
        context,
        folderPath.isNotEmpty
            ? "Folder uploaded successfully!"
            : (files.length > 1
                ? "Files uploaded successfully!"
                : "File uploaded successfully!"),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading files: $e');
      }

      showStolitySnack(context, "Error uploading files: ${e.toString()}");
    }
  }

  static Future<void> _uploadFiles(
    List<File> files,
    bool isPrivate,
    String? accessToken,
    Function(String id, String message)? onUploadStart,
    Function(String id, int progress)? onUploadProgress,
    Function(String id)? onUploadComplete,
  ) async {
    const String uploadEndpoint = Constants.getuploadurl;

    for (int i = 0; i < files.length; i++) {
      final File file = files[i];
      final String fileName = path.basename(file.path);
      final String sanitizedName = isVideoFile(fileName) ? sanitizeFilename(fileName) : fileName;
      final String uploadId = "${DateTime.now().millisecondsSinceEpoch}_$i";

      // Notify upload started and show overlay
      onUploadStart?.call(uploadId, "Uploading $sanitizedName");
      UploadProgressOverlay()
          .addOrUpdate(UploadProgressItem(id: uploadId, label: sanitizedName, progress: 0));

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));
      print(request.url);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer ${accessToken ?? ''}';
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      // Add metadata
      request.fields['fileName'] = sanitizedName;
      request.fields['fileSize'] = (await file.length()).toString();
      request.fields['acl'] = isPrivate ? "private" : "public-read";

      // Send request with progress tracking
      var streamedResponse = await request.send();

      // Simulate progress updates and update overlay
      for (int p = 10; p <= 100; p += 10) {
        await Future.delayed(Duration(milliseconds: 100));
        onUploadProgress?.call(uploadId, p);
        UploadProgressOverlay()
            .addOrUpdate(UploadProgressItem(id: uploadId, label: sanitizedName, progress: p));
      }

      if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
        onUploadComplete?.call(uploadId);
        UploadProgressOverlay()
            .addOrUpdate(UploadProgressItem(id: uploadId, label: sanitizedName, progress: 100));
      } else {
        throw Exception('Failed to upload file: ${streamedResponse.statusCode}');
      }
    }
  }

  static Future<void> _uploadFolder(
    List<File> files,
    String folderPath,
    bool isPrivate,
    String? accessToken,
    Function(String id, String message)? onUploadStart,
    Function(String id, int progress)? onUploadProgress,
    Function(String id)? onUploadComplete,
  ) async {
    const String uploadFolderEndpoint = Constants.uploadfolder;
    final String uploadId = "${DateTime.now().millisecondsSinceEpoch}_folder";
    final String localPath = path.basename(folderPath);

    // Notify upload started and show overlay
    onUploadStart?.call(uploadId, "Uploading folder $localPath");
    UploadProgressOverlay()
        .addOrUpdate(UploadProgressItem(id: uploadId, label: 'Folder: $localPath', progress: 0));

    // Create multipart request
    var request = http.MultipartRequest('POST', Uri.parse(uploadFolderEndpoint));
    
    // Add headers
    request.headers['Authorization'] = 'Bearer ${accessToken ?? ''}';
    
    // Add folder metadata
    request.fields['localPath'] = localPath;
    request.fields['acl'] = isPrivate ? "private" : "public-read";

    // Add all files with their relative paths
    for (File file in files) {
      String filePath = file.path;
      String relativePath = '';

      if (filePath.startsWith(folderPath)) {
        String relPath = filePath.substring(folderPath.length);
        if (relPath.startsWith(Platform.pathSeparator)) {
          relPath = relPath.substring(1);
        }
        final dirname = path.dirname(relPath);
        relativePath = dirname == '.' ? '' : dirname.replaceAll(Platform.pathSeparator, '/');
      }

      final String fileName = path.basename(filePath);
      final String sanitizedName = isVideoFile(fileName) ? sanitizeFilename(fileName) : fileName;

      if (kDebugMode) {
        print('Processing file: $fileName with relative path: $relativePath, localPath: $localPath');
      }

      // Add file to request
      var multipartFile = await http.MultipartFile.fromPath('files', file.path);
      request.files.add(multipartFile);
      
      // Add file metadata as fields
      request.fields['fileNames'] = request.fields['fileNames'] != null 
          ? '${request.fields['fileNames']!},$sanitizedName'
          : sanitizedName;
      
      request.fields['filePaths'] = request.fields['filePaths'] != null 
          ? '${request.fields['filePaths']!},$relativePath'
          : relativePath;
      
      request.fields['fileSizes'] = request.fields['fileSizes'] != null 
          ? '${request.fields['fileSizes']!},${await file.length()}'
          : (await file.length()).toString();
    }

    // Send request with progress tracking
    var streamedResponse = await request.send();

    // Simulate progress updates and update overlay
    for (int p = 10; p <= 100; p += 10) {
      await Future.delayed(Duration(milliseconds: 200));
      onUploadProgress?.call(uploadId, p);
      UploadProgressOverlay()
          .addOrUpdate(UploadProgressItem(id: uploadId, label: 'Folder: $localPath', progress: p));
    }

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      onUploadComplete?.call(uploadId);
      UploadProgressOverlay()
          .addOrUpdate(UploadProgressItem(id: uploadId, label: 'Folder: $localPath', progress: 100));
    } else {
      throw Exception('Failed to upload folder: ${streamedResponse.statusCode}');
    }
  }

  static bool isVideoFile(String fileName) {
    final videoExtensions = ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv'];
    final extension = path.extension(fileName).toLowerCase();
    return videoExtensions.contains(extension);
  }

  static String sanitizeFilename(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s\.]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  static String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.ppt':
      case '.pptx':
        return 'application/vnd.ms-powerpoint';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.zip':
        return 'application/zip';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}