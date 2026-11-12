import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/core/auth_controller.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/shared/widget/red_button.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}
  class _SignUpState extends State<SignUp> {

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 22),
            Lottie.asset("assets/lottie/WalkingCat.json", height: 280, width: 280),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined, size: 21),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, size: 21),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() => AuthController.instance.isLoading.value
                    ? const CircularProgressIndicator(color: mainColor)
                    : RedButton(title: "Sign Up", press: () {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        
                        if (email.isEmpty || password.isEmpty) {
                          Get.snackbar("تنبيه", "يرجى ملء جميع الحقول", backgroundColor: Colors.orangeAccent);
                          return;
                        }
                        
                        AuthController.instance.register(email, password);
                      })
                  ),
                  const SizedBox(height: 10),
                  Obx(() => AuthController.instance.isLoading.value
                    ? const SizedBox.shrink()
                    : SignInButton(
                        Buttons.google,
                        text: "Sign up with Google",
                        onPressed: () => AuthController.instance.signInWithGoogle(),
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
