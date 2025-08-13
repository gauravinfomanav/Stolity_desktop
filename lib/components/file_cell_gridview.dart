import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';
import 'package:stolity_desktop_application/dialogs/stolity_alert_prompt.dart';
import 'package:stolity_desktop_application/screens/open_file/controller.dart';

class FileGridCell extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String dateModified;
  final String fileType;
  final VoidCallback? onTap;
  final bool isSelected;
  final Function(bool)? onSelect;
  final String? fileIcon;
  final Function(String)? onDelete;
  final String? fileUrl;

  const FileGridCell({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.dateModified,
    required this.fileType,
    this.onTap,
    this.isSelected = false,
    this.onSelect,
    this.fileIcon,
    this.onDelete, // Added to constructor
    this.fileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 170, 165, 165).withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: fileIcon != null
                            ? SvgPicture.network(
                                fileIcon!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.insert_drive_file,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, top: 12, right: 16, bottom: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileSize,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              dateModified,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 12,
                left: 8,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (onSelect != null && value != null) {
                      onSelect!(value);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: const Color(0xFFFFAB49),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon:
                      const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                  offset: const Offset(-10, 50),
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _handleRename(
                            context, fileName, fileSize, dateModified);
                        break;
                      case 'delete':
                        _handleDelete(context);
                        break;
                      case 'download':
                        final key = (fileUrl != null && fileUrl!.isNotEmpty)
                            ? Uri.parse(fileUrl!).path.substring(1)
                            : fileName;
                        FileOpenController().backgroundDownloadByKey(context, key);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: $fileSize, Modified: $dateModified',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(CupertinoIcons.square_pencil),
                    title: const Text('Rename'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'download',
                  child: ListTile(
                    leading: Icon(Icons.download_rounded),
                    title: Text('Download', style: TextStyle(fontFamily: Constants.FONT_DEFAULT_NEW, fontSize: 12, color: Colors.black)),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(CupertinoIcons.delete),
                    title: Text('Delete',style: TextStyle(fontFamily: Constants.FONT_DEFAULT_NEW,fontSize: 12,color: Colors.black),),
                    
                  ),
                ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRename(BuildContext context, String fileName, String fileSize,
      String dateModified) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Renaming $fileName (Size: $fileSize, Modified: $dateModified)')),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    bool? shouldDelete = await StolityPrompt.show(
      context: context,
      title: 'Confirm Delete',
      subtitle:
          'Are you sure you want to delete $fileName? This action cannot be undone.',
      negativeButtonText: 'Cancel',
      positiveButtonText: 'Delete',
      onNegativePressed: () => Navigator.pop(context, false),
      onPositivePressed: () => Navigator.pop(context, true),
    );

    if (shouldDelete != true) return;

    // Create a FileModel instance for deletion
    FileModel file = FileModel(
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      uploadDateTime: dateModified,
      url: '', // Adjust based on your implementation
      isFolder: false,
      icon: fileIcon ?? '',
    );

    // Call UserController to perform deletion
    UserController userController = UserController();
    bool success = await userController.deleteFiles(context, [file]);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      if (onDelete != null) {
        onDelete!(fileName); // Notify parent widget to remove the file locally
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete $fileName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
