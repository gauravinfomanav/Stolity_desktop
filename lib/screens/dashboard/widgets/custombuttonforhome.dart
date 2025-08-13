import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomButtonForHome extends StatefulWidget {
  final VoidCallback onTap;
  final String text; 
  final String? svgIconPath; 
  final Color iconColor;
  final Color textColor; 
  final Color borderColor; 
  final Color activeBorderColor; 
  final Color buttonColor; 
  final Color activeButtonColor;
  final double borderRadius; 
  final double iconSize; 
  final EdgeInsets padding; 
  final double fontSize; 
  final FontWeight fontWeight; 

  const CustomButtonForHome({
    super.key,
    required this.onTap,
    required this.text,
    this.svgIconPath, 
    this.iconColor = Colors.black54,
    this.textColor = Colors.black87,
    this.borderColor = const Color(0xFFECB390), 
    this.activeBorderColor = Colors.orange, 
    this.buttonColor = const Color.fromARGB(255, 255, 153, 0), 
    this.activeButtonColor = const Color(0xFFFFE0B2), 
    this.borderRadius = 20.0, 
    this.iconSize = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 14.0, 
    this.fontWeight = FontWeight.w500, 
  });

  @override
  State<CustomButtonForHome> createState() => _CustomButtonForHomeState();
}

class _CustomButtonForHomeState extends State<CustomButtonForHome> {
  bool _isTapped = false;

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });
    widget.onTap();

    // Revert the tap effect after 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isTapped = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _isTapped ? widget.activeButtonColor : widget.buttonColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isTapped ? widget.activeBorderColor : widget.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.svgIconPath != null) ...[
              SvgPicture.asset(
                widget.svgIconPath!,
                width: widget.iconSize,
                height: widget.iconSize,
                colorFilter: ColorFilter.mode(
                  widget.iconColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
                fontWeight: widget.fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}