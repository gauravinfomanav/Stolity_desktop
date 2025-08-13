import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';

class ButtonForDialog extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final Color pressedTextColor;
  final Color buttonColor;

  const ButtonForDialog({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.black,
    required this.pressedTextColor,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return pressedTextColor;
          }
          return textColor;
        }),
        
        
      ),
      onPressed: onPressed,
      child: Text(text,style: TextStyle(fontFamily: Constants.FONT_DEFAULT_NEW,fontSize: 16,fontWeight: FontWeight.w500),),
    );
  }
}
