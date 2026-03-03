import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/navigation_service.dart';
import 'package:yottachat/pref/app_preference.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/resources/app_style.dart';
import 'package:yottachat/screens/binding/main_binding.dart';
import 'package:yottachat/screens/views/splash/splash.dart';

import 'app_localizations.dart';

class App extends StatelessWidget {
  static const APP_NAME =
      String.fromEnvironment('APP_NAME', defaultValue: "YottaChat");

  static final App _instance = App._internal();

  App._internal();

  factory App() {
    Get.put(AppPreference());
    return _instance;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: MainBinding(),
      navigatorKey: NavigationService.navigatorKey,
      locale: LocalizationService.locale,
      defaultTransition: Transition.leftToRight,
      fallbackLocale: LocalizationService.fallbackLocale,
      supportedLocales: LocalizationService.locales,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      translations: LocalizationService(),
      title: APP_NAME,
      theme: AppStyles.lightTheme(),
      home: Splash(),
    );
  }

  showNetOffSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: AppColors.white,
      messageText: Text(message, style: TextStyle(color: AppColors.black)),
      mainButton: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.close, color: AppColors.black)),
    ));
  }

  showAppbar(BuildContext context,
      [Widget? widget,
      Color? bgColor,
      Function? function,
      String? title,
      Widget? action,
      bool? isBackButtonNeeded,
      PreferredSizeWidget? bottomWidget,
      bool? isTitleBold = true,
      Widget? networkWidget,
      bool? isNetWorkAvailable]) {
    return isNetWorkAvailable == true
        ? customAppBar(context, widget, bgColor, function, title, action,
            isBackButtonNeeded, bottomWidget, isTitleBold)
        : PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 30),
            child: Column(
              children: [
                networkWidget ?? SizedBox.shrink(),
                SizedBox.fromSize(
                  size: const Size.fromHeight(kToolbarHeight + 30),
                  child: Stack(
                    children: [
                      customAppBar(context, widget, bgColor, function, title,
                          action, isBackButtonNeeded, bottomWidget, isTitleBold)
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget customAppBar(BuildContext context,
      [Widget? widget,
      Color? bgColor,
      Function? function,
      String? title,
      Widget? action,
      bool? isBackButtonNeeded,
      PreferredSizeWidget? bottomWidget,
      bool? isTitleBold = true]) {
    return AppBar(
        toolbarHeight: bottomWidget != null ? 100.0 : 70.0,
        backgroundColor: bgColor,
        forceMaterialTransparency: true,
        leadingWidth: 80,
        leading: Container(
            margin: EdgeInsetsDirectional.only(
                start: 20.0, top: bottomWidget != null ? 10.0 : 0.0),
            alignment: AlignmentDirectional.centerStart,
            child: widget ??
                (isBackButtonNeeded!
                    ? InkWell(
                        onTap: () {
                          if (function != null) {
                            function();
                          } else {
                            Get.back();
                          }
                        },
                        child: SvgPicture.asset(
                          scaffoldArrowExploreSvg,
                          matchTextDirection: true,
                        ),
                      )
                    : const SizedBox.shrink())),
        title: (title != null)
            ? Text(title,
                style: TextStyle(
                    fontSize: AppDimen.textSize_20,
                    fontFamily: AppFont.font,
                    color: AppColors.black,
                    fontWeight: isTitleBold == true
                        ? FontWeight.bold
                        : FontWeight.normal))
            : const SizedBox.shrink(),
        elevation: 0,
        titleTextStyle:
            const TextStyle(color: AppColors.black, fontFamily: AppFont.font),
        centerTitle: true,
        bottom: bottomWidget != null
            ? bottomWidget
            : PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox(
                  height: 0,
                ),
              ),
        actions: <Widget>[
          (action != null) ? action : const SizedBox.shrink(),
        ]);
  }

  MethodChannel locationChannel = MethodChannel('getLocation');

  void closeApp() {
    if (Platform.isAndroid) {
      locationChannel.invokeMethod('closeApp');
      SystemNavigator.pop();
    } else
      exit(0);
  }

  Future<String> getSecurityKey() async {
    try {
      String securityKey = await locationChannel.invokeMethod('getSecurityKey');
      Constants.securityKey = securityKey;
      return securityKey;
    } on PlatformException catch (e) {
      print("Failed to get security key: '${e.message}'.");
      return "";
    }
  }
}
