import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/graphql/delete_account/__generated__/delete_account.data.gql.dart';
import 'package:yottachat/graphql/delete_account/__generated__/delete_account.req.gql.dart';
import 'package:yottachat/graphql/get_static_content/__generated__/get_static_content_by_id.req.gql.dart';
import 'package:yottachat/graphql/user_signout/__generated__/user_signout.data.gql.dart';
import 'package:yottachat/graphql/user_signout/__generated__/user_signout.req.gql.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';

import '../../../graphql/siteSettings/__generated__/secure_site_settings.data.gql.dart';
import '../../../graphql/siteSettings/__generated__/secure_site_settings.req.gql.dart';
import '../base_controller.dart';

class ProfileController extends HomeController {
  HomeNavigator? navigator;
  var version = "".obs;
  var firstName = "".obs;
  var description = "".obs;
  var profileImage = "".obs;
  var htmlContent = "".obs;
  var isLoadSupportUrl = true.obs;
  var isDeleteLoading = false.obs;

  @override
  void onReady() {
    firstName.value = appPreference.firstName!;
    description.value = appPreference.description!;
    profileImage.value = appPreference.profileImage!;
    listenPrefChanges();
    getVersionDetails();
    super.onReady();
  }

  getVersionDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  void userSignout(context) {

    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GuserLogoutReq((b) => b
      ..vars.deviceType = appType
      ..vars.deviceId = appPreference.deviceID
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GuserLogoutData;
        if (response.userLogout != null) {
          if (response.userLogout?.status == 200) {
            FirebaseMessaging.instance.deleteToken().then((value) {
              BaseController.socketIO.off("loginCheck-${appPreference.userID}");
              BaseController.socketIO.off("updatePresenceStatus");
              sendUserIsOfflineSocket();
              appPreference.removePreference();
              resetFerryClient();
              isLoading.value = false;
              navigator?.navigateScreen(HomeScreens.getStarted, "false");
            });
          }
          else if (response.userLogout?.status == 400) {
            showSnackBar(response.userLogout!.errorMessage!, context);
          }
          else {
            FirebaseMessaging.instance.deleteToken().then((value) {
              BaseController.socketIO.off("loginCheck-${appPreference.userID}");
              appPreference.removePreference();
              resetFerryClient();
              isLoading.value = false;
              sendUserIsOfflineSocket();
              navigator?.navigateScreen(HomeScreens.getStarted, "false");
            });
          }
        }
      } else {
        userSignout(context);
      }
    });
  }

  sendUserIsOfflineSocket() {
    List<String> arg = [
      '{"auth" : "${appPreference.accessToken}","data" : { "status": "offline" }}'
    ];
    BaseController.socketIO.emit('updatePresence', arg.first);
  }

  getStaticContent(context) {
    final params = GgetStaticPageContentReq((b) => b..vars.id = isShowPrivacy.value ? 2 : 3);
    FerryLoggerClient.makeRequest(params).listen((res) {
      if (res != null) {
        var response = res.data;
        if (response.getStaticPageContent != null) {
          if (response.getStaticPageContent!.status == 200) {
            if (response.getStaticPageContent!.result!.content!.isNotEmpty) {
              htmlContent.value = response.getStaticPageContent!.result!.content!;
            }
            else {
             htmlContent.value = isShowPrivacy.value == true ? "Privacy Policy" : "Legal";
            }
            isLoading.value = false;
          }
          else if (response.getStaticPageContent!.status == 400) {
            showSnackBar(response.getStaticPageContent!.errorMessage!, context);
            isLoading.value = false;
          }
          else {
            isLoading.value = false;
            showUserLogout(response.getStaticPageContent!.errorMessage!, context);
          }
        } else {
          isLoading.value = false;
          showSnackBar("some_thing_error".tr, context);
        }
      }
      else {
        isLoading.value = false;
        showSnackBar("some_thing_error".tr, context);
      }
    });
  }

  listenPrefChanges() {
    appPreference.pref.listenKey('firstName', (value) {
      firstName.value = value;
    });
    appPreference.pref.listenKey('profileImage', (value) {
      profileImage.value = value;
    });
    appPreference.pref.listenKey('description', (value) {
      description.value = value;
    });
  }

  deleteUser(context) {
    final req = GdeleteUserReq((data) => data..vars.build());
    FerryLoggerClient.makeRequest(req).listen((response) {
      var res = response.data as GdeleteUserData;
      var data = res.deleteUser;
      if (data != null) {
        isLoading.value = false;
        if (data.status == 200) {
        } else if (data.status == 400) {
          showDeleteSnackBar(
              data.errorMessage ?? "some_thing_error".tr, context);
        } else {
          showDeleteSnackBar(
              data.errorMessage ?? "some_thing_error".tr, context);
        }
      }
    });
  }

  Future<void> getSiteSettings(String securityKey) async {
    final params = GgetSecureSiteSettingsReq((b) => b
      ..vars.securityKey = securityKey
      ..vars.settingsType = "appSettings"
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetSecureSiteSettingsData;
        var resultStatus = response.getSecureSiteSettings?.status;
        if (resultStatus == 200) {
          response.getSecureSiteSettings?.results?.forEach((element) {
            if (element?.name == "contactPhoneNumber") {
              appPreference.adminPhoneNumber = element?.value;
            } else if (element?.name == "contactEmail") {
              appPreference.adminEmail = element?.value;
            } else if (element?.name == "skype") {
              appPreference.adminSkype = element?.value;
            }
          });
          isLoadSupportUrl.value = false;
        }
      }
    });
  }

  @override
  void onPaused() {
    print('profile controller - onPaused called');
    super.onPaused();
  }
}
