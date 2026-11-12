import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart' as geocode_lib;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:noor/data/data.dart';
import 'core.dart';
import 'functions.dart';

class PrayerController extends GetxController {
  final Rx<PrayerTimes?> prayerTimes = Rx<PrayerTimes?>(null);
  final RxString currentAddress = "جاري تحديد الموقع...".obs;
  final RxString hijriDate = "".obs;
  final RxString gregorianDate = "".obs;
  final RxString dayName = "".obs;
  final RxMap<String, bool> notifications = <String, bool>{}.obs;
  final RxBool isLoading = false.obs;
  final RxDouble prayerProgress = 0.0.obs;
  final RxString timeLeftText = "".obs;
  final RxString nextSalatName = "".obs;
  final Rx<Color> timeLeftColor = Colors.black.obs;
  
  final _prefs = Get.find<SharedPreferences>();
  
  @override
  void onInit() {
    super.onInit();
    HijriCalendar.setLocal('ar');
    _loadNotifications();
    _updateDates();
    recomputeStatuses();
    Timer.periodic(const Duration(seconds: 15), (timer) {
      _updateDates();
      recomputeStatuses(); 
    });
  }

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print("Starting app initialization...");
    await Future.delayed(const Duration(milliseconds: 800));

    // 1. Request All Permissions first
    await _requestPermissions();
    
    // 2. Init Notifications (Fixed crash by using ic_notification)
    await initNotifications();
    
    // 3. Load Location
    await _loadSavedLocation();
    
    // 4. Force status recompute
    recomputeStatuses();
    
    // 5. Initial Schedule
    await _scheduleDailyNotifications();
    
    // 6. Show status
    showTimeLeftNotification();
  }

  Future<void> _requestPermissions() async {
    print("Requesting permissions...");
    
    // Notification Permission
    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      notificationStatus = await Permission.notification.request();
    }
    
    // Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("الموقع معطل", "يرجى تفعيل GPS لتحديد مواقيت الصلاة بدقة.", 
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(onPressed: () => Geolocator.openLocationSettings(), child: const Text("تفعيل")));
    }
  }

  Future<void> _scheduleDailyNotifications() async {
    double? lat = _prefs.getDouble('latitude');
    double? lng = _prefs.getDouble('longitude');

    if (lat != null && lng != null) {
      await rescheduleMultiDayPrayerNotifications(
        prefs: _prefs,
        lat: lat,
        lng: lng,
      );
    }
  }

  void _loadNotifications() {
    for (var s in salats) {
      // Default to false for Adhan sound as requested
      notifications[s.id] = _prefs.getBool('adhan_${s.id}') ?? false;
    }
  }

  void toggleNotificationById(String salatId) {
    final current = notifications[salatId] ?? false;
    notifications[salatId] = !current;
    _prefs.setBool('adhan_$salatId', !current);
    _scheduleDailyNotifications(); // Reschedule to apply new sound settings
  }

  double getPrayerProgress() {
    return prayerProgress.value;
  }

  void _updateDates() {
    final now = DateTime.now();
    
    // Hijri Date
    final hijri = HijriCalendar.fromDate(now);
    hijriDate.value = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";
    
    // Gregorian Date
    gregorianDate.value = DateFormat('d MMMM yyyy', 'ar').format(now);
    
    // Day Name
    dayName.value = DateFormat('EEEE', 'ar').format(now);
    
    // Refresh prayer times if we have location
    if (prayerTimes.value != null) {
      _calculatePrayerTimes(
        prayerTimes.value!.coordinates.latitude,
        prayerTimes.value!.coordinates.longitude,
      );
      _updateSalatsList();
    }
    
    // Update progress and time left
    prayerProgress.value = _calculateProgress();
    _updateTimeLeft();
    nextSalatName.value = _getNextSalatName();
    _updateTimeLeft();
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    for (int i = 0; i < salats.length; i++) {
      if (salats[i].status == PrayerStatus.current) {
        final prayer = salats[i].time;
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

        Color color = Colors.black;
        if (hours > 0) {
          timeLeftText.value = "متبقي $hours ساعة و $minutes دقيقة";
        } else if (minutes > 0) {
          if (minutes <= 15) {
            color = Colors.red;
          }
          timeLeftText.value = "متبقي $minutes دقيقة";
        } else {
          color = Colors.red;
          timeLeftText.value = "الآن وقت الصلاة";
        }
        timeLeftColor.value = color;
        return;
      }
    }
    timeLeftText.value = "---";
    timeLeftColor.value = Colors.black;
  }

  String _getNextSalatName() {
    for (int i = 0; i < salats.length; i++) {
      if (salats[i].status == PrayerStatus.current) {
        return salats[i].name;
      }
    }
    return "";
  }

  void _updateSalatsList() {
    final pt = prayerTimes.value;
    if (pt == null) return;

    final isFriday = DateTime.now().weekday == DateTime.friday;
    final times = [pt.fajr, pt.sunrise, pt.dhuhr, pt.asr, pt.maghrib, pt.isha];
    
    for (int i = 0; i < salats.length && i < times.length; i++) {
      salats[i].time = TimeOfDay(hour: times[i].hour, minute: times[i].minute);
      
      // Dynamic name for Friday
      if (salats[i].id == 'dhuhr') {
        salats[i].name = isFriday ? 'الجمعة' : 'الظهر';
      }
    }
    recomputeStatuses();
    salats.refresh();
  }

  double _calculateProgress() {
    final pt = prayerTimes.value;
    if (pt == null) return 0.0;
    
    final now = DateTime.now();
    final coords = pt.coordinates;
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    // Get all times for today
    final fajr = pt.fajr;
    final sunrise = pt.sunrise;
    final dhuhr = pt.dhuhr;
    final asr = pt.asr;
    final maghrib = pt.maghrib;
    final isha = pt.isha;

    DateTime start, end;

    if (now.isBefore(fajr)) {
      final yesterday = now.subtract(const Duration(days: 1));
      final ptYesterday = PrayerTimes(coords, DateComponents.from(yesterday), params);
      start = ptYesterday.isha;
      end = fajr;
    } else if (now.isBefore(sunrise)) {
      start = fajr;
      end = sunrise;
    } else if (now.isBefore(dhuhr)) {
      start = sunrise;
      end = dhuhr;
    } else if (now.isBefore(asr)) {
      start = dhuhr;
      end = asr;
    } else if (now.isBefore(maghrib)) {
      start = asr;
      end = maghrib;
    } else if (now.isBefore(isha)) {
      start = maghrib;
      end = isha;
    } else {
      final tomorrow = now.add(const Duration(days: 1));
      final ptTomorrow = PrayerTimes(coords, DateComponents.from(tomorrow), params);
      start = isha;
      end = ptTomorrow.fajr;
    }

    final total = end.difference(start).inSeconds;
    final elapsed = now.difference(start).inSeconds;

    if (total <= 0) return 0.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Future<void> _loadSavedLocation() async {
    double? lat = _prefs.getDouble('latitude');
    double? lng = _prefs.getDouble('longitude');
    String? address = _prefs.getString('address');

    if (lat != null && lng != null) {
      currentAddress.value = address ?? "موقع محفوظ";
      _calculatePrayerTimes(lat, lng);
      prayerProgress.value = _calculateProgress();
    } else {
      await updateLocation();
    }
  }

  Future<void> updateLocation() async {
    if (isLoading.value) return;
    isLoading.value = true;
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoading.value = false;
        Get.snackbar("الموقع معطل", "يرجى تفعيل GPS لتحديد مواقيت الصلاة بدقة.", 
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(onPressed: () => Geolocator.openLocationSettings(), child: const Text("تفعيل")));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading.value = false;
          return;
        }
      }

      currentAddress.value = "جاري تحديد الموقع...";
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      try {
        final placemarks = await geocode_lib.Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          currentAddress.value = "${place.locality ?? place.subAdministrativeArea ?? ''}, ${place.country ?? ''}";
        }
      } catch (e) {
        currentAddress.value = "موقع مخصص (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})";
      }

      await _prefs.setDouble('latitude', position.latitude);
      await _prefs.setDouble('longitude', position.longitude);
      await _prefs.setString('address', currentAddress.value);

      _calculatePrayerTimes(position.latitude, position.longitude);
      await _scheduleDailyNotifications();
      prayerProgress.value = _calculateProgress();
      showTimeLeftNotification();
    } catch (e) {
      Get.snackbar("خطأ", "تعذر تحديد الموقع تلقائياً.");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculatePrayerTimes(double lat, double lng) {
    final myCoordinates = Coordinates(lat, lng);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    prayerTimes.value = PrayerTimes.today(myCoordinates, params);
  }

  String get nextPrayerId {
    final pt = prayerTimes.value;
    if (pt == null) return '';
    final next = pt.nextPrayer();
    if (next == Prayer.none) return 'fajr';
    switch (next) {
      case Prayer.fajr: return 'fajr';
      case Prayer.sunrise: return 'sunrise';
      case Prayer.dhuhr: return 'dhuhr';
      case Prayer.asr: return 'asr';
      case Prayer.maghrib: return 'maghrib';
      case Prayer.isha: return 'isha';
      default: return '';
    }
  }


  
  Duration? get timeToNextPrayer {
    final pt = prayerTimes.value;
    if (pt == null) return null;
    
    final now = DateTime.now();
    final next = pt.nextPrayer();
    
    if (next == Prayer.none) {
      final tomorrow = now.add(const Duration(days: 1));
      final coords = pt.coordinates;
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final ptTomorrow = PrayerTimes(coords, DateComponents.from(tomorrow), params);
      return ptTomorrow.fajr.difference(now);
    }
    
    final nextTime = pt.timeForPrayer(next);
    if (nextTime == null) return null;
    return nextTime.difference(now);
  }
}
