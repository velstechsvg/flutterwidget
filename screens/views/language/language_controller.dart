import 'dart:io';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/utils.dart';
import '../../../app_localizations.dart';
import '../../../config/client.dart';
import '../../../constant.dart';
import '../../../graphql/settings/update_profile_settings/__generated__/updateProfileSettings.data.gql.dart';
import '../../../graphql/settings/update_profile_settings/__generated__/updateProfileSettings.req.gql.dart';
import '../base_controller.dart';
import 'language_navigator.dart';

class LanguageController extends BaseController {
  SettingsNavigator? navigator;
  var version = "".obs;

  var languageCodeObs = "Eng".obs;
  final List<String> languageDropDown = [
    "English",
    "Española",
    "Français",
    "Indonesia",
    "日本",
    "Pусский",
    "عربي"
  ];

  final List<String> languageCode = [
    "en",
    "es",
    "fr",
    "id",
    "ja",
    "ru",
    "ar"
  ];

  List<Map<String, dynamic>> launguages = [];

  @override
  void onReady() {
    isLoading.value = false;
    formLanguageArray();
    super.onReady();
  }

  @override
  void onHidden() {}

  String getLanguageName() {
    return languageDropDown[
        languageCode.indexOf(appPreference.preferredLanguage ?? "en")];
  }

  updateProfileSettings(context, String fieldName, String fieldValue) {
    isLoading.value = true;
    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GUpdateProfileSettingsReq((b) => b
      ..vars.deviceId = appPreference.deviceID
      ..vars.deviceType = appType
      ..vars.fieldName = fieldName
      ..vars.fieldValue = fieldValue
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) {
      isLoading.value = false;
      if (res.data != null) {
        var response = res.data as GUpdateProfileSettingsData;
        if (response.updateProfileSettings?.status == 200) {
          appPreference.preferredLanguage = fieldValue;
          LocalizationService().changeLocale(fieldValue);
        } else if (response.updateProfileSettings?.status == 400) {
          showSnackBar(
              response.updateProfileSettings?.errorMessage ??
                  "some_thing_error".tr,
              context);
        } else if (response.updateProfileSettings?.status == 500) {
          showUserLogout(
              response.updateProfileSettings?.errorMessage ??
                  "some_thing_error".tr,
              context);
        }
      } else {
        updateProfileSettings(context, fieldName, fieldValue);
        // showSnackBar("some_thing_error".tr, context);
      }
    });
  }

  void formLanguageArray() {
    for (var i = 0; i < languageDropDown.length; i++) {
      Map<String, dynamic> map = Map<String, dynamic>();
      map["id"] = languageCode[i];
      map["value"] = languageDropDown[i];

      if (languageCode[i] == appPreference.preferredLanguage) {
        launguages.insert(0, map);
      } else {
        launguages.add(map);
      }
    }
  }

  showErrorMessage(context) {
    showSnackBar("No currencies fetched", context);
  }
}
