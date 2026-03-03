import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/screens/binding/auth_binding.dart';
import 'package:yottachat/screens/views/auth/auth_navigator.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_page.dart';
import 'package:yottachat/screens/views/splash/splash_controller.dart';

import '../../../app.dart';
import '../../../config/client.dart';
import '../../binding/home_binding.dart';
import '../chat/chat_view.dart';
import '../explore/explore_view.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  SplashImplState createState() => SplashImplState();
}

class SplashImplState extends State<Splash> implements AuthNavigator {
  final controller = Get.find<SplashController>();
  late Stream<String> _tokenStream;

  @override
  void initState() {
    controller.navigator = this;
    controller.hideKeyBoard();
    App().getSecurityKey().then((value) => controller.getSiteSettings(value));
    controller.checkNetwork(Get.context, () {
      controller.verifyIsLogin(context);
    });
    setCrashCollection();
    super.initState();
  }

  setCrashCollection() async {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS) {
        requestIOSPermission();
      } else {
        getFCMToken();
      }
    });
  }

  Future<void> getFCMToken() async {
    FirebaseMessaging.instance.getToken().then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  void setToken(String? token) {
    controller.fcmToken = token;
    controller.appPreference.deviceID = controller.fcmToken;
    if (appPreference.accessToken.toString().isNotEmpty) {
      controller.isLoading.value = true;
    } else {
      controller.isLoading.value = false;
    }
  }

  requestIOSPermission() {
    FirebaseMessaging.instance
        .requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    )
        .then((value) {
      getFCMToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Image(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          image: const AssetImage(splashPng),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  navigateScreen(AuthScreen screen, String param) {
    isShowPopup = true;
    if (screen == AuthScreen.getStarted) {
      Get.to(() => const GetStartedPage(),
          binding: AuthBinding(),
          arguments: {"isLogin": param},
          routeName: "/getStartedPage");
    } else if (screen == AuthScreen.moveToHome) {
      country = controller.country;
      controller.isLoading.value = false;
      Get.offAll(ExploreView(),
          binding: HomeBinding(),
          routeName: "/homePage",
          duration: const Duration(seconds: 2),
          transition: Transition.fade);
    } else if (screen == AuthScreen.moveToChat) {
      Get.to(() => const ChatView(),
          binding: HomeBinding(),
          arguments: {
            "selectedContact": Constants.chatDetailsFromFCM,
            "from": "fcm"
          },
          routeName: "/chatView");
    }
  }

  @override
  showDialog() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(0),
        title: '',
        titleStyle: const TextStyle(fontSize: 0),
        radius: 20,
        content: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(controller.updateMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.black,
                        fontSize: AppDimen.textSize_20))),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: const SizedBox(
                width: double.infinity,
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primaryColor),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    UrlLauncher.launchUrl(Uri.parse(controller.playStoreLink), mode: UrlLauncher.LaunchMode.externalApplication);
                  } else if (Platform.isIOS) {
                    UrlLauncher.launchUrl(Uri.parse(controller.appStoreLink));
                  }
                },
                child: Text(
                  'update_now'.tr,
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: AppDimen.textSize_16,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ));
  }
}
