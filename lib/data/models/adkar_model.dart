import 'dart:ui';

class AdkarCategory {
  final String title;
  final String icon;
  final Color color;
  final List<AdkarModel> adkar;

  const AdkarCategory({
    required this.title,
    required this.icon,
    required this.color, required this.adkar,
  });
}

class AdkarModel {
  final String text;
  final int targetCount;
  int currentCount;

  AdkarModel({
    required this.text,
    required this.targetCount,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= targetCount;
}