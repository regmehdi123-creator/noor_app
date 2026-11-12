import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noor/data/data.dart';
import 'package:noor/core/core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> rescheduleMultiDayPrayerNotifications({
  required SharedPreferences prefs,
  required double lat,
  required double lng,
  int daysToSchedule = 30,
}) async {
  await notificationsPlugin.cancelAll();

  final myCoordinates = Coordinates(lat, lng);
  final params = CalculationMethod.muslim_world_league.getParameters();
  params.madhab = Madhab.shafi;

  final now = DateTime.now();
  final salatIds = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
  final salatNames = {
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  int notificationId = 1;

  for (int dayOffset = 0; dayOffset < daysToSchedule; dayOffset++) {
    final targetDate = now.add(Duration(days: dayOffset));
    final pt = PrayerTimes(myCoordinates, DateComponents.from(targetDate), params);

    final prayers = {
      'fajr': pt.fajr,
      'sunrise': pt.sunrise,
      'dhuhr': pt.dhuhr,
      'asr': pt.asr,
      'maghrib': pt.maghrib,
      'isha': pt.isha,
    };

    int prayerIndexInDay = 1;

    for (var idKey in salatIds) {
      final time = prayers[idKey]!;
      if (time.isBefore(now)) continue;

      final bool playAdhan = prefs.getBool('adhan_$idKey') ?? false;
      final String salatName = salatNames[idKey] ?? idKey;

      final int mainAlertId = notificationId++;

      await schedulePrayerNotifications(
        prayerTime: time,
        title: 'حان الآن وقت صلاة $salatName 🤲',
        id: mainAlertId,
        playAdhan: playAdhan,
      );

      // Status countdown logic for today
      if (dayOffset == 0) {
        final reminderTime = time.subtract(const Duration(minutes: 15));
        final int statusId = 1000 + prayerIndexInDay;
        prayerIndexInDay++;

        if (reminderTime.isAfter(now)) {
          await scheduleNextPrayerCountdown(
            id: statusId,
            reminderTime: reminderTime,
            prayerTime: time,
            prayerName: salatName,
          );
        }
        await schedulePrayerAfterNotification(
          id: statusId,
          prayerTime: time,
          prayerName: salatName,
        );
      }
    }
  }
}

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  print("Initializing Notifications...");
  try {
    tz.initializeTimeZones();
    // Try to set local timezone, fallback to Algiers if it fails
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Algiers'));
    } catch (e) {
      print("Timezone error: $e");
    }
  } catch (e) {
    print("TZ init error: $e");
  }
  
  const androidSettings = AndroidInitializationSettings('ic_notification');
  const iosSettings = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notification tapped: ${response.payload}");
    },
  );

  print("Requesting notification permissions...");
  // Use permission_handler to EXPLICITLY request permission
  PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }

  final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  await androidPlugin?.requestExactAlarmsPermission();
}

void recomputeStatuses() {
  print("Recomputing statuses...");
  final now = TimeOfDay.now();
  final nowMinutes = now.hour * 60 + now.minute;
  int? nextIndex;

  for (var i = 0; i < salats.length; i++) {
    final minutes = salats[i].time.hour * 60 + salats[i].time.minute;
    if (minutes > nowMinutes) {
      nextIndex = i;
      break;
    }
  }

  final targetIndex = nextIndex ?? 0;

  for (var i = 0; i < salats.length; i++) {
    if (i == targetIndex) {
      salats[i].status = PrayerStatus.current;
    } else if (nextIndex != null && i > nextIndex) {
      salats[i].status = PrayerStatus.upcoming;
    } else {
      salats[i].status = PrayerStatus.passed;
    }
  }
}


// --- Centralized Notification Style ---
NotificationDetails _getNoorNotificationStyle({
  required String channelId,
  required String channelName,
  bool ongoing = false,
  Importance importance = Importance.max,
  Priority priority = Priority.high,
  bool showCountdown = false,
  DateTime? prayerTime,
  String? soundFile,
}) {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      ongoing: ongoing,
      showWhen: true,
      onlyAlertOnce: true,
      color: const Color(0xFF0D7E5E), // Noor Green
      largeIcon: const DrawableResourceAndroidBitmap('ic_large_logo'), // Full color logo
      usesChronometer: showCountdown || (prayerTime != null),
      chronometerCountDown: showCountdown,
      when: prayerTime?.millisecondsSinceEpoch,
      playSound: soundFile != null,
      sound: soundFile != null ? RawResourceAndroidNotificationSound(soundFile) : null,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: soundFile != null,
      sound: soundFile != null ? '$soundFile.caf' : null,
    ),
  );
}

Future<void> showInstantNotification({
  required int id,
  required String title,
  required String body,
}) async {
  await notificationsPlugin.show(
    id,
    title,
    body,
    _getNoorNotificationStyle(
      channelId: 'prayer_status_channel',
      channelName: 'حالة الصلاة',
      ongoing: true,
    ),
  );
}

Future<void> schedulePrayerNotifications({
  required DateTime prayerTime,
  required String title,
  required int id,
  bool playAdhan = false,
}) async {
  final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
  if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

  await notificationsPlugin.zonedSchedule(
    id,
    '🕌  وقت الصلاة',
    title,
    scheduledDate,
    _getNoorNotificationStyle(
      channelId: playAdhan ? 'adhan_channel' : 'prayer_notification_channel_id',
      channelName: playAdhan ? 'الأذان' : 'Prayer Notifications',
      soundFile: playAdhan ? 'adan' : null,
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> scheduleNextPrayerCountdown({
  required int id,
  required DateTime reminderTime,
  required DateTime prayerTime,
  required String prayerName,
}) async {
  final reminderDate = tz.TZDateTime.from(reminderTime, tz.local);
  if (reminderDate.isBefore(tz.TZDateTime.now(tz.local))) return;

  await notificationsPlugin.zonedSchedule(
    id,
    '🕌 الصلاة القادمة: $prayerName',
    'سيتم رفع الأذان قريباً',
    reminderDate,
    _getNoorNotificationStyle(
      channelId: 'prayer_status_channel',
      channelName: 'حالة الصلاة',
      importance: Importance.low,
      priority: Priority.low,
      showCountdown: true,
      prayerTime: prayerTime,
      ongoing: true,
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> showTimeLeftNotification() async {
  final timeLeft = getTimeLeftString();
  if (timeLeft.isEmpty) return;

  await showInstantNotification(
    id: 999,
    title: 'تطبيق نور',
    body: timeLeft,
  );
}

Future<void> schedulePrayerAfterNotification({
  required int id,
  required DateTime prayerTime,
  required String prayerName,
}) async {
  final prayerDate = tz.TZDateTime.from(prayerTime, tz.local);
  if (prayerDate.isBefore(tz.TZDateTime.now(tz.local))) return;

  await notificationsPlugin.zonedSchedule(
    id,
    '🕌 صلاة $prayerName',
    'مضى وقت من دخول الصلاة',
    prayerDate,
    _getNoorNotificationStyle(
      channelId: 'prayer_status_channel',
      channelName: 'حالة الصلاة',
      importance: Importance.low,
      priority: Priority.low,
      prayerTime: prayerTime,
      ongoing: true,
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

String getTimeLeftString() {
  final now = DateTime.now();

  for (int i = 0; i < salats.length; i++) {
    if (salats[i].status == PrayerStatus.current) {
      final prayer = salats[i].time;
      final salatName = salats[i].name; // جلب اسم الصلاة

      DateTime nextPrayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayer.hour,
        prayer.minute,
      );

      if (nextPrayerTime.isBefore(now)) {
        nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
      }

      final difference = nextPrayerTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return "متبقي على صلاة $salatName $hours ساعة و $minutes دقيقة";
      } else if (minutes > 0) {
        return "متبقي على صلاة $salatName $minutes دقيقة";
      } else {
        return "الآن وقت صلاة $salatName";
      }
    }
  }
  return "";
}

