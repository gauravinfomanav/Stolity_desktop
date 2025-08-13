import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final String? errorText;
  final bool isPasswordField;
  final IconData? icon;
  final Color borderColor;
  final double borderRadius;
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.title,
    this.errorText,
    this.isPasswordField = false,
    this.icon,
    this.borderColor = const Color(0xFFD2D5DA),
    this.borderRadius = 8,
    this.controller,
    this.hintText,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive width and height
    double fieldWidth = screenWidth * 0.3;
    double fieldHeight = screenHeight * 0.055;

    fieldWidth = fieldWidth.clamp(250.0, 500.0);
    fieldHeight = fieldHeight.clamp(40.0, 60.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF6D7280),
          ),
        ),
        const SizedBox(height: 4),

        // Field
        Container(
          height: fieldHeight,
          width: fieldWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.errorText != null ? Colors.red : widget.borderColor,
            ),
          ),
          child: Center(
              child: TextField(
            controller: widget.controller,
            obscureText: widget.isPasswordField ? _obscureText : false,
            onChanged: widget.onChanged, 
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
              suffixIcon: widget.isPasswordField
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.icon != null
                      ? Icon(widget.icon, color: Colors.grey)
                      : null,
            ),
          )),
        ),

        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
