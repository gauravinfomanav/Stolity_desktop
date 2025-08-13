import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/components/set_visiblity.dart';
import 'package:stolity_desktop_application/dialogs/download_from_url/buttons.dart';
import 'package:stolity_desktop_application/dialogs/download_from_url/controller.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/textfeilds.dart';

class DownloadFromUrlScreen extends StatefulWidget {
  const DownloadFromUrlScreen({Key? key}) : super(key: key);

  @override
  State<DownloadFromUrlScreen> createState() => _DownloadFromUrlScreenState();
}

class _DownloadFromUrlScreenState extends State<DownloadFromUrlScreen> {
  TextEditingController urlController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
          child: Text(
        'Download File From URL',
        style: TextStyle(
            fontFamily: Constants.FONT_DEFAULT_NEW,
            fontWeight: FontWeight.w500),
      )),
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: urlController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                fileNameController.text =
                    DownloadFromUrlController.extractFileNameFromUrl(value);
              }
            },
            title: "File URL",
          ),
          SizedBox(height: Get.height * 0.02),
          CustomTextField(
            controller: fileNameController,
            title: "File Name",
          ),
          SizedBox(height: Get.height * 0.04),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     // TextButton(
          //     //   onPressed: () => Navigator.pop(context),
          //     //   child: Text('Close'),
          //     // ),
          //      ElevatedButton(
          //       onPressed: () {
          //         String url = urlController.text.trim();
          //         String name = fileNameController.text.trim();

          //         if (url.isNotEmpty && name.isNotEmpty) {
          //           DownloadFromUrlController.downloadFileFromUrl(
          //               context, url, name);
          //           Navigator.pop(context);
          //         } else {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             SnackBar(content: Text('Please fill both fields')),
          //           );
          //         }
          //       },
          //       child: Text('Submit'),
          //     ),
          //     SizedBox(width: 20),
          //     ElevatedButton(
          //       onPressed: () {
          //         String url = urlController.text.trim();
          //         String name = fileNameController.text.trim();

          //         if (url.isNotEmpty && name.isNotEmpty) {
          //           DownloadFromUrlController.downloadFileFromUrl(
          //               context, url, name);
          //           Navigator.pop(context);
          //         } else {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             SnackBar(content: Text('Please fill both fields')),
          //           );
          //         }
          //       },
          //       child: Text('Submit'),
          //     ),
          //   ],
          // ),

           VisibilitySelector(
             isForDownload: true,
           ),
          SizedBox(height: Get.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: Text('Close'),
              // ),
              //  ElevatedButton(
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.all(Colors.grey),
              //   ),
              //   onPressed: () => Navigator.pop(context),
              //   child: Text('Cancel'),
              // ),
              ButtonForDialog(
                text: "Cancel",
                onPressed: () => Navigator.pop(context),
                buttonColor: Colors.grey.shade100,
                pressedTextColor: Colors.transparent,
                textColor: Colors.grey,
              ),
              SizedBox(width: 20),
              ButtonForDialog(
                text: "Submit",
                onPressed: () {
                  String url = urlController.text.trim();
                  String name = fileNameController.text.trim();

                  if (url.isNotEmpty && name.isNotEmpty) {
                    DownloadFromUrlController.downloadFileFromUrl(
                        context, url, name);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill both fields')),
                    );
                  }
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
