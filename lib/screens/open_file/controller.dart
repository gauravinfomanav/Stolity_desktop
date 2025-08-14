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
import 'dart:convert';
import 'package:file_picker/file_picker.dart';


class FileOpenController {
  // Helper function to show a custom save dialog
  Future<String?> _showCustomSaveDialog(BuildContext context, String fileName) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save File'),
          content: Text('File will be saved to Documents folder as: $fileName'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(fileName),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

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

      Future<String?> saveBytes(Uint8List bytes) async {
        final fileName = p.basename(normalizedKey);
        
        // On macOS, use save dialog instead of direct Downloads access
        if (Platform.isMacOS) {
          if (kDebugMode) {
            print('[DL] Showing save dialog for macOS...');
          }
          try {
            // Try using a different approach for macOS
            String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Save File',
              fileName: fileName,
              type: FileType.any,
              lockParentWindow: true,
            );
            
            if (outputFile != null) {
              final file = File(outputFile);
              await file.writeAsBytes(bytes);
              if (kDebugMode) {
                print('[DL] Saved to: $outputFile');
              }
              return outputFile;
            } else {
              if (kDebugMode) {
                print('[DL] User cancelled save dialog');
              }
              return null;
            }
          } catch (e) {
            if (kDebugMode) {
              print('[DL] Save dialog error: $e');
            }
            // Fallback: try custom dialog and save to Documents directory
            try {
              final result = await _showCustomSaveDialog(context, fileName);
              if (result != null) {
                final documentsDir = await getApplicationDocumentsDirectory();
                final fallbackPath = p.join(documentsDir.path, fileName);
                final file = File(fallbackPath);
                await file.writeAsBytes(bytes);
                if (kDebugMode) {
                  print('[DL] Custom dialog saved to: $fallbackPath');
                }
                return fallbackPath;
              } else {
                if (kDebugMode) {
                  print('[DL] User cancelled custom dialog');
                }
                return null;
              }
            } catch (fallbackError) {
              if (kDebugMode) {
                print('[DL] Custom dialog save error: $fallbackError');
              }
              return null;
            }
          }
        } else {
          // For other platforms, use the original Downloads logic
          final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
          final dlPath = p.join(home, 'Downloads', fileName);
          final f = File(dlPath);
          await f.create(recursive: true);
          await f.writeAsBytes(bytes);
          return dlPath;
        }
      }

      if (response.statusCode == 200) {
        final savedPath = await saveBytes(response.bodyBytes);
        if (savedPath != null) {
          if (kDebugMode) {
            print('[DL] Saved to: $savedPath');
          }
          showStolitySnack(context, 'File downloaded successfully.');
        } else {
          showStolitySnack(context, 'Download cancelled by user.');
        }
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
          if (savedPath != null) {
            if (kDebugMode) {
              print('[DL] Fallback Saved to: $savedPath');
            }
            showStolitySnack(context, 'File downloaded successfully.');
            return;
          } else {
            showStolitySnack(context, 'Download cancelled by user.');
            return;
          }
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

  Future<void> downloadFolderZip(BuildContext context, String folderPath) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');
      final String? refreshToken = prefs.getString('refreshToken');
      final cookieHeader = [
        if (accessToken != null && accessToken.isNotEmpty) 'accessToken=$accessToken',
        if (refreshToken != null && refreshToken.isNotEmpty) 'refreshToken=$refreshToken',
      ].join('; ');

      // Web uses only the folder name in filePath. Send only the last segment.
      final String onlyFolderName = folderPath.split('/').last;
      final encPath = Uri.encodeQueryComponent(onlyFolderName);
      final url = Uri.parse('${Constants.downloadFolderZip}$encPath');
      if (kDebugMode) {
        print('[DLFOLDER] GET /download-folder: $url');
      }
      final response = await http.get(
        url,
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
          if (accessToken != null && accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
        },
      );

      Future<String?> saveZip(Uint8List bytes) async {
        final baseName = p.basename(onlyFolderName);
        final zipName = baseName.isNotEmpty ? '$baseName.zip' : 'folder.zip';
        
        // On macOS, use save dialog instead of direct Downloads access
        if (Platform.isMacOS) {
          if (kDebugMode) {
            print('[DLFOLDER] Showing save dialog for macOS...');
          }
          try {
            String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Save ZIP File',
              fileName: zipName,
              type: FileType.custom,
              allowedExtensions: ['zip'],
              lockParentWindow: true,
            );
            
            if (outputFile != null) {
              final file = File(outputFile);
              await file.writeAsBytes(bytes);
              if (kDebugMode) {
                print('[DLFOLDER] Saved to: $outputFile');
              }
              return outputFile;
            } else {
              if (kDebugMode) {
                print('[DLFOLDER] User cancelled save dialog');
              }
              return null;
            }
          } catch (e) {
            if (kDebugMode) {
              print('[DLFOLDER] Save dialog error: $e');
            }
            // Fallback: try custom dialog and save to Documents directory
            try {
              final result = await _showCustomSaveDialog(context, zipName);
              if (result != null) {
                final documentsDir = await getApplicationDocumentsDirectory();
                final fallbackPath = p.join(documentsDir.path, zipName);
                final file = File(fallbackPath);
                await file.writeAsBytes(bytes);
                if (kDebugMode) {
                  print('[DLFOLDER] Custom dialog saved to: $fallbackPath');
                }
                return fallbackPath;
              } else {
                if (kDebugMode) {
                  print('[DLFOLDER] User cancelled custom dialog');
                }
                return null;
              }
            } catch (fallbackError) {
              if (kDebugMode) {
                print('[DLFOLDER] Custom dialog save error: $fallbackError');
              }
              return null;
            }
          }
        } else {
          // For other platforms, use the original Downloads logic
          final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
          final dlPath = p.join(home, 'Downloads', zipName);
          final f = File(dlPath);
          await f.create(recursive: true);
          await f.writeAsBytes(bytes);
          return dlPath;
        }
      }

      if (response.statusCode == 200) {
        final saved = await saveZip(response.bodyBytes);
        if (saved != null) {
          if (kDebugMode) print('[DLFOLDER] Saved ZIP to: $saved');
          showStolitySnack(context, 'Folder downloaded as ZIP.');
        } else {
          showStolitySnack(context, 'Download cancelled by user.');
        }
      } else if (response.statusCode == 401) {
        showStolitySnack(context, 'Unauthorized. Please login again.');
      } else {
        if (kDebugMode) print('[DLFOLDER] Error ${response.statusCode}: ${response.body}');
        showStolitySnack(context, 'Failed to download folder (${response.statusCode}).');
      }
    } catch (e) {
      if (kDebugMode) print('[DLFOLDER] Exception: $e');
      showStolitySnack(context, 'Error downloading folder: $e');
    }
  }
}