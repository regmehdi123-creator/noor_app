import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/core/prayer_controller.dart';
import 'package:noor/data/data.dart';
import 'package:noor/data/models/prayer_model.dart';
import 'package:noor/shared/background.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrayerController>();

    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          "مواقيت الصلاة",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "أوقات دقيقة حسب موقعك",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.2,
                          ),
                        )
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 28, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- Location Card ---
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () => controller.updateLocation(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            controller.currentAddress.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.location_on_rounded, color: mainColor, size: 24),
                      ],
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 20),

              // --- Date Card ---
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.dayName.value,
                        style: const TextStyle(
                          color: mainColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(height: 2, width: 60, color: Colors.grey[200]),
                      const SizedBox(height: 12),
                      Text(
                        controller.gregorianDate.value,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(height: 1, width: 60, color: Colors.grey[200]),
                      const SizedBox(height: 4),
                      Text(
                        controller.hijriDate.value,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: secondColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 20),

              // --- Prayer List ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() {
                  if (controller.prayerTimes.value == null) return const Center(child: CircularProgressIndicator());
                  
                  return Column(
                    children: salats.map((salat) => _buildPrayerItem(controller, salat)).toList(),
                  );
                }),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerItem(PrayerController controller, PrayerTimeModel salat) {
    final nextPrayerName = controller.nextPrayerId; // We need a way to get ID of next prayer
    final isNext = nextPrayerName == salat.id;

    // Color Logic
    final bgColor = isNext ? mainColor : Colors.white;
    final contentColor = isNext ? Colors.white : Colors.black87;
    final subColor = isNext ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Time & Notification
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${salat.time.hourOfPeriod}:${salat.time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Obx(() {
                            final isAdhan = controller.notifications[salat.id] ?? false;
                            return Icon(
                              isAdhan ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              size: 18,
                              color: isNext ? Colors.white70 : mainColor.withValues(alpha: 0.7),
                            );
                          }),
                          const SizedBox(width: 4),
                          Obx(() {
                            final isAdhan = controller.notifications[salat.id] ?? false;
                            return SizedBox(
                              height: 20,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: isAdhan,
                                  onChanged: (_) => controller.toggleNotificationById(salat.id),
                                  activeThumbColor: isNext ? Colors.white : mainColor,
                                  activeTrackColor: isNext ? Colors.white30 : mainColor.withValues(alpha: 0.2),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 2),
                          Obx(() {
                            final isAdhan = controller.notifications[salat.id] ?? false;
                            return Text(
                              isAdhan ? "الأذان" : "صامت",
                              style: TextStyle(
                                fontSize: 10,
                                color: subColor,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right: Name & Icon
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              salat.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                            ),
                            if (isNext && controller.timeToNextPrayer != null)
                              Text(
                                "بعد ${controller.timeToNextPrayer!.inHours} س و ${controller.timeToNextPrayer!.inMinutes % 60} د",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.right,
                              )
                            else
                              Text(
                                _isPast(salat.time) ? "فائتة" : "قادمة",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isNext ? Colors.white.withValues(alpha: 0.2) : salat.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          salat.icon,
                          color: isNext ? Colors.white : salat.iconColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isNext)
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white24, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(controller.getPrayerProgress() * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const Text(
                        "الوقت المتبقي",
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.getPrayerProgress(),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  bool _isPast(TimeOfDay prayerTime) {
    final now = TimeOfDay.now();
    if (now.hour > prayerTime.hour) return true;
    if (now.hour == prayerTime.hour && now.minute >= prayerTime.minute) return true;
    return false;
  }
}
