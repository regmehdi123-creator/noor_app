import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor/features/home/home_page.dart';
import 'package:noor/features/on_boarding/language_page.dart';
import 'package:noor/features/on_boarding/onboarding.dart';
import 'package:noor/features/signing/verify_email.dart';

import 'package:noor/features/signing/sign_in.dart';

class AppRoutes {
  static const String root = '/';
  static const String language = '/language';
  static const String home = '/home';
  static const String verifyEmail = '/verify-email';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';

  static List<GetPage> routes = [
    GetPage(
      name: language,
      page: () => const LanguageSelect(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: signIn,
      page: () => const SignIn(),
    ),
    GetPage(
      name: home,
      page: () => const Homepage(),
      middlewares: [StartMiddleware()],
    ),
    GetPage(
      name: verifyEmail,
      page: () => const VerifyEmailPage(),
    ),
  ];
}

class StartMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final prefs = Get.find<SharedPreferences>();
    
    // 1. Check Onboarding
    final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
    if (!onboardingSeen) {
      return const RouteSettings(name: AppRoutes.onboarding);
    }

    // 2. Check Language
    final String? lang = prefs.getString('lang');
    if (lang == null || lang.isEmpty) {
      return const RouteSettings(name: AppRoutes.language);
    }
    
    return null;
  }
}
