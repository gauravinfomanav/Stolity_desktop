import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stolity_desktop_application/application_constants.dart';
import 'package:stolity_desktop_application/components/file_cell_gridview.dart';
import 'package:stolity_desktop_application/screens/dashboard/dashboard.dart';

import 'package:stolity_desktop_application/screens/main_screen/homescreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // or prefs.remove('isLoggedIn');
  Get.offAll(() => Dashboard());
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Container(
            width: 80,
            color: const Color(0xFFFDF8F4),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SvgPicture.asset(assetutils.stolity_logo_small),
                const SizedBox(height: 40),
                _buildSidebarItem(0, assetutils.home_icon),
                _buildSidebarItem(1, assetutils.user_icon),
                const Spacer(),
                _buildSidebarItem(2, assetutils.logout_icon),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Homescreen(),
          ),
        ],
      ),
    );
  }
Widget _buildSidebarItem(int index, String icon) {
  final isSelected = _selectedIndex == index;

  return GestureDetector(
    onTap: () {
      if (index == 2) {
        logout(); // Logout logic
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isSelected ? const Color.fromARGB(255, 247, 39, 39) : Colors.transparent,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                )
              ]
            : null,
      ),
      child: SvgPicture.asset(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        height: 25,
        width: 25,
      ),
    ),
  );
}

}


