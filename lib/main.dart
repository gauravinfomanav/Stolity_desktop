import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stolity_desktop_application/screens/dashboard/dashboard.dart';
import 'package:stolity_desktop_application/screens/main_screen/main_screen.dart';
import 'package:window_size/window_size.dart';
import 'package:http/http.dart' as http;
import 'package:stolity_desktop_application/components/app_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(700, 900));
    setWindowMaxSize(Size.infinite);
  }
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
  ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? MainScreen() : Dashboard(),
    );
  }
}
