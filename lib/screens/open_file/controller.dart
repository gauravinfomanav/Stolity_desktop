import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/screens/open_file/fileviewer.dart';
import 'package:path/path.dart' as p;
import 'package:stolity_desktop_application/dialogs/stolity_alert_prompt.dart';
import 'package:stolity_desktop_application/components/stolity_snackbar.dart';


class FileOpenController {
  String _extractKeyCandidate(String? fileKeyOrUrl, String fallbackName) {
    if (fileKeyOrUrl == null || fileKeyOrUrl.isEmpty) return fallbackName;
    try {
      final uri = Uri.parse(fileKeyOrUrl);
      if (uri.hasQuery && uri.queryParameters.containsKey('key')) {
        return Uri.decodeComponent(uri.queryParameters['key']!);
      }
      // Not a key URL; use path without leading slash
      final path = uri.path.isNotEmpty ? uri.path : fileKeyOrUrl;
      final trimmed = path.startsWith('/') ? path.substring(1) : path;
      return Uri.decodeComponent(trimmed);
    } catch (_) {
      return Uri.decodeComponent(fileKeyOrUrl);
    }
  }

  String _relativePathForGetFile(String keyOrPath, String fileName) {
    // If it looks like 'user_xxx/...', strip the first segment; otherwise keep as-is
    final parts = keyOrPath.split('/');
    if (parts.length > 1 && parts.first.startsWith('user_')) {
      return parts.sublist(1).join('/');
    }
    // If no slash, fall back to fileName to avoid using tokens like 'download-file'
    if (!keyOrPath.contains('/')) {
      return fileName;
    }
    return keyOrPath;
  }

  Future<void> fetchAndOpenFile(BuildContext context, String fileName, {String? fileKey}) async {
    try {
      // Pre-check extension to avoid navigating for unsupported types
      final ext = p.extension(fileName).toLowerCase();
      const supported = {
        '.pdf', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
        '.txt', '.md', '.csv', '.xlsx', '.xls',
        '.mp4', '.avi', '.mov', '.wmv',
        '.mp3', '.wav', '.m4a',
        '.json', '.yml', '.yaml', '.xml', '.log', '.ini'
      };
      if (!supported.contains(ext)) {
        await StolityPrompt.show(
          context: context,
          title: 'Unsupported file',
          subtitle: 'This file type ($ext) is not supported for in-app preview.',
          negativeButtonText: '',
          positiveButtonText: 'OK',
        );
        return;
      }

      // Show loading indicator now that we know it's supported
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
      );

      final candidate = _extractKeyCandidate(fileKey, fileName);
      final relativeForGetFile = _relativePathForGetFile(candidate, fileName);
      final url = Uri.parse("${Constants.getfiledata}${Uri.encodeQueryComponent(relativeForGetFile)}");
      if (kDebugMode) {
        print('[OPEN] GET: $url');
      }

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

      if (kDebugMode) {
        print('[OPEN] Status: ${response.statusCode} bytes: ${response.bodyBytes.length}');
      }

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final localRelativePath = relativeForGetFile;
        final filePath = '${directory.path}/$localRelativePath';
        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('[OPEN] Saved to: $filePath');
        }

        // Open file in our custom viewer instead of system default
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileViewer(
              filePath: filePath,
              fileName: fileName,
              fileKey: candidate,
            ),
          ),
        );
      } else {
        if (kDebugMode) {
          print('[OPEN] Error body: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching file: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OPEN] Exception: $e');
      }
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

  Future<void> backgroundDownloadByKey(BuildContext context, String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final String? refreshToken = prefs.getString('refreshToken');
      final cookieHeader = [
        if (accessToken != null && accessToken.isNotEmpty) 'accessToken=$accessToken',
        if (refreshToken != null && refreshToken.isNotEmpty) 'refreshToken=$refreshToken',
      ].join('; ');

      showStolitySnack(context, 'Download started. File will be saved to Downloads.');

      final normalizedKey = _extractKeyCandidate(key, key);
      final encKey = Uri.encodeQueryComponent(normalizedKey);
      final url = Uri.parse('${Constants.downloadFileByKey}$encKey');
      if (kDebugMode) {
        print('[DL] GET /download-file: $url');
        print('[DL] Headers: Cookie=${cookieHeader.isNotEmpty}, Authorization=${accessToken != null && accessToken.isNotEmpty}');
      }
      final response = await http.get(
        url,
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
          if (accessToken != null && accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (kDebugMode) {
        print('[DL] Status: ${response.statusCode} bytes: ${response.bodyBytes.length}');
        if (response.statusCode != 200) {
          print('[DL] Error body: ${response.body}');
        }
      }

      Future<String> saveBytes(Uint8List bytes) async {
        final fileName = p.basename(normalizedKey);
        // Try Downloads first
        try {
          final downloads = await getDownloadsDirectory();
          final dlPath = p.join(downloads?.path ?? '', fileName);
          final f = File(dlPath);
          await f.create(recursive: true);
          await f.writeAsBytes(bytes);
          return dlPath;
        } catch (e) {
          if (kDebugMode) {
            print('[DL] Write to Downloads failed: $e');
          }
          final docsDir = await getApplicationDocumentsDirectory();
          final docPath = p.join(docsDir.path, fileName);
          final f = File(docPath);
          await f.create(recursive: true);
          await f.writeAsBytes(bytes);
          return docPath;
        }
      }

      if (response.statusCode == 200) {
        final savedPath = await saveBytes(response.bodyBytes);
        if (kDebugMode) {
          print('[DL] Saved to: $savedPath');
        }
        showStolitySnack(context, 'File downloaded successfully.');
      } else if (response.statusCode == 404) {
        // Fallback: use getFile?filePath= with the relative path (strip leading bucket/user prefix when present)
        final relativeForGet = _relativePathForGetFile(normalizedKey, p.basename(normalizedKey));
        final fallbackUrl = Uri.parse('${Constants.getfiledata}${Uri.encodeQueryComponent(relativeForGet)}');
        if (kDebugMode) {
          print('[DL] Fallback GET: $fallbackUrl');
        }
        final fb = await http.get(
          fallbackUrl,
          headers: {
            if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
            if (accessToken != null && accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
          },
        );
        if (kDebugMode) {
          print('[DL] Fallback Status: ${fb.statusCode} bytes: ${fb.bodyBytes.length}');
          if (fb.statusCode != 200) {
            print('[DL] Fallback Error body: ${fb.body}');
          }
        }
        if (fb.statusCode == 200) {
          final savedPath = await saveBytes(fb.bodyBytes);
          if (kDebugMode) {
            print('[DL] Fallback Saved to: $savedPath');
          }
          showStolitySnack(context, 'File downloaded successfully.');
          return;
        }
        showStolitySnack(context, 'File not found on server.');
      } else if (response.statusCode == 401) {
        showStolitySnack(context, 'Unauthorized. Please login again.');
      } else {
        showStolitySnack(context, 'Download failed (${response.statusCode}).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DL] Exception: $e');
      }
      showStolitySnack(context, 'Error downloading file: $e');
    }
  }
}