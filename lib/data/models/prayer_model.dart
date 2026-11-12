import 'package:flutter/material.dart';

import 'package:noor/core/core.dart';


class PrayerTimeModel {
  final String id;
   String name; // pass the already-localized name, e.g. "العصر" or "Asr"
  TimeOfDay time;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  PrayerStatus status;
  bool adhanEnabled;

  PrayerTimeModel({
    required this.id,
    required this.name,
    required this.time,
    required this.icon,
    this.iconColor = const Color(0xFF1B7A6E),
    this.iconBackgroundColor = const Color(0xFFE3F3EC),
    this.status = PrayerStatus.upcoming,
    this.adhanEnabled = false,
  });

  /// "3:45" style formatting (12h, no AM/PM) to match the design. Pass
  /// use24h: true for a "15:45" style instead.

}