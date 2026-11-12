import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:get/get.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/core/core.dart';
import 'package:noor/core/prayer_controller.dart';
import 'package:noor/data/data.dart';
import 'package:noor/features/home/setting.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/shared/widget/gold_container.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrayerController>();

    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Header ---


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.to(() => const SettingPage()),
                    icon: const Icon(Icons.settings_outlined, size: 28, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "تطبيق نور",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'السلام عليكم ورحمة الله',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- Prayer Card ---
              Obx(() {
                final pt = controller.prayerTimes.value;
                if (pt == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TimeOfDay.fromDateTime(DateTime.now()).format(context),
                                style: const TextStyle(color: mainColor, fontSize: 34, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                controller.timeLeftText.value,
                                style: TextStyle(
                                  color: controller.timeLeftColor.value,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: mainColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("الصلاة القادمة", style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(
                                      controller.nextSalatName.value,
                                      style: const TextStyle(color: secondColorLight, fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                const Icon(FlutterIslamicIcons.sajadah, size: 30, color: mainColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 70,
                            child: Divider(
                              height: 40,
                              thickness: 3,
                              color: mainColor,
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Divider(
                              height: 40,
                              thickness: 3,
                              color: secondColor,
                            ),
                          ),
                        ],
                      ),

                      // Quick dots for prayers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: salats.map((s) {
                          final isNext = controller.nextPrayerId == s.id;
                          return Column(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: isNext ? mainColor : Colors.grey.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isNext ? mainColor : Colors.grey,
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 30),
              const GoldContainer(title: 'آية اليوم', dalile: '﴿ وَقُل رَّبِّ زِدۡنِی عِلۡمࣰا ﴾', source: 'سورة طه - آية 114',),
              const SizedBox(height: 30),

              // --- Grid Menu ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 18, mainAxisSpacing: 18, crossAxisCount: 2, childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  Color pageColor = index % 2 == 0 ? mainColor : secondColor;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: pages[index]["press"],
                        borderRadius: BorderRadius.circular(25),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: pageColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                                child: Icon(pages[index]["icon"], size: 36, color: pageColor),
                              ),
                              const SizedBox(height: 12),
                              Text(pages[index]["title"], textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(pages[index]["subtitle"], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
