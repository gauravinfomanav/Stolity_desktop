import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/autotextsize.dart';

class ImageWithTextOverlay extends StatefulWidget {
  const ImageWithTextOverlay({super.key});

  @override
  State<ImageWithTextOverlay> createState() => _ImageWithTextOverlayState();
}

class _ImageWithTextOverlayState extends State<ImageWithTextOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  final List<Map<String, String>> _contentList = [
    {
      'heading': 'Upload Files',
      'subtitle':
          'Store upto 5GB data in a centralised location for easy access and management',
    },
    {
      'heading': 'Fast Access',
      'subtitle':
          'Experience quicker uploads for every file type — faster, smoother, better.',
    },
    {
      'heading': 'Generate Link',
      'subtitle':
          'Generate Links and shorten then for efficient sharing of files.',
    },
    {
      'heading': 'Genrate QR Code',
      'subtitle':
          'Generate and Scan the QR code to Download all Files with one click.',
    },
    {
      'heading': 'Share Securely',
      'subtitle': 'Securely share files to multiple people from any location.',
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _animations = List.generate(
      _contentList.length - 1,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / (_contentList.length - 1),
            (index + 1) / (_contentList.length - 1),
            curve: Curves.linear,
          ),
        ),
      ),
    );

    for (int i = 0; i < _animations.length; i++) {
      _animations[i].addListener(() {
        if (_animations[i].value > 0.5 && _currentIndex != i + 1) {
          setState(() {
            _currentIndex = i + 1;
          });
        }
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Loop the animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = 0; // Reset to first title
        });
        _controller.reset();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _controller.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed container with animated text content
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: screenHeight * 0.11,
              width: screenWidth * 0.25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
            ),

            // Rotated square at bottom (fixed)
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

            // Text content that animates
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: screenHeight * 0.11,
              width: screenWidth * 0.25,
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  key: ValueKey<int>(_currentIndex),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    MusaffaAutoSizeText.displayExtraLarge(
                      _contentList[_currentIndex]['heading']!,
                      color: Color(0xFFE94545),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    MusaffaAutoSizeText.titleMediumSmall(
                      _contentList[_currentIndex]['subtitle']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      color: Color(0xFF7C7C7C),
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: screenHeight * 0.05),

        SizedBox(
          width: screenWidth * 0.50,
          height: screenHeight * 0.55,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SvgPicture.asset(
              'resources/images/dashboard_image.svg',
            ),
          ),
        ),
      ],
    );
  }
}