import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:yottachat/pref/app_preference.dart';
import 'package:yottachat/screens/views/splash/splash_controller.dart';

class MainBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<AppPreference>(()=> AppPreference(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
  }
}