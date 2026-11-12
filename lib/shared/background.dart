import 'package:flutter/material.dart';
import 'package:noor/core/colors.dart';
import 'package:flutter/services.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: cream, // Changed from Colors.white
        statusBarIconBrightness: Brightness.dark, // Black icons
        statusBarBrightness: Brightness.light,    // For iOS (dark icons)
        systemNavigationBarColor: cream, // Changed from Colors.white
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Remove extendBodyBehindAppBar to keep status bar area separate/white
        extendBodyBehindAppBar: false, 
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 380,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [mainColor, mainColorLight],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // Decorative element
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}