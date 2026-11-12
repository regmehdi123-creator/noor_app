import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/features/on_boarding/onboarding.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/shared/widget/language_select_card.dart';
import '../../core/langue_controller.dart';


class LanguageSelect extends StatelessWidget{
   const LanguageSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LangueController>();

    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 100),
          Lottie.asset("assets/lottie/Ramadanlesen.json"),
          const SizedBox(height: 5),
          LanguageSelectCard(
            title: "English",
            subtitle: "الإنجليزية",
            press: () => controller.setLangue('en'),
            lang: 'en',
          ),
          const SizedBox(height: 22),
          LanguageSelectCard(
            title: "العربية",
            subtitle: "Arabic",
            press: () => controller.setLangue('ar'),
            lang: 'ar-sa',
          ),
        ],
      ),
    );
  }

}