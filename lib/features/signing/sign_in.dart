import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/core/auth_controller.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/features/home/home_page.dart';
import 'package:noor/features/signing/sign_up.dart';
import 'package:noor/shared/widget/red_button.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
        const SizedBox(height: 22,),
        Lottie.asset("assets/lottie/WalkingCat.json",height: 280,width: 280),
        Container(margin: const EdgeInsets.symmetric(horizontal: 22,),padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 18),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(25),),
        child: Column(children: [
          const Text("WELCOME",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
          const SizedBox(height: 25,),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
             labelText: "Email"
            ,prefixIcon: const Icon(
              Icons.email_outlined,
              size: 21,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.black,
                )
            ),
            ),
          ),
          const SizedBox(height: 15,),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(
              Icons.lock,
              size: 21,
            ),
            border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.black,
                )
            ),

            ),
          ),
          const SizedBox(height: 15,),
          Obx(() => AuthController.instance.isLoading.value 
            ? const CircularProgressIndicator(color: Colors.red)
            : RedButton(title: "Sign In", press: (){
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                if(email.isEmpty || password.isEmpty) {
                  Get.snackbar("تنبيه", "يرجى إدخال البريد وكلمة المرور");
                  return;
                }
                AuthController.instance.login(email, password);
              })
          ),
          const SizedBox(height: 10,),
          Obx(() => AuthController.instance.isLoading.value 
            ? const SizedBox.shrink()
            : SignInButton(
                Buttons.google,
                text: "Sign in with Google",
                onPressed: () => AuthController.instance.signInWithGoogle(),
              )
          ),
          const SizedBox(height: 8,),
          RedButton(title: "Go as Host", press: (){
            Get.offAll(() => const Homepage());
          }),
          const SizedBox(height: 10,),
          TextButton(onPressed: (){
            Get.to(() => const SignUp());
          }, child: const Text("Sign Up",style: TextStyle(color: Colors.red,decoration: TextDecoration.underline,),))


          ],
        ),
      ),
      ],
    ),
  ),
);
  }

}