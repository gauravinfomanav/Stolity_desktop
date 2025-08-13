import 'package:flutter/material.dart';

class Constants {
  static const FONT_DEFAULT_NEW = "Poppins";
  static const String domainName = "filesapi.infomanav.in/prod/api/aws";
  static const String baseUrl = "https://$domainName/";

  static const Getfiles = "${baseUrl}getAllObjectsNew?limit=1000";
  static const filterbynameasc = "${baseUrl}get-all-files?ascending=true";
  static const filterbynamedesc = "${baseUrl}get-all-files?ascending=false";
  static const filterbysizeasc = "${baseUrl}get-all-files?sortSize=true";
  static const filterysizedesc = "${baseUrl}get-all-files?sortSize=false";
  static const filterbydateasc = "${baseUrl}get-all-files?sortByDate=asc";
  static const filterbydatedesc = "${baseUrl}get-all-files?sortByDate=desc";
  static const filterbytype = "${baseUrl}get-all-files?fileTypes=";
  static const searchfile = "${baseUrl}search-file?searchFile=";
  static const deletefile = "${baseUrl}delete-file";
  static const deletefolder = "${baseUrl}delete-folder";
  static const downloadfromurl = "${baseUrl}download-file-bucket";
  static const uploadfile = "${baseUrl}create-folder";
  static const getuploadurl = "https://filesapi.infomanav.in/prod/api/aws/upload-file";
  static const uploadfolder = "${baseUrl}upload-folder";
  static const getfiledata = "${baseUrl}getFile?filePath=";
  static const downloadFileByKey = "https://filesapi.infomanav.in/prod/api/aws/download-file?key=";
  static const login = "${baseUrl}login-user";
  static const register = "${baseUrl}create-user";

  static double stolityIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    double size = (width + height) * 0.02;

    return size.clamp(30.0, 100.0);
  }



  static const double gridSpacing = 16.0;
  static const double gridItemMinWidth = 150.0;
  static const double gridItemAspectRatio = 1.1;
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const Color shadowColor = Color(0x1A000000); 
  static const Color checkboxColor = Color(0xFFFFAB49);
  static const TextStyle fileNameStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  static const TextStyle metaStyle = TextStyle(
    color: Colors.grey,
    fontSize: 12,
  );
}
