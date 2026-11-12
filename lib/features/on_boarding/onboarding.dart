import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:get/get.dart';
import 'package:noor/core/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  int currentPage = 0;

  // ... (pages list remains same)
  final List<OnboardingData> pages = [
    OnboardingData(
      title: 'القرآن الكريم',
      description: 'اقرأ القرآن الكريم وتدبر آياته واحصل على أجر كبير',
      icon: FlutterIslamicIcons.quran2,
      color: const Color(0xFF007D63),
    ),
    OnboardingData(
      title: 'مواقيت الصلاة',
      description: 'تعرف على مواقيت الصلاة بدقة وتابع صوت الأذان',
      icon:FlutterIslamicIcons.takbir,
      color: const Color(0xFFD0A619),
    ),
    OnboardingData(
      title: 'الأذكار والأدعية',
      description: 'تطبيقك اليومي لكل ما تحتاجه في رحلتك الإيمانية',
      icon: FlutterIslamicIcons.prayingPerson,
      color: const Color(0xFF007D63),
    ),
  ];

  Future<void> _completeOnboarding() async {
    await _prefs.setBool('onboarding_seen', true);
    Get.offAllNamed(AppRoutes.language);
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void skip() {
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              // Background decorations
              const _BackgroundDecorations(),

              Column(
                children: [
                  // ==================================================
                  // ONLY THIS PART SCROLLS
                  // ==================================================
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _ScrollableContent(
                          data: pages[index],
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // FIXED BOTTOM SECTION
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 14,
                    ),
                    child: Row(
                      children: [
                        // Skip
                        TextButton(
                          onPressed: skip,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(45, 35),
                          ),
                          child: const Text(
                            'تخطي',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Page indicators
                        _PageIndicator(
                          currentPage: currentPage,
                          totalPages: pages.length,
                          activeColor: pages[currentPage].color,
                        ),

                        const Spacer(),

                        // Next button
                        _NextButton(
                          color: pages[currentPage].color,
                          isLast: currentPage == pages.length - 1,
                          onPressed: nextPage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SCROLLABLE CONTENT
// ================================================================

class _ScrollableContent extends StatelessWidget {
  final OnboardingData data;

  const _ScrollableContent({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          const Spacer(flex: 3),
          // Icon with smoother layered circles
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.color.withValues(alpha: 0.1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.color.withValues(alpha: 0.2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.color,
                        boxShadow: [
                          BoxShadow(
                            color: data.color.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          // Animated Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3436),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Color(0xFF636E72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(flex: 5),
        ],
      ),
    );
  }
}


// ================================================================
// NEXT BUTTON
// ================================================================

class _NextButton extends StatelessWidget {
  final Color color;
  final bool isLast;
  final VoidCallback onPressed;

  const _NextButton({
    required this.color,
    required this.isLast,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'ابدأ الآن' : 'التالي',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (!isLast) ...[
                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PAGE INDICATOR
// ================================================================

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages,
            (index) {
          final bool active = index == currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 21 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? activeColor
                  : const Color(0xFFE2E2DE),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// BACKGROUND DECORATIONS
// ================================================================

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -65,
            child: _Circle(
              size: 180,
            ),
          ),

          Positioned(
            top: 150,
            left: -75,
            child: _Circle(
              size: 280,
            ),
          ),

          Positioned(
            top: 145,
            right: -55,
            child: _Circle(
              size: 170,
            ),
          ),

          Positioned(
            bottom: -75,
            left: -65,
            child: _Circle(
              size: 190,
            ),
          ),

          Positioned(
            bottom: -100,
            right: -90,
            child: _Circle(
              size: 300,
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;

  const _Circle({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE9ECE6),
          width: 1.7,
        ),
      ),
    );
  }
}

// ================================================================
// DATA
// ================================================================

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}