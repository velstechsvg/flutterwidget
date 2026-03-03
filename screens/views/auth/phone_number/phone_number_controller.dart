import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/graphql/send_otp/__generated__/send_verification_otp.data.gql.dart';

// import 'package:yottachat/config/client.dart';
import 'package:yottachat/graphql/send_otp/__generated__/send_verification_otp.req.gql.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/widgets/country_code_picker/country.dart';

import '../../../../app.dart';
import '../../../../widgets/country_code_picker/function.dart';
import '../auth_navigator.dart';

enum status { initial, loading, loaded }

class PhoneNumberController extends BaseController {
  AuthNavigator? navigator;
  TextEditingController phoneNumberController = TextEditingController();
  var languageCodeObs = "EN".obs;
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

  final List<String> languageDisplayCode = ["EN", "ES", "FR","IN", "日本", "PY", "AR"];
  List<Map<String, dynamic>> launguages = [];
  var passingArg;
  String countryCode = "US";
  var dialCode = "+1".obs;
  var selectedFlag = "flags/usa.png".obs;

  @override
  void onReady() {
    super.onReady();
    formLanguageArray();
  }

  void validatePhoneNumber(context) {
    int phonenolength = phoneNumberController.text.toString().length;
    if (phoneNumberController.text.isEmpty) {
      isLoading.value = false;
      showSnackBar("please_enter_phone_number".tr, context);
    } else if (phonenolength <= 4 || phonenolength >= 15) {
      isLoading.value = false;
      showSnackBar("enter_valid_number".tr, context);
    } else {
      isLoading.value = true;
      sendVerificationOTP(context);
    }
  }

  Future<void> sendVerificationOTP(context) async {
    String appType = Platform.isAndroid ? "android" : "ios";

    final params = GsendVerificationSmsReq((b) => b
      ..vars.phoneNumber = phoneNumberController.text.toString()
      ..vars.deviceId = appPreference.deviceID
      ..vars.phoneDialCode = dialCode.value
      ..vars.deviceType = appType
      ..vars.securityKey = Constants.securityKey
      ..vars.phoneCountryCode = countryCode
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GsendVerificationSmsData;
        var resultStatus = response.sendVerificationSms!.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          navigator!.navigateScreen(AuthScreen.otpPage, "");
        } else {
          isLoading.value = false;
          showSnackBar(response.sendVerificationSms!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void formLanguageArray() {
    for (var i = 0; i < languageDropDown.length; i++) {
      Map<String, dynamic> map = Map<String, dynamic>();
      map["id"] = languageCode[i];
      map["value"] = languageDropDown[i];
      map["discode"] = languageDisplayCode[i];

      if (languageCode[i] == appPreference.preferredLanguage) {
        languageCodeObs.value = languageDisplayCode[i];
        launguages.insert(0, map);
      } else {
        launguages.add(map);
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
