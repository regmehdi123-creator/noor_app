import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_routes.dart';

class LangueController extends GetxController {
  final _pref = Get.find<SharedPreferences>();
  final RxString lang = "".obs;

  @override
  void onInit() {
    super.onInit();
    final savedLang = _pref.getString('lang');
    if (savedLang != null) {
      lang.value = savedLang;
    }
  }

  void setLangue(String l) {
    _pref.setString('lang', l);
    lang.value = l;
    Get.offAllNamed(AppRoutes.signIn);
  }

  void toggleLanguage() {
    String newLang = lang.value == 'ar' ? 'en' : 'ar';
    _pref.setString('lang', newLang);
    lang.value = newLang;
  }
}
