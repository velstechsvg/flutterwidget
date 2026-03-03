import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yottachat/screens/views/auth/auth_navigator.dart';
import 'package:yottachat/constant.dart' as Constants;

import '../../../app.dart';
import '../../../app_localizations.dart';
import '../../../config/client.dart';
import '../../../graphql/get_version_update/__generated__/get_version_update.data.gql.dart';
import '../../../graphql/get_version_update/__generated__/get_version_update.req.gql.dart';
import '../../../graphql/siteSettings/__generated__/secure_site_settings.data.gql.dart';
import '../../../graphql/siteSettings/__generated__/secure_site_settings.req.gql.dart';
import '../../../graphql/user_profile/__generated__/profile.data.gql.dart';
import '../../../graphql/user_profile/__generated__/profile.req.gql.dart';
import '../../../widgets/country_code_picker/country.dart';
import '../../../widgets/country_code_picker/function.dart';
import '../base_controller.dart';

class SplashController extends BaseController {
  AuthNavigator? navigator;
  String playStoreLink = 'https://play.google.com/store/apps/details?id=com.radicalstart.yottachat', appStoreLink = 'https://apps.apple.com/in/app/yottachat/id6479519753';
  String updateMessage = "";
  bool isSettingOpened = false;
  String? fcmToken;
  var cameras;

  @override
  void onReady() {
    super.onReady();
    availableCameras().then((value) {
      cameras = value;
    });
  }

  @override
  void onHidden() {}

  Future<void> getSiteSettings(String securityKey) async {
    final params = GgetSecureSiteSettingsReq((b) => b
      ..vars.securityKey = securityKey
      ..vars.settingsType = "site_settings"
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetSecureSiteSettingsData;
        var resultStatus = response.getSecureSiteSettings?.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          response.getSecureSiteSettings?.results?.forEach((element) {
            if (element?.name == "siteName") {
              appPreference.siteName = element?.value;
            } else if (element?.name == "homeLogo") {
              appPreference.homeLogo = element?.value;
            }
          });
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> getVersionUpdate(context, bool isLoggedIn) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    resetFerryClient();
    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GGetApplicationVersionInfoReq((b) => b
      ..vars.version = packageInfo.version
      ..vars.osType = appType
      ..vars.requestLang = appPreference.preferredLanguage
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GGetApplicationVersionInfoData;
        var resultStatus = response.getApplicationVersionInfo?.status;
        if (resultStatus == 500) {
          navigator?.navigateScreen(AuthScreen.getStarted, "");
        }
        if (resultStatus == 200) {
          isLoading.value = false;
          if (isLoggedIn) {
            checkNetwork(context, () {
              getProfileInfo(context);
            });
          } else {
            navigator?.navigateScreen(AuthScreen.getStarted, "");
          }
        } else {
          response.getApplicationVersionInfo!.result?.siteSettings!.forEach((element) {
            if (element?.name == "siteName") {
              appPreference.siteName = element?.value;
            } else if (element?.name == "homeLogo") {
              appPreference.homeLogo = element?.value;
            }
          });
          updateMessage = response.getApplicationVersionInfo?.errorMessage ?? "Something went wrong";
          isLoading.value = false;
          if(response.getApplicationVersionInfo?.result?.playStoreURL != null && response.getApplicationVersionInfo?.result?.playStoreURL?.user?.isNotEmpty == true){
            playStoreLink = response.getApplicationVersionInfo?.result?.playStoreURL?.user ?? 'https://play.google.com/store/apps/details?id=com.radicalstart.yottachat';
          }
          if(response.getApplicationVersionInfo?.result?.appStoreURL != null && response.getApplicationVersionInfo?.result?.appStoreURL?.user?.isNotEmpty == true){
            appStoreLink = response.getApplicationVersionInfo?.result?.appStoreURL?.user ?? 'https://apps.apple.com/in/app/yottachat/id6479519753';
          }
          navigator?.showDialog();
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void getProfileInfo(context) {
    final params = GGetProfileReq((b) => b..vars.build());

    FerryLoggerClient.makeRequest(params).listen((res) {
      if (res.data != null) {
        var response = res.data as GGetProfileData;
        if (response.userAccount != null) {
          if (response.userAccount?.status == 200 &&
              response.userAccount?.result != null) {
            if (response.userAccount?.result!.picture != null &&
                response.userAccount?.result!.userId != null) {
              appPreference.profileImage =
                  "${Constants.profileImagePath}${response.userAccount?.result!.userId}/${response.userAccount?.result!.picture}";
            }
            appPreference.countryCode =
                response.userAccount?.result!.phoneCountryCode ?? "US";
            appPreference.dialCode =
                response.userAccount?.result!.phoneDialCode ?? "+1";
            if (response.userAccount?.result!.description != null) {
              appPreference.description =
                  response.userAccount?.result!.description;
            } else {
              appPreference.description = "${App.APP_NAME} newbie :)";
            }
            appPreference.firstName = response.userAccount?.result!.firstName;
            if (Constants.chatDetailsFromFCM.isNotEmpty) {
              navigator!.navigateScreen(AuthScreen.moveToChat, "");
            } else {
              navigator!.navigateScreen(AuthScreen.moveToHome, "");
            }
          } else if (response.userAccount!.status == 400) {
            isLoading.value = false;
            showSnackBar(response.userAccount!.errorMessage!, context);
          } else {
            isLoading.value = false;
            showUserLogout(response.userAccount!.errorMessage!, context);
          }
        } else {
          isLoading.value = false;
          showSnackBar("some_thing_error".tr, context);
        }
      } else {
        getProfileInfo(context);
      }
    });
  }

  void verifyIsLogin(BuildContext context) {
    appPreference.pref.initStorage.then((value) {
      Constants.authToken = appPreference.accessToken ?? "";
      LocalizationService().changeLocale(
          appPreference.preferredLanguage ?? Constants.preferredLanguage);
      if (Constants.authToken?.isNotEmpty == true) {
        getVersionUpdate(context, true);
      } else {
        getVersionUpdate(context, false);
      }
    });
  }
}
