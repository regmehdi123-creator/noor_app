import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/core/auth_controller.dart';
import 'package:noor/shared/widget/red_button.dart';

import '../home/home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Removed sendVerificationEmail() from here because it's already sent during Register
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // Don't auto-send immediately to avoid "too-many-requests" error
      // Instead, we wait for user to press the button or just start the checker
      timer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });

      if (isEmailVerified) {
        timer?.cancel();
        Get.snackbar("نجاح", "تم التحقق من الحساب بنجاح ✅");
        // AuthController listener will handle navigation to Home
      }
    }
  }

  Future sendVerificationEmail() async {
    if (!canResendEmail) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        setState(() => canResendEmail = false);
        // Start cooldown
        Timer(const Duration(seconds: 60), () {
          if (mounted) setState(() => canResendEmail = true);
        });

        Get.snackbar("البريد الإلكتروني", "تم إرسال رابط التحقق. تفقد بريدك الوارد.", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: mainColor.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ أثناء الإرسال";
      if (e.code == 'too-many-requests') {
        message = "لقد أرسلنا بريداً بالفعل، يرجى الانتظار قليلاً قبل المحاولة مجدداً";
      }
      Get.snackbar("تنبيه", message,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("خطأ", "فشل إرسال البريد، حاول لاحقاً",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Homepage()
      : Scaffold(
          backgroundColor: cream,
          appBar: AppBar(
            backgroundColor: mainColor,
            title: const Text("التحقق من الحساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/lottie/WalkingCat.json", height: 180),
                const SizedBox(height: 24),
                const Text(
                  "لقد قمنا بإنشاء حسابك! 🚀",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainColor),
                ),
                const SizedBox(height: 12),
                const Text(
                  "يرجى الضغط على الزر أدناه لإرسال رابط التحقق إلى بريدك الإلكتروني، ثم اضغط على الرابط في الرسالة لتفعيل الحساب.",
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                RedButton(
                  title: canResendEmail ? "إرسال رابط التحقق" : "انتظر دقيقة قبل الإعادة...",
                  press: canResendEmail ? sendVerificationEmail : () {},
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => AuthController.instance.logout(),
                  child: const Text(
                    "تسجيل الخروج / إلغاء",
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
}
