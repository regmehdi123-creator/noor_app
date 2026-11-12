import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/adkar_model.dart';
import 'models/prayer_model.dart';

RxList<PrayerTimeModel> salats = <PrayerTimeModel>[
  PrayerTimeModel(
    id: 'fajr',
    name: 'الفجر',
    time:  TimeOfDay(hour: 4, minute: 30),
    icon: Icons.wb_twilight_rounded,
    iconColor: const Color(0xFF52657A),
    iconBackgroundColor: const Color(0xFFEFF6EF),
  ),
  PrayerTimeModel(
    id: 'sunrise',
    name: 'الشروق',
    time:  TimeOfDay(hour: 6, minute: 0),
    icon: Icons.wb_sunny_outlined,
    iconColor: const Color(0xFFE0A63C),
    iconBackgroundColor: const Color(0xFFEFF6EF),
  ),
  PrayerTimeModel(
    id: 'dhuhr',
    name: 'الظهر',
    time:  TimeOfDay(hour: 12, minute: 15),
    icon: Icons.wb_sunny_rounded,
    iconColor: const Color(0xFFE0A63C),
    iconBackgroundColor: const Color(0xFFEFF6EF),
  ),
PrayerTimeModel(
id: 'asr',
name: 'العصر',
time:  TimeOfDay(hour: 15, minute: 45),
icon: Icons.wb_cloudy_rounded,
iconColor: const Color(0xFFE0A63C),
iconBackgroundColor: const Color(0xFFEFF6EF),
),
PrayerTimeModel(
id: 'maghrib',
name: 'المغرب',
time: const TimeOfDay(hour: 18, minute: 15),
icon: Icons.wb_twilight_rounded,
iconColor: const Color(0xFFD16A3E),
iconBackgroundColor: const Color(0xFFEFF6EF),
),
PrayerTimeModel(
id: 'isha',
name: 'العشاء',
time: const TimeOfDay(hour: 19, minute: 45),
icon: Icons.nightlight_round,
iconColor: const Color(0xFF2E3A4F),
iconBackgroundColor: const Color(0xFFEFF6EF),
),
].obs;
final List<AdkarCategory> adkarCategories = [
  AdkarCategory(
    title: "أذكار الصباح",
    icon: "🌅",
    color: const Color(0xFFFF9800),
    adkar: [
      AdkarModel(text: "أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له", targetCount: 1),
      AdkarModel(text: "اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور", targetCount: 1),
      AdkarModel(text: "سُبْحَانَ اللهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ", targetCount: 3),
      AdkarModel(text: "يا حي يا قيوم برحمتك أستغيث أصلح لي شأني كله ولا تكلني إلى نفسي طرفة عين", targetCount: 1),
      AdkarModel(text: "اللهم إني أسألك علماً نافعاً، ورزقاً طيباً، وعملاً متقبلاً", targetCount: 1),
      AdkarModel(text: "أستغفر الله وأتوب إليه", targetCount: 100),
      AdkarModel(text: "سبحان الله وبحمده", targetCount: 100),
    ],
  ),
  AdkarCategory(
    title: "أذكار المساء",
    icon: "🌙",
    color: const Color(0xFF7C2CFF),
    adkar: [
      AdkarModel(text: "أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له", targetCount: 1),
      AdkarModel(text: "اللهم بك أمسينا، وبك أصبحنا، وبك نحيا، وبك نموت، وإليك المصير", targetCount: 1),
      AdkarModel(text: "اللهم ما أمسى بي من نعمة أو بأحد من خلقك فمنك وحدك لا شريك لك", targetCount: 1),
      AdkarModel(text: "أعوذ بكلمات الله التامات من شر ما خلق", targetCount: 3),
      AdkarModel(text: "سبحان الله وبحمده", targetCount: 100),
    ],
  ),
  AdkarCategory(
    title: "أذكار بعد الصلاة",
    icon: "🕌",
    color: const Color(0xFF00B894),
    adkar: [
      AdkarModel(text: "أستغفر الله", targetCount: 3),
      AdkarModel(text: "اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام", targetCount: 1),
      AdkarModel(text: "سبحان الله", targetCount: 33),
      AdkarModel(text: "الحمد لله", targetCount: 33),
      AdkarModel(text: "الله أكبر", targetCount: 33),
      AdkarModel(text: "لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير", targetCount: 1),
    ],
  ),
  AdkarCategory(
    title: "أذكار النوم",
    icon: "🌃",
    color: const Color(0xFF2196F3),
    adkar: [
      AdkarModel(text: "باسمك اللهم أموت وأحيا", targetCount: 1),
      AdkarModel(text: "سورة الإخلاص والمعوذتين", targetCount: 3),
      AdkarModel(text: "آية الكرسي", targetCount: 1),
      AdkarModel(text: "باسمك ربي وضعت جنبي، وبك أرفعه", targetCount: 1),
    ],
  ),
  AdkarCategory(
    title: "أدعية قرآنية",
    icon: "📖",
    color: const Color(0xFFFFA000),
    adkar: [
      AdkarModel(text: "ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار", targetCount: 1),
      AdkarModel(text: "رب اجعلني مقيم الصلاة ومن ذريتي ربنا وتقبل دعاء", targetCount: 1),
      AdkarModel(text: "ربنا لا تزغ قلوبنا بعد إذ هديتنا وهب لنا من لدنك رحمة", targetCount: 1),
    ],
  ),
  AdkarCategory(
    title: "تسابيح",
    icon: "📿",
    color: const Color(0xFFFF0F63),
    adkar: [
      AdkarModel(text: "سبحان الله وبحمده، سبحان الله العظيم", targetCount: 100),
      AdkarModel(text: "لا حول ولا قوة إلا بالله", targetCount: 100),
      AdkarModel(text: "اللهم صل وسلم على نبينا محمد", targetCount: 10),
    ],
  ),
];
final time = TimeOfDay.now();