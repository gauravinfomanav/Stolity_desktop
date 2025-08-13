import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialCircleButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialCircleButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive size
    double size = (screenWidth + screenHeight) * 0.02;
    size = size.clamp(20.0, 50.0);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          iconPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
