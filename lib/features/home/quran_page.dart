import 'package:flutter/material.dart';
import 'package:quran_library/quran.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RepaintBoundary(
        child: QuranLibraryScreen(
          parentContext: context,
          isDark: false,
          showAyahBookmarkedIcon: true,
          ayahIconColor: const Color(0xffcdad80),
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
      ),
    );
  }
}