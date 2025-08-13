import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';

class UpperContainer extends StatelessWidget {
  final String heading;
  final String subtitle;

  const UpperContainer({
    super.key,
    required this.heading,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    var textScaleFactor = TextScaler.linear(1);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
       
        Positioned(
          bottom: 0,
          child: Transform.rotate(
            angle: 3.1416 / 4, 
            child: Container(
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
        ),

        
        Container(
          margin: const EdgeInsets.only(bottom: 10), 
          height: screenHeight * 0.11,
          width: screenWidth * 0.25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                heading,
                textScaler: TextScaler.linear(1),
                style: const TextStyle(
                  fontFamily: Constants.FONT_DEFAULT_NEW,
                  color: Color(0xFFE94545),
                  fontWeight: FontWeight.w500,
                  fontSize: 27,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textScaler: TextScaler.linear(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: Constants.FONT_DEFAULT_NEW,
                  color: Color(0xFF7C7C7C),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
