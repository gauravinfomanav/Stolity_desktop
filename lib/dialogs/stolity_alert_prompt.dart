import 'package:flutter/material.dart';

class StolityPrompt extends StatelessWidget {
  final String title;
  final String subtitle;
  final String negativeButtonText;
  final String positiveButtonText;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;
  final Color? positiveButtonColor;
  final Color? positiveButtonTextColor;
  final Color? negativeButtonTextColor;
  const StolityPrompt({
    Key? key,
    required this.title,
    required this.subtitle,
    this.negativeButtonText = "No",
    this.positiveButtonText = "Yes",
    this.onNegativePressed,
    this.onPositivePressed,
    this.positiveButtonColor = Colors.orange, // Orange color from image
    this.positiveButtonTextColor = Colors.white,
    this.negativeButtonTextColor = const Color(0xFF666666),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Buttons Row
                Row(
                  children: [
                    // Negative Button
                    Expanded(
                      child: TextButton(
                        onPressed: onNegativePressed ?? () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          negativeButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: negativeButtonTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Positive Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPositivePressed ?? () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: positiveButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          positiveButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: positiveButtonTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Static method to show the dialog easily
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    String negativeButtonText = "No",
    String positiveButtonText = "Yes",
    VoidCallback? onNegativePressed,
    VoidCallback? onPositivePressed,
    Color? positiveButtonColor = const Color(0xFFE6A853),
    Color? positiveButtonTextColor = Colors.white,
    Color? negativeButtonTextColor = const Color(0xFF666666),
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return StolityPrompt(
          title: title,
          subtitle: subtitle,
          negativeButtonText: negativeButtonText,
          positiveButtonText: positiveButtonText,
          onNegativePressed: onNegativePressed,
          onPositivePressed: onPositivePressed,
          positiveButtonColor: positiveButtonColor,
          positiveButtonTextColor: positiveButtonTextColor,
          negativeButtonTextColor: negativeButtonTextColor,
        );
      },
    );
  }
}