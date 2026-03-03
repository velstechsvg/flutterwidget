import 'package:get/get.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_controller.dart';
import 'package:yottachat/screens/views/auth/otp_verify/otp_verify_page_controller.dart';
import 'package:yottachat/screens/views/auth/phone_number/phone_number_controller.dart';
import 'package:yottachat/screens/views/auth/signup/signup_controller.dart';
import 'package:yottachat/screens/views/splash/splash_controller.dart';


class AuthBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(()=> SplashController(), fenix: true);
    Get.lazyPut<SignUpController>(() =>SignUpController(), fenix: true);
    Get.lazyPut<GetStartedController>(() =>GetStartedController(), fenix: true);
    Get.lazyPut<PhoneNumberController>(() =>PhoneNumberController(), fenix: true);
    Get.lazyPut<OtpVerifyController>(() => OtpVerifyController(), fenix: true);
  }
}