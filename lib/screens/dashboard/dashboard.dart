import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stolity_desktop_application/screens/dashboard/imagetextoverlay.dart';
import 'package:stolity_desktop_application/screens/dashboard/login_container.dart';
import 'package:stolity_desktop_application/screens/dashboard/signupcontainer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  
  bool showLogin = true;

  
  void toggleAuthScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFFFFE7C6),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Content container
          Positioned(
           top: showLogin ? screenHeight * 0.15 : screenHeight * 0.1,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 950;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isSmallScreen)
                      Expanded(
                        flex: 5,
                        child: ImageWithTextOverlay(),
                      ),
                    if (!isSmallScreen) SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      flex: isSmallScreen ? 1 : 4,
                      child: Center(
                        child: showLogin 
                            ? Login_conatiner(
                                signUpTapCallback: toggleAuthScreen,
                              )
                            : signup_conatiner(
                                loginTapCallback: toggleAuthScreen,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}