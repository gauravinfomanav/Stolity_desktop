import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';
import 'package:stolity_desktop_application/dialogs/stolity_alert_prompt.dart';
import 'package:stolity_desktop_application/screens/open_file/controller.dart';

class FileCell extends StatelessWidget {
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

  const FileCell({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.dateModified,
    required this.fileType,
    this.onTap,
    this.isSelected = false,
    this.onSelect,
    this.fileIcon,
    this.onDelete,
    this.fileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
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
            const SizedBox(width: 12),
            buildFileIcon(fileIcon!),
            const SizedBox(width: 12),
            Expanded(
              flex: 8,
              child: Text(
                fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                fileSize,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                dateModified,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              offset: const Offset(-40, 10),
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    _handleRename(context, fileName, fileSize, dateModified);
                    break;
                  case 'delete':
                    _handleDelete(context);
                    break;
                  case 'download':
                    final keyOrUrl = (fileUrl != null && fileUrl!.isNotEmpty)
                        ? fileUrl!
                        : fileName;
                    FileOpenController().backgroundDownloadByKey(context, keyOrUrl);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                const PopupMenuItem<String>(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(CupertinoIcons.square_pencil),
                    title: Text('Rename'),
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
          ],
        ),
      ),
    );
  }

  Widget buildFileIcon(String fileIcon) {
    if (fileIcon.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        fileIcon,
        width: 32,
        height: 32,
        placeholderBuilder: (context) =>
            CircularProgressIndicator(strokeWidth: 1),
      );
    } else {
      return Image.network(
        fileIcon,
        width: 32,
        height: 32,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
      );
    }
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
      positiveButtonColor: Colors.orange,


      onNegativePressed: () => Navigator.pop(context, false),
      onPositivePressed: () => Navigator.pop(context, true),
    );

    if (shouldDelete != true) return;

    FileModel file = FileModel(
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      uploadDateTime: dateModified,
      url: '',
      isFolder: false,
      icon: fileIcon ?? '',
    );

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
        onDelete!(fileName); // Pass fileName to remove locally
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
