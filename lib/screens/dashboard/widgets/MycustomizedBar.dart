import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/application_constants.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';
import 'package:stolity_desktop_application/dialogs/download_from_url/dialog.dart';
import 'package:stolity_desktop_application/dialogs/upload_files/dialog.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/custom_sort_filter_button.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/custombuttonforhome.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/searchbar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyCustomizedBar extends StatefulWidget {
  final Function(String)? onSortSelected;
  final Function(List<String>)? onFileTypeSelected;
  final Function(int)? onViewToggle;
  final Function(List<FileModel>, String)? onSearchResults;
  final VoidCallback? onRefreshRequested;

  const MyCustomizedBar({
    super.key,
    this.onViewToggle,
    this.onSortSelected,
    this.onFileTypeSelected,
    this.onSearchResults,
    this.onRefreshRequested,
  });

  @override
  State<MyCustomizedBar> createState() => _MyCustomizedBarState();
}

class _MyCustomizedBarState extends State<MyCustomizedBar> {
  int switchValue = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: MySearchBar(
                onSearchResults: widget.onSearchResults,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, rightConstraints) {
                  final double rightWidth = rightConstraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: rightWidth),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ToggleSwitch(
                            minWidth: 48,
                            minHeight: 36,
                            animate: true,
                            animationDuration: 100,
                            cornerRadius: 250.0,
                            activeBgColors: [
                              [Color(0xffFFAB49)],
                              [Color(0xffFFAB49)]
                            ],
                            activeFgColor: Colors.white,
                            inactiveBgColor: Color(0xFFFDF8F4),
                            inactiveFgColor: Color(0xffADB0B7),
                            initialLabelIndex: switchValue,
                            totalSwitches: 2,
                            iconSize: 18,
                            borderWidth: 1,
                            borderColor: [
                              Color(0xFFFFEFE1),
                              Color(0xFFFFEFE1),
                            ],
                            icons: [
                              Icons.menu,
                              Icons.grid_view,
                            ],
                            radiusStyle: true,
                            onToggle: (index) {
                              setState(() {
                                if (index != null) {
                                  switchValue = index;
                                  if (widget.onViewToggle != null) {
                                    widget.onViewToggle!(switchValue);
                                  }
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          CustomFilterButton(
                            mode: FilterButtonMode.sort,
                            label: "By Name (A-Z)",
                            sortOptions: const [
                              "By Name (A-Z)",
                              "By Name (Z-A)",
                              "By Size (Ascending)",
                              "By Size (Descending)",
                              "By Date (Oldest)",
                              "By Date (Newest)",
                            ],
                            onSortSelected: (value) {
                              print("Sort selected: $value");
                              if (widget.onSortSelected != null) {
                                widget.onSortSelected!(value);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          CustomFilterButton(
                            mode: FilterButtonMode.fileType,
                            label: "File Type",
                            onFileTypesSelected: (fileTypes) {
                              print("File types selected: $fileTypes");
                              if (widget.onFileTypeSelected != null) {
                                widget.onFileTypeSelected!(fileTypes);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          CustomButtonForHome(
                              onTap: () {},
                              text: "Create Folder",
                              svgIconPath: assetutils.create_folder_icon,
                              buttonColor: Colors.white),
                          const SizedBox(width: 12),
                          // CustomButtonForHome(
                          //   onTap: () {
                          //     showDialog(
                          //       context: context,
                          //       builder: (context) => DownloadFromUrlScreen(),
                          //     );
                          //   },
                          //   text: "Download From Url",
                          //   svgIconPath: assetutils.download_from_urlIcon,
                          //   buttonColor: Color(0xFFFFC895),
                          //   borderColor: Colors.transparent,
                          // ),
                          CustomButtonForHome(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => FileUploadDialog(),
                              ).then((value) {
                                if (value == 'refresh' && widget.onRefreshRequested != null) {
                                  widget.onRefreshRequested!();
                                }
                              });
                            },
                            text: "Upload Files",
                            svgIconPath: assetutils.upload_file_icon,
                            buttonColor: Color(0xFFFFAB49),
                            borderColor: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}