import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/screens/dashboard/controller/dashboard_controller.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/button.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/socials_button.dart';
import 'package:stolity_desktop_application/screens/dashboard/widgets/textfeilds.dart';

class signup_conatiner extends StatefulWidget {
  final VoidCallback? loginTapCallback;
  const signup_conatiner({super.key, this.loginTapCallback});

  @override
  State<signup_conatiner> createState() => _signup_conatinerState();
}

class _signup_conatinerState extends State<signup_conatiner> {
  final DashboardController controller = DashboardController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validateFields() {
    bool isValid = true;
    setState(() {
      
      if (controller.namecontroller.text.isEmpty) {
        _nameError = 'Full Name is required';
        isValid = false;
      } else {
        _nameError = null;
      }

      
      if (controller.emailController.text.isEmpty) {
        _emailError = 'Email is required';
        isValid = false;
      } else if (!_isValidEmail(controller.emailController.text)) {
        _emailError = 'Please enter a valid email';
        isValid = false;
      } else {
        _emailError = null;
      }

      
      if (controller.passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
        isValid = false;
      } else {
        _passwordError = null;
      }

      
      if (controller.confirmpasswordController.text.isEmpty) {
        _confirmPasswordError = 'Confirm Password is required';
        isValid = false;
      } else if (controller.confirmpasswordController.text != controller.passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
        isValid = false;
      } else {
        _confirmPasswordError = null;
      }
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.33,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Get.height * 0.02),
            SvgPicture.asset(
              "resources/images/stolity_logo.svg",
              height: Constants.stolityIconSize(context),
              width: Constants.stolityIconSize(context),
            ),
            SizedBox(height: Get.height * 0.02),
            Text(
              "Create an account",
              style: TextStyle(
                fontFamily: Constants.FONT_DEFAULT_NEW,
                fontSize: 28,
                color: Color(0xFF222222),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              controller: controller.namecontroller,
              title: "Full Name",
              errorText: _nameError,
              onChanged: (value) {
                if (_nameError != null) {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
            ),
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              controller: controller.emailController,
              title: "Email Address",
              errorText: _emailError,
              onChanged: (value) {
                if (_emailError != null) {
                  setState(() {
                    _emailError = null;
                  });
                }
              },
            ),
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              controller: controller.passwordController,
              isPasswordField: true,
              title: "Password",
              errorText: _passwordError,
              onChanged: (value) {
                if (_passwordError != null) {
                  setState(() {
                    _passwordError = null;
                  });
                }
              },
            ),
            SizedBox(height: Get.height * 0.02),
            CustomTextField(
              controller: controller.confirmpasswordController,
              isPasswordField: true,
              title: "Confirm Password",
              errorText: _confirmPasswordError,
              onChanged: (value) {
                if (_confirmPasswordError != null) {
                  setState(() {
                    _confirmPasswordError = null;
                  });
                }
              },
            ),
            SizedBox(height: Get.height * 0.02),
            ResponsiveButton(
              text: "Sign up",
              onTap: () {
                if (_validateFields()) {
                  controller.signup(context);
                }
              },
            ),
            SizedBox(height: Get.height * 0.02),
            GestureDetector(
              onTap: widget.loginTapCallback,
              child: RichText(
                text: TextSpan(
                  text: "Already have an account ? ",
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 1,
                    color: const Color(0xFF7C7C7C),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'OR',
                  style: TextStyle(
                    color: const Color(0xFF7C7C7C),
                    fontFamily: Constants.FONT_DEFAULT_NEW,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    height: 1,
                    color: const Color(0xFF7C7C7C),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
            SocialCircleButton(
              iconPath: "resources/images/google_icon.svg",
              onPressed: () {},
            ),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
      ),
    );
  }
}