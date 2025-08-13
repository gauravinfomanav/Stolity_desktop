import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ResponsiveButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    double fieldWidth = screenWidth * 0.3;
    double fieldHeight = screenHeight * 0.05;

    // Clamping to safe limits
    fieldWidth = fieldWidth.clamp(250.0, 500.0);
    fieldHeight = fieldHeight.clamp(50.0, 70.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fieldWidth,
        height: fieldHeight,
        decoration: BoxDecoration(
          boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 231, 231, 231).withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 4, // changes position of shadow
          ),
        ],
          color: const Color(0xFFFFAB49),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: Constants.FONT_DEFAULT_NEW,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

