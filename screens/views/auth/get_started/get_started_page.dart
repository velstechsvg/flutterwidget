import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:yottachat/app.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_controller.dart';
import 'package:yottachat/screens/views/auth/phone_number/phone_number_page.dart';
import 'package:yottachat/widgets/bottom_button.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../../widgets/country_code_picker/function.dart';
import '../../custom_scaffold.dart';
import '../../splash/splash.dart';
import '../auth_navigator.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with WidgetsBindingObserver
    implements AuthNavigator {
  final GetStartedController controller = Get.find();
  late Stream<String> _tokenStream;

  @override
  void initState() {
    controller.buttonClickInPhoneNoAuth = true;
    controller.navigator = this;
    WidgetsBinding.instance!.addObserver(this);
    controller.passingArg = Get.arguments;
    if (controller.appPreference.deviceID == null ||
        controller.appPreference.deviceID!.isEmpty) {
      getFCMToken();
    }
    if (Platform.isAndroid) {
      _getNotificationPermission();
    }
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.resumed") {
        if (Platform.isAndroid) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: AppColors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: AppColors.white, // Note RED here
            ),
          );
        }
      }
      return await msg;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.lightPrimary,
      body: SafeArea(
        child: showBodyContent(context),
      ),
      isShowAppBar: false,
      customAppBarFunction: () {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
          Get.to(Splash);
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
      resizeToAvoidBottomInset: true,
    );
  }

  Widget showBodyContent(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.white,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withAlpha(60),
            AppColors.primaryColor.withAlpha(30),
            AppColors.primaryColor.withAlpha(0),
            AppColors.primaryColor.withAlpha(0)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.2, 1, 1],
        ),
      ),
      child: [
        [
          Center(
            child: Image.asset(
              initialPagePng,
              width: MediaQuery.of(context).size.width * 0.90, //
              height: MediaQuery.of(context).size.height * 0.65,
              fit: BoxFit.scaleDown,
            ),
          ),
          10.toHeight(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimen.textSize_20),
            child: CustomText(
              text: "${'welcome_text'.tr} ${App.APP_NAME}",
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              size: AppDimen.textSize_24,
            ),
          ),
          15.toHeight(),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimen.textSize_24),
            child: CustomText(
              text: 'get_that_done'.tr,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              color: AppColors.secondaryTextColor,
              size: AppDimen.textSize_18,
              maxLines: 2,
              fontWeight: AppFont.regular,
            ),
          ),
        ].toScroll().toStretch(isFillSpace: false),
        InkWell(
          onTap: () async {
            controller.isLoading.value = true;
            controller.checkNetwork(context, () {
              navigateScreen(AuthScreen.phoneNumber, "");
            });
          },
          child: Obx(
            () => BottomButton(
                buttonText: 'get_started'.tr,
                isLoading: controller.isLoading.value),
          ),
        ),
      ].toColumn(),
    );
  }

  @override
  navigateScreen(AuthScreen screen, String param) {
    if (screen == AuthScreen.phoneNumber) {
      Get.offAll(
          () => PhoneNumberPage(
                from: "getStartedPage",
              ),
          arguments: {
            "countryCode": controller.country.countryCode,
            "dialCode": controller.country.callingCode,
            "country": controller.country
          },
          routeName: "/phoneNumberPage");
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
                    UrlLauncher.launchUrl(Uri.parse(controller.playStoreLink));
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

  _getNotificationPermission() async {
    PermissionStatus notificationPermissionStatus =
        await Permission.notification.status;
    if (notificationPermissionStatus != PermissionStatus.granted &&
        notificationPermissionStatus != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus =
          await Permission.notification.request();
    } else {
      return notificationPermissionStatus;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller.buttonClickInPhoneNoAuth = false;
    super.dispose();
  }
}
