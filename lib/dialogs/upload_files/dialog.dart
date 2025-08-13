import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:stolity_desktop_application/dialogs/download_from_url/buttons.dart';
import 'package:stolity_desktop_application/dialogs/upload_files/controller.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/textfeilds.dart';

class FileUploadDialog extends StatefulWidget {
  const FileUploadDialog({super.key});

  @override
  State<FileUploadDialog> createState() => _FileUploadDialogState();
}

class _FileUploadDialogState extends State<FileUploadDialog> {
  int _selectedTabIndex = 0;
  bool _isPrivate = false;
  List<File> selectedFiles = [];
  String selectedFolderPath = ""; // Add this to track the folder path

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double dialogWidth = Get.width * 0.6;
          double dialogHeight = Get.height * 0.6;

          if (_selectedTabIndex == 1) {
            dialogWidth = Get.width * 0.6;
            dialogHeight = Get.height * 0.5;
          }
          if (_selectedTabIndex == 2) {
            dialogWidth = Get.width * 0.6;
            dialogHeight = Get.height * 0.4;
          }
          return Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _buildTab(0, Icons.insert_drive_file_outlined, 'Files'),
                      _buildTab(
                          1, Icons.create_new_folder_outlined, 'Upload Folder'),
                      _buildTab(2, Icons.folder_outlined, 'Folder'),
                    ],
                  ),
                ),

                Container(
                  height: 3,
                  margin: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: _selectedTabIndex == 0
                              ? Colors.orange
                              : Colors.transparent,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: _selectedTabIndex == 1
                              ? Colors.orange
                              : Colors.transparent,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: _selectedTabIndex == 2
                              ? Colors.orange
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Tab content area
                Expanded(
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildFilesTab(),
                      _buildUploadFolderTab(),
                      _buildFolderTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            // Clear selected files when switching tabs
            if (_selectedTabIndex != 0) {
              selectedFiles = [];
            }
            if (_selectedTabIndex != 1) {
              selectedFolderPath = "";
            }
          });
        },
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.orange
                  : const Color.fromARGB(255, 154, 152, 152),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.orange
                    : const Color.fromARGB(255, 154, 152, 152),
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await _pickFiles();
            },
            child: SvgPicture.network(
              "https://stolity.com/static/media/Background.b2e30a080645db1cb9b8a5f1f8683c5b.svg",
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: Get.height * 0.2),
            child: GestureDetector(
              onTap: () async {
                await _pickFiles();
              },
              child: SvgPicture.network(
                "https://stolity.com/static/media/UploadIcon.c1b8e2f29da6514089b13505f8cec485.svg",
                width: 50,
                height: 50,
              ),
            ),
          ),

          Positioned(
            bottom: Get.height * 0.08,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text('Max File size is 5 GB',
                          style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Set Visibility:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _isPrivate,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value!;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                      Text('Public'),
                      const SizedBox(width: 20),
                      Radio<bool>(
                        value: true,
                        groupValue: _isPrivate,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value!;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                      Text('Private'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Show selected files if any
          if (selectedFiles.isNotEmpty)
            Positioned(
              top: Get.height * 0.15,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: Get.height * 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Files:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedFiles.length,
                        itemBuilder: (context, index) {
                          final fileName =
                              path.basename(selectedFiles[index].path);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      selectedFiles.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Buttons positioned at bottom
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(120, 45),
                    ),
                    child: Text('Close'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedFiles.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please select files to upload",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      await UploadController.uploadFilesOrFolder(
                        context,
                        selectedFiles,
                        "", // Empty folder path for individual files
                        _isPrivate,
                        (id, message) {
                          Get.snackbar(
                            "Uploading",
                            message,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        },
                        (id, progress) {
                          if (progress % 25 == 0) {
                            print("Upload progress for $id: $progress%");
                          }
                        },
                        (id) {
                          print("Upload complete for $id");
                        },
                      );

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(120, 45),
                    ),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method to pick files
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
        selectedFolderPath = ""; // Reset folder path when picking files
      });

      print("Selected files: ${selectedFiles.map((f) => f.path).join(', ')}");
    }
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        selectedFolderPath = selectedDirectory;
      });

      Directory directory = Directory(selectedDirectory);
      List<FileSystemEntity> entities = directory.listSync(recursive: true);

      setState(() {
        selectedFiles = entities
            .where((entity) => entity is File)
            .map((entity) => File(entity.path))
            .toList();
      });

      String folderName = path.basename(directory.path);
      print(
          "Selected folder: $folderName, Files count: ${selectedFiles.length}");
    }
  }

  Widget _buildUploadFolderTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(
            'Upload Folder',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: Colors.grey[300]!,
            strokeWidth: 1,
            dashPattern: [5, 3],
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Choose a folder or drag & drop it here',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedFolderPath.isNotEmpty
                          ? 'Selected folder: ${path.basename(selectedFolderPath)} (${selectedFiles.length} files)'
                          : 'JPEG, PNG, PDF, and other file formats, up to 50MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _pickFolder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text('Browse Folder'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text('Set Visibility:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value!;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                    Text('Public'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: true,
                      groupValue: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value!;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                    Text('Private'),
                  ],
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text('Close'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedFiles.isEmpty || selectedFolderPath.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please select a folder to upload",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    await UploadController.uploadFilesOrFolder(
                      context,
                      selectedFiles,
                      selectedFolderPath, // Pass the folder path here
                      _isPrivate,
                      (id, message) {
                        Get.snackbar(
                          "Uploading",
                          message,
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      },
                      (id, progress) {
                        if (progress % 25 == 0) {
                          print("Upload progress for $id: $progress%");
                        }
                      },
                      (id) {
                        print("Upload complete for $id");
                      },
                    );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTab() {
    final TextEditingController folderNameController = TextEditingController();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Text("Create Folder",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          const SizedBox(height: 10),
          CustomTextField(
            title: '',
            hintText: "Enter Folder Name",
            controller: folderNameController,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonForDialog(
                text: "Close",
                onPressed: () => Navigator.pop(context),
                buttonColor: Colors.grey.shade100,
                pressedTextColor: Colors.transparent,
                textColor: Colors.grey,
              ),
              SizedBox(width: 30),
              ButtonForDialog(
                text: "Submit",
                onPressed: () async {
                  String foldername = folderNameController.text;
                  if (foldername.isEmpty) {
                    Get.snackbar("Error", "Please enter a folder name",
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  await FolderController.createFolder(context, foldername);
                  folderNameController.clear();
                },
                buttonColor: Color(0xFFFFAB49),
                textColor: Colors.white,
                pressedTextColor: const Color.fromARGB(0, 192, 165, 165),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
