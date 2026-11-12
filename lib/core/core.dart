import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:get/get.dart';
import 'package:noor/features/home/adkar_page.dart';
import 'package:noor/features/home/hokm_page.dart';
import 'package:noor/features/home/misbaha_page.dart';
import 'package:noor/features/home/prayer_page.dart';
import 'package:noor/features/home/quibla_page.dart';
import 'package:noor/features/home/quran_page.dart';

List<Map<String, dynamic>> pages = [
  {
    "title": "الأذان",
    "subtitle": "مواقيت الصلاة",
    "icon": FlutterIslamicIcons.community,
    "press": () {
      Get.to(const PrayerTimesScreen());
    }
  },
  {
    "title": "المصحف",
    "subtitle": "قراءة القرآن الكريم",
    "icon": FlutterIslamicIcons.quran2,
    "press": () {
      Get.to(const QuranPage());
    }
  },
  {
    "title": "الأدعية والأذكار",
    "subtitle": "حصن المسلم",
    "icon": FlutterIslamicIcons.solidTasbih2,
    "press": () {
      Get.to(const AdkarPage());
    }
  },
  {
    "title": "المسبحة",
    "subtitle": "عداد التسبيح",
    "icon": FlutterIslamicIcons.tasbih3,
    "press": () {
      Get.to(const MisbahaPage());
    }
  },
  {
    "title": "اتجاه القبلة",
    "subtitle": "تحديد اتجاه القبلة",
    "icon": FlutterIslamicIcons.qibla,
    "press": () {
      Get.to(const QiblahScreen());
    }
  },
  {
    "title": "الأحكام",
    "subtitle": "فتاوى شرعية",
    "icon": Icons.gavel_rounded,
    "press": () {
      Get.to(const HokmPage());
    }
  }
];

const Map<PrayerStatus, String> prayerStatusLabels = {
  PrayerStatus.upcoming: 'قادمة',
  PrayerStatus.current: 'حالية',
  PrayerStatus.passed: 'انقضت',
};
const List<String> adkar = [
  'سبحان الله',
  'أستغفر الله',
  'سبحان الله وبحمده',
  'الله أكبر',
  'لا إله إلا الله',
  'الحمد لله',
];

enum PrayerStatus { passed, current, upcoming }
 final int nextPrayerNotificationId=999;
