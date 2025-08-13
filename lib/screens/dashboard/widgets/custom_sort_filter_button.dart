import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/autotextsize.dart';

enum FilterButtonMode { sort, fileType }

class CustomFilterButton extends StatefulWidget {
  final FilterButtonMode mode;
  final String label;
  final List<String> sortOptions;
  final Function(String)? onSortSelected;
  final Function(List<String>)? onFileTypesSelected;

  const CustomFilterButton({
    super.key,
    required this.mode,
    required this.label,
    this.sortOptions = const [],
    this.onSortSelected,
    this.onFileTypesSelected,
  });

  @override
  State<CustomFilterButton> createState() => _CustomFilterButtonState();
}

class _CustomFilterButtonState extends State<CustomFilterButton> {
  String currentLabel = '';
  List<String> selectedFileTypes = [];
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    currentLabel = widget.label;
  }

  void _showFileTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFFEFE1), width: 1),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MusaffaAutoSizeText.titleLarge(
                            "File Type Filter",
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          splashRadius: 18,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MusaffaAutoSizeText.bodyMedium(
                      "Select the file types you want to filter by:",
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    _buildFileTypeGrid(context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            foregroundColor: Colors.black87,
                            backgroundColor: const Color(0xFFFDF8F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFFFEFE1), width: 1),
                            ),
                          ),
                          child: MusaffaAutoSizeText.labelMedium(
                            "Cancel",
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            if (widget.onFileTypesSelected != null) {
                              widget.onFileTypesSelected!(selectedFileTypes);
                            }
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            backgroundColor: const Color(0xFFFFAB49),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: MusaffaAutoSizeText.labelMedium(
                            "Apply Filter",
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileTypeGrid(BuildContext context) {
    final fileTypes = [
      ["PDF", "JPG", "JPEG", "PNG"],
      ["MOV", "MP3", "MP4"],
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        final types = fileTypes.expand((row) => row).toList();
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: types
              .map((type) => _buildFileTypeChip(context, setState, type))
              .toList(),
        );
      },
    );
  }

  Widget _buildFileTypeChip(
      BuildContext context, StateSetter setState, String type) {
    final lowercaseType = type.toLowerCase();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: ChoiceChip(
        label: Text(
          type,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selectedFileTypes.contains(lowercaseType)
                ? Colors.white
                : Colors.black87,
          ),
        ),
        selected: selectedFileTypes.contains(lowercaseType),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              selectedFileTypes.add(lowercaseType);
            } else {
              selectedFileTypes.remove(lowercaseType);
            }
          });
        },
        selectedColor: const Color(0xFFFFAB49),
        backgroundColor: const Color(0xFFFDF8F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFEFE1), width: 1),
        ),
      ),
    );
  }

  void _showSortDropdown(BuildContext context) {
    // Get the button's size and position
    final RenderBox button =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonSize = button.size;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    // Calculate the position for the dropdown
    final position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + buttonSize.height,
      buttonPosition.dx + buttonSize.width,
      buttonPosition.dy + buttonSize.height,
    );

    showMenu<String>(
      color: Colors.white,
      context: context,
      position: position,
      constraints: BoxConstraints(
        minWidth: buttonSize.width,
        maxWidth: buttonSize.width,
      ),
      items: widget.sortOptions.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: MusaffaAutoSizeText.bodyMedium(option, color: Colors.black87),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          currentLabel = value;
        });
        if (widget.onSortSelected != null) {
          widget.onSortSelected!(value);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.mode == FilterButtonMode.sort
        ? GestureDetector(
            onTap: () => _showSortDropdown(context),
            child: Container(
              key: _buttonKey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFFDF8F4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFFFFEFE1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_double_arrow_down_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  MusaffaAutoSizeText.bodyMedium(
                    currentLabel,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () => _showFileTypeDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFFDF8F4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 224, 194, 125).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  MusaffaAutoSizeText.bodyMedium(
                    widget.label,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          );
  }
}
