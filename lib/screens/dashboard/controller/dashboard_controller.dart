import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/screens/main_screen/main_screen.dart';

class DashboardController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final TextEditingController namecontroller = TextEditingController();

  Future<void> login(BuildContext context) async {
    final url = Uri.parse(Constants.login);

    final body = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var data = jsonDecode(response.body);

        
        String accessToken =
            data['accessToken']; 

        // Save the token and login status
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('accessToken', accessToken);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
          ),
        );
        Get.off(() => MainScreen());
      } else {
        print('Error!: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User Not Found.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  Future<void> signup(BuildContext context) async {
    final url = Uri.parse(Constants.register);

    final body = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'name': namecontroller.text.trim(),
      'confirmPassword': confirmpasswordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup successful!'),
          ),
        );
        Get.off(() => MainScreen());
      } else {
        print('Signup failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed. Please check your credentials.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    namecontroller.dispose();
  }
}
