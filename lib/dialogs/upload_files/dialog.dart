import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:stolity_desktop_application/dialogs/download_from_url/buttons.dart';
import 'package:stolity_desktop_application/dialogs/upload_files/controller.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/textfeilds.dart';
import 'package:stolity_desktop_application/autotextsize.dart';
import 'package:stolity_desktop_application/application_constants.dart';
import 'package:stolity_desktop_application/components/stolity_snackbar.dart';

class FileUploadDialog extends StatefulWidget {
  final int initialTabIndex;
  const FileUploadDialog({super.key, this.initialTabIndex = 0});

  @override
  State<FileUploadDialog> createState() => _FileUploadDialogState();
}

class _FileUploadDialogState extends State<FileUploadDialog> {
  late int _selectedTabIndex;
  bool _isPrivate = false;
  List<File> selectedFiles = [];
  String selectedFolderPath = ""; // Add this to track the folder path
  bool _isDraggingOver = false;

  @override
  void initState() {
    super.initState();
    int idx = widget.initialTabIndex;
    if (idx < 0) idx = 0;
    if (idx > 2) idx = 2;
    _selectedTabIndex = idx;
  }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - 32;
        final double zoneWidth = math.max(0, math.min(availableWidth, 560));
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropTarget(
                    onDragEntered: (_) {
                      setState(() {
                        _isDraggingOver = true;
                      });
                    },
                    onDragExited: (_) {
                      setState(() {
                        _isDraggingOver = false;
                      });
                    },
                    onDragDone: (details) async {
                      final droppedFiles = details.files
                          .map((xf) => xf.path)
                          .where((p) => p.isNotEmpty)
                          .map((p) => File(p))
                          .toList();
                      if (droppedFiles.isNotEmpty) {
                        setState(() {
                          selectedFolderPath = "";
                          selectedFiles.addAll(droppedFiles);
                          _isDraggingOver = false;
                        });
                      }
                    },
                    child: GestureDetector(
                      onTap: () async {
                        await _pickFiles();
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(16),
                        color: _isDraggingOver ? const Color(0xFFFFAB49) : const Color(0xFFFFEFE1),
                        dashPattern: const [6, 4],
                        strokeWidth: 1.2,
                        child: Container(
                          width: zoneWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          decoration: BoxDecoration(
                            color: _isDraggingOver ? const Color(0xFFFFF1E2) : const Color(0xFFFDF8F4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFFFE6CC), Color(0xFFFFD5A3)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFFFEFE1)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14FFAB49),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(CupertinoIcons.cloud_upload_fill, size: 36, color: Color(0xFF8A5C2C)),
                              ),
                              const SizedBox(height: 14),
                              MusaffaAutoSizeText.titleLarge(
                                "Upload your files",
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 6),
                              MusaffaAutoSizeText.bodyMedium(
                                "Click to select files",
                                color: Colors.black54,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  await _pickFiles();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFAB49),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(160, 44),
                                ),
                                child: const Text('Select files'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedFiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MusaffaAutoSizeText.bodyMedium(
                              "Selected Files:",
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListView.builder(
                                itemCount: selectedFiles.length,
                                itemBuilder: (context, index) {
                                  final fileName = path.basename(selectedFiles[index].path);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
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

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.info_outline, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text('Max File size is 5 GB', style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MusaffaAutoSizeText.bodyMedium(
                          'Set Visibility:',
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
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
                            const Text('Public'),
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
                            const Text('Private'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Padding(
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
                            minimumSize: const Size(120, 45),
                          ),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedFiles.isEmpty) {
                              showStolitySnack(context, "Please select files to upload");
                              return;
                            }

                            // Close promptly before starting upload
                            Navigator.of(context).pop('refresh');

                            await UploadController.uploadFilesOrFolder(
                              context,
                              selectedFiles,
                              "", // Empty folder path for individual files
                              _isPrivate,
                              (id, message) {
                                showStolitySnack(context, message);
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(120, 45),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
              
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
                const SizedBox(height: 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
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
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedFiles.isEmpty || selectedFolderPath.isEmpty) {
                            showStolitySnack(context, "Please select a folder to upload");
                            return;
                          }

                          // Close promptly before starting upload
                          Navigator.of(context).pop('refresh');

                          await UploadController.uploadFilesOrFolder(
                            context,
                            selectedFiles,
                            selectedFolderPath, // Pass the folder path here
                            _isPrivate,
                            (id, message) {
                              showStolitySnack(context, message);
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolderTab() {
    final TextEditingController folderNameController = TextEditingController();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Center(
                child: Text(
                  "Create Folder",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              
              CustomTextField(
                title: '',
                hintText: "Enter Folder Name",
                controller: folderNameController,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(120, 45),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final String foldername = folderNameController.text;
                      if (foldername.isEmpty) {
                        showStolitySnack(context, "Please enter a folder name");
                        return;
                      }
                      await FolderController.createFolder(context, foldername);
                      folderNameController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAB49),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(120, 45),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
