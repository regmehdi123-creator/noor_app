import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noor/features/home/home_page.dart';
import 'package:noor/features/on_boarding/language_page.dart';
import 'package:noor/features/signing/verify_email.dart';
import 'package:noor/core/colors.dart';
import 'app_routes.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<User?> _user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  User? get firebaseUser => _user.value;

  @override
  void onReady() {
    super.onReady();
    _user.value = _auth.currentUser;
    _user.bindStream(_auth.userChanges());
    
    // Initial check and splash removal
    _handleAuthChanged(_user.value);
    FlutterNativeSplash.remove();
    
    ever(_user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      // Go to home, middleware will catch if language is not set
      Get.offAllNamed(AppRoutes.home);
    } else {
      // Logic: Only proceed to Homepage if email is verified OR it's a Google login
      bool isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
      if (user.emailVerified || isGoogle) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.verifyEmail);
      }
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Send verification immediately
      await credential.user?.sendEmailVerification();
      
      Get.snackbar("نجاح", "تم إنشاء الحساب، يرجى تفعيل البريد الإلكتروني", 
        backgroundColor: mainColor, colorText: Colors.white);
        
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.code);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.code);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      
    } catch (e, stackTrace) {
      debugPrint("Google Sign-In Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      Get.snackbar(
        "خطأ", 
        "فشل تسجيل الدخول عبر جوجل: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String errorCode) {
    String message;
    switch (errorCode) {
      case 'user-not-found':
        message = "لا يوجد حساب بهذا البريد الإلكتروني";
        break;
      case 'wrong-password':
        message = "كلمة المرور غير صحيحة";
        break;
      case 'email-already-in-use':
        message = "هذا البريد الإلكتروني مستخدم بالفعل";
        break;
      case 'weak-password':
        message = "كلمة المرور ضعيفة جداً";
        break;
      case 'invalid-email':
        message = "صيغة البريد الإلكتروني غير صحيحة";
        break;
      case 'too-many-requests':
        message = "تم حظر الطلبات مؤقتاً لكثرة المحاولات، حاول لاحقاً";
        break;
      default:
        message = "حدث خطأ ما، يرجى المحاولة لاحقاً";
    }
    Get.snackbar("تنبيه", message, 
      backgroundColor: Colors.redAccent, 
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
