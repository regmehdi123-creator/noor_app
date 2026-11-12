import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/auth_controller.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/core/langue_controller.dart';
import 'package:noor/core/prayer_controller.dart';
import 'package:noor/features/signing/sign_in.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/core/app_routes.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final LangueController languageController = Get.find<LangueController>();

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 25),
          _buildProfileSection(),
          const SizedBox(height: 25),
          _buildSectionTitle("الإعدادات العامة"),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: "اللغة",
              subtitle: "تغيير لغة التطبيق",
              trailing: Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageController.lang.value == 'ar' ? "العربية" : "English", 
                    style: const TextStyle(color: Colors.grey)
                  ),
                  const Icon(Icons.swap_horiz, size: 16, color: Colors.grey),
                ],
              )),
              onTap: () => languageController.toggleLanguage(),
            ),
            const Divider(height: 1, indent: 50),
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              title: "الموقع",
              subtitle: "تحديث موقع مواقيت الصلاة",
              trailing: Obx(() {
                final controller = Get.find<PrayerController>();
                return controller.isLoading.value 
                    ? const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: mainColor),
                      )
                    : const Icon(Icons.refresh, size: 18, color: mainColor);
              }),
              onTap: () async {
                final controller = Get.find<PrayerController>();
                if (!controller.isLoading.value) {
                  await controller.updateLocation();
                }
              },
            ),
            const Divider(height: 1, indent: 50),
            _buildSettingItem(
              icon: Icons.notifications_none_outlined,
              title: "الإشعارات",
              subtitle: "إدارة التنبيهات والإشعارات",
              trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 25),
          _buildSectionTitle("حول التطبيق"),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.info_outline,
              title: "عن التطبيق",
              subtitle: "معلومات عن المصحف الشريف",
              trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 50),
            _buildSettingItem(
              icon: Icons.verified_outlined,
              title: "الإصدار",
              subtitle: "إصدار التطبيق الحالي",
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        const Text(
          "الإعدادات",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 48), // Spacer for balance
      ],
    );
  }

  Widget _buildProfileSection() {
    final authController = AuthController.instance;
    final user = authController.firebaseUser;
    final isGuest = user == null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: isGuest
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("زائر", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("سجل دخولك لحفظ بياناتك", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const SignIn()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text("تسجيل الدخول", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(user.displayName ?? "مستخدم التطبيق", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(user.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      TextButton(
                        onPressed: () => authController.logout(),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                        child: const Text("تسجيل الخروج", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: mainColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(isGuest ? Icons.person_add_outlined : Icons.person_outline, color: mainColor, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: mainColor, size: 24),
      ),
      leading: trailing,
      title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, textAlign: TextAlign.right, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: mainColor, shape: BoxShape.circle),
          child: const Icon(Icons.star, color: secondColorLight, size: 24),
        ),
        const SizedBox(height: 10),
        const Text("المصحف الشريف", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const Text("صنع بـ ❤️ لخدمة القرآن الكريم", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
