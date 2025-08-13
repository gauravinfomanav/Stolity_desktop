import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/components/file_cell.dart';
import 'package:stolity_desktop_application/components/file_cell_gridview.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';
import 'package:stolity_desktop_application/dialogs/stolity_alert_prompt.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/MycustomizedBar.dart';
import 'package:stolity_desktop_application/screens/open_file/controller.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<List<FileModel>> _futureFiles;
  final List<String> _selectedFileNames = [];
  List<String> _selectedFileTypes = [];
  String _currentSortOption = "";
  int _viewMode = 0;
  final FileOpenController _fileopencontroller = FileOpenController();
  final UserController _userController = UserController();
  List<FileModel> _searchResults = [];
  String _currentSearchQuery = "";
  List<FileModel> _allFiles = [];

  @override
  void initState() {
    super.initState();
    _futureFiles = _loadFiles();
  }

  Future<List<FileModel>> _loadFiles({
    String sortOption = "",
    List<String> fileTypes = const [],
  }) async {
    try {
      final userController = UserController();
      List<FileModel> files;

       if (fileTypes.isNotEmpty) {
      print('Loading files with types: $fileTypes');
      files = await userController.getFilesByFileTypes(context, fileTypes);
    } else if (sortOption.isNotEmpty) {
      print('Loading files with sort: $sortOption');
      files = await userController.getFilesWithSorting(context, sortOption);
    } else {
      print('Loading all files');
      files = await userController.getFiles(context);
    }


      _allFiles = files;
      print('Loaded files: ${files.map((f) => f.fileName).toList()}');
      return files;
    } catch (e) {
      print('Error loading files: $e');
      return [];
    }
  }

  void refreshFiles() {
  setState(() {
    
    _currentSortOption = "";
    _selectedFileTypes = [];
    _futureFiles = _loadFiles();
  });
}

void _refreshWithSort(String sortOption) {
  setState(() {
    _currentSortOption = sortOption;
    
    _futureFiles = _loadFiles(sortOption: sortOption);
  });
}

void _refreshWithFileTypes(List<String> fileTypes) {
  setState(() {
    _selectedFileTypes = fileTypes;
    print('Refreshing with file types: $fileTypes');
    // Only pass the file types, not sort option
    _futureFiles = _loadFiles(fileTypes: fileTypes);
  });
}

  void _toggleFileSelection(String fileName, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedFileNames.add(fileName);
      } else {
        _selectedFileNames.remove(fileName);
      }
    });
  }

  void _onViewToggle(int viewMode) {
    setState(() {
      _viewMode = viewMode;
    });
  }

  void _onSearchResults(List<FileModel> results, String query) {
    setState(() {
      _searchResults = results;
      _currentSearchQuery = query;
      if (query.isNotEmpty) {
        _allFiles = results;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFileNames.clear();
    });
  }

  // Modified method to toggle between select all and deselect all
  void _toggleSelectAll() {
    setState(() {
      List<FileModel> currentFiles =
          _currentSearchQuery.isNotEmpty ? _searchResults : _allFiles;

      // Check if all files are currently selected
      bool allSelected = currentFiles
          .every((file) => _selectedFileNames.contains(file.fileName));

      if (allSelected) {
        // If all are selected, deselect all and close the bar
        _selectedFileNames.clear();
      } else {
        // If not all are selected, select all
        _selectedFileNames.clear();
        _selectedFileNames.addAll(currentFiles.map((file) => file.fileName));
      }
    });
  }

  // Helper method to check if all files are selected
  bool _areAllFilesSelected() {
    List<FileModel> currentFiles =
        _currentSearchQuery.isNotEmpty ? _searchResults : _allFiles;

    if (currentFiles.isEmpty) return false;

    return currentFiles
        .every((file) => _selectedFileNames.contains(file.fileName));
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFileNames.isEmpty) return;

    bool? shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting files...'),
              ],
            ),
          );
        },
      );

      List<FileModel> currentFiles =
          _currentSearchQuery.isNotEmpty ? _searchResults : _allFiles;
      List<FileModel> filesToDelete = currentFiles
          .where((file) => _selectedFileNames.contains(file.fileName))
          .toList();

      bool success = await _userController.deleteFiles(context, filesToDelete);

      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${filesToDelete.length} files deleted successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
        _clearSelection();
        refreshFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Some files could not be deleted'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting files: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return await StolityPrompt.show(
      context: context,
      title: 'Confirm Delete',
      subtitle:
          'Are you sure you want to delete ${_selectedFileNames.length} selected files? This action cannot be undone.',
      negativeButtonText: 'Cancel',
      positiveButtonText: 'Delete',
      positiveButtonColor: Colors.orange,
      positiveButtonTextColor: Colors.white,
      onNegativePressed: () => Navigator.pop(context, false),
      onPositivePressed: () => Navigator.pop(context, true),
    );
  }

  void _handleFileDeletion(String fileName) {
    setState(() {
      // Remove from _allFiles and _searchResults
      _allFiles.removeWhere((file) => file.fileName == fileName);
      _searchResults.removeWhere((file) => file.fileName == fileName);
      _selectedFileNames.remove(fileName); // Clear selection if any
    });
    // Refresh from server in background
    refreshFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _currentSearchQuery.isNotEmpty
                    ? "Search Results for '$_currentSearchQuery'"
                    : "Recent Uploads",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF344054),
                  fontFamily: Constants.FONT_DEFAULT_NEW,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        MyCustomizedBar(
          onSortSelected: _refreshWithSort,
          onFileTypeSelected: _refreshWithFileTypes,
          onViewToggle: _onViewToggle,
          onSearchResults: _onSearchResults,
          onRefreshRequested: refreshFiles,
        ),
        const SizedBox(height: 10),
        if (_selectedFileNames.isNotEmpty)
          Container(
            height: Get.height * 0.05,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 250, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                      tooltip: 'Clear selection',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${_selectedFileNames.length} Selected",
                      style: TextStyle(
                        fontFamily: Constants.FONT_DEFAULT_NEW,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleSelectAll,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 246, 198, 143),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.all(4),
                        child: Text(
                          _areAllFilesSelected()
                              ? "Deselect All"
                              : "Select All",
                          style: TextStyle(
                            fontFamily: Constants.FONT_DEFAULT_NEW,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: _deleteSelectedFiles,
                    child: Icon(
                      CupertinoIcons.trash,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedFileNames.isNotEmpty) const SizedBox(height: 10),
        Expanded(
          child: _currentSearchQuery.isNotEmpty
              ? _searchResults.isEmpty
                  ? const Center(child: Text('No files found.'))
                  : _viewMode == 0
                      ? ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final file = _searchResults[index];
                            return FileCell(
                              fileName: file.fileName,
                              fileSize: file.fileSize,
                              fileIcon: file.icon,
                              dateModified: file.uploadDateTime,
                              fileType: file.fileType,
                              isSelected:
                                  _selectedFileNames.contains(file.fileName),
                              onTap: () {
                                _fileopencontroller.fetchAndOpenFile(
                                    context, file.fileName);
                              },
                              onSelect: (selected) {
                                _toggleFileSelection(file.fileName, selected);
                              },
                              onDelete: _handleFileDeletion,
                            );
                          },
                        )
                      : ResponsiveFileGrid(
                          files: _searchResults
                              .map((file) => FileGridCell(
                                    fileName: file.fileName,
                                    fileSize: file.fileSize,
                                    fileIcon: file.icon,
                                    dateModified: file.uploadDateTime,
                                    fileType: file.fileType,
                                    isSelected: _selectedFileNames
                                        .contains(file.fileName),
                                    onTap: () {
                                      _fileopencontroller.fetchAndOpenFile(
                                          context, file.fileName);
                                    },
                                    onSelect: (selected) {
                                      _toggleFileSelection(
                                          file.fileName, selected);
                                    },
                                  ))
                              .toList(),
                          key: const Key('responsive_file_grid'),
                        )
              : FutureBuilder<List<FileModel>>(
                  future: _futureFiles,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No files found.'));
                    } else {
                      final files = snapshot.data!;
                      return _viewMode == 0
                          ? ListView.builder(
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                final file = files[index];
                                return FileCell(
                                  fileName: file.fileName,
                                  fileSize: file.fileSize,
                                  fileIcon: file.icon,
                                  dateModified: file.uploadDateTime,
                                  fileType: file.fileType,
                                  isSelected: _selectedFileNames
                                      .contains(file.fileName),
                                  onTap: () {
                                    _fileopencontroller.fetchAndOpenFile(
                                        context, file.fileName);
                                  },
                                  onSelect: (selected) {
                                    _toggleFileSelection(
                                        file.fileName, selected);
                                  },
                                  onDelete: _handleFileDeletion,
                                );
                              },
                            )
                          : ResponsiveFileGrid(
                              files: files
                                  .map((file) => FileGridCell(
                                        fileName: file.fileName,
                                        fileSize: file.fileSize,
                                        fileIcon: file.icon,
                                        dateModified: file.uploadDateTime,
                                        fileType: file.fileType,
                                        isSelected: _selectedFileNames
                                            .contains(file.fileName),
                                        onTap: () {
                                          _fileopencontroller.fetchAndOpenFile(
                                              context, file.fileName);
                                        },
                                        onSelect: (selected) {
                                          _toggleFileSelection(
                                              file.fileName, selected);
                                        },
                                      ))
                                  .toList(),
                              key: const Key('responsive_file_grid'),
                            );
                    }
                  },
                ),
        ),
      ]),
    );
  }
}

class ResponsiveFileGrid extends StatelessWidget {
  final List<FileGridCell> files;

  const ResponsiveFileGrid({Key? key, required this.files}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double minCardWidth = 220;
    const double cardHeight = 220;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / minCardWidth).floor();
        crossAxisCount = crossAxisCount.clamp(2, 10);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: minCardWidth,
              height: cardHeight,
              child: files[index],
            );
          },
        );
      },
    );
  }
}
