import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/graphql/send_otp/__generated__/send_verification_otp.data.gql.dart';
import 'package:yottachat/graphql/send_otp/__generated__/send_verification_otp.req.gql.dart';
import 'package:yottachat/graphql/verify_otp/__generated__/verify_otp.data.gql.dart';
import 'package:yottachat/graphql/verify_otp/__generated__/verify_otp.req.gql.dart';

import '../../../../app.dart';
import '../../base_controller.dart';
import '../auth_navigator.dart';

enum status { initial, loading }

class OtpVerifyController extends BaseController {
  AuthNavigator? navigator;
  TextEditingController firstPinController = TextEditingController(text: '');
  TextEditingController secondPinController = TextEditingController(text: '');
  TextEditingController thirdPinController = TextEditingController(text: '');
  TextEditingController fourthPinController = TextEditingController(text: '');
  var passingArg;
  String phoneNumber = "", countryCode = "", dialCode = "";
  final FocusNode pinInputFocus = FocusNode();

  var focusChange = false.obs;
  TextEditingController pinEditingController = TextEditingController(text: '');
  var pinvalue = "";

  @override
  void onReady() {
    super.onReady();
  }

  void vaildateOTP(context) {
    if (pinvalue.isNotEmpty && pinvalue.length == 4) {
      verifyOTP(context);
    } else {
      isLoading.value = false;
      showSnackBar("enter_vaild_otp".tr, context);
    }
  }

  void verifyOTP(context) {
    try {
      String appType = Platform.isAndroid ? "android" : "ios";
      String pin = pinEditingController.text;
      int pinNumber = int.parse(pin);

      final params = GverifyPhoneNumberReq((b) => b
        ..vars.phoneDialCode = dialCode
        ..vars.phoneNumber = phoneNumber
        ..vars.verificationCode = pinNumber
        ..vars.deviceType = appType
        ..vars.deviceId = appPreference.deviceID
        ..vars.preferredLanguage = appPreference.preferredLanguage
        ..vars.phoneCountryCode = countryCode
        ..vars.build());

      FerryLoggerClient.makeRequest(params).listen((res) async {
        if (res.data != null) {
          var response = res.data as GverifyPhoneNumberData;
          var data = response.verifyPhoneNumber;
          if (data != null) {
            if (data.status == 200) {
              isLoading.value = false;
              if (data.result?.account != null) {
                setPreferenceValue(response, context);
              } else {
                navigator?.navigateScreen(AuthScreen.signup, "");
              }
            }
            else if (data.status == 400) {
              firstPinController.text = "";
              secondPinController.text = "";
              thirdPinController.text = "";
              fourthPinController.text = "";
              isLoading.value = false;
              showSnackBar(response.verifyPhoneNumber!.errorMessage!, context);
            }
            else {
              isLoading.value = false;
              showUserLogout(response.verifyPhoneNumber!.errorMessage!, context);
            }
          } else {
            isLoading.value = false;
            showSnackBar("Something went wrong", context);
          }
        }
        isLoading.value = false;
      });
    } catch (e) {
      Get.printInfo(info: "Service not found-->> Normal login");
      String appType = Platform.isAndroid ? "android" : "ios";
      String pin = "${pinEditingController.text}";
      int pinNumber = int.parse(pin);

      final params = GverifyPhoneNumberReq((b) => b
        ..vars.phoneDialCode = dialCode
        ..vars.phoneNumber = phoneNumber
        ..vars.verificationCode = pinNumber
        ..vars.deviceType = appType
        ..vars.deviceId = appPreference.deviceID
        ..vars.preferredLanguage = appPreference.preferredLanguage
        ..vars.phoneCountryCode = countryCode
        ..vars.build());

      FerryLoggerClient.makeRequest(params).listen((res) async {
        if (res != null && res.data != null) {
          var response = res.data as GverifyPhoneNumberData;
          var data = response.verifyPhoneNumber;
          if (data != null) {
            if (data.status == 200) {
              isLoading.value = false;
              if (data.result?.account != null) {
                setPreferenceValue(response, context);
              } else {
                navigator?.navigateScreen(AuthScreen.signup, "");
              }
            } else if (data.status == 400) {
              isLoading.value = false;
              firstPinController.text = "";
              secondPinController.text = "";
              thirdPinController.text = "";
              fourthPinController.text = "";
              showSnackBar(response.verifyPhoneNumber!.errorMessage!, context);
            } else {
              isLoading.value = false;
              showUserLogout(response.verifyPhoneNumber!.errorMessage!, context);
            }
          } else {
            isLoading.value = false;
            showSnackBar("Something went wrong", context);
          }
        }
        isLoading.value = false;
      });
    }
  }

  Future<void> sendVerificationOTP(context) async {
    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GsendVerificationSmsReq((b) => b
      ..vars.phoneNumber = phoneNumber
      ..vars.deviceId = appPreference.deviceID
      ..vars.phoneDialCode = dialCode
      ..vars.deviceType = appType
      ..vars.securityKey = Constants.securityKey
      ..vars.phoneCountryCode = countryCode
      ..vars.build());

    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res != null) {
        pinEditingController.clear();
        pinvalue = "";
        var response = res.data as GsendVerificationSmsData;
        var resultStatus = response.sendVerificationSms!.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          showSnackBar("otp_resend".tr, context);
        } else {
          // isLoading.value = false;
          showSnackBar(response.sendVerificationSms!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> setPreferenceValue(
      GverifyPhoneNumberData res, BuildContext context) async {
    var data = res.verifyPhoneNumber!;
    appPreference.accessToken = data.result!.auth!;
    appPreference.userID = data.result!.account!.userId;
    appPreference.firstName = data.result!.account!.firstName;
    if (data.result!.account!.description != null) {
      appPreference.description = data.result!.account!.description;
    } else {
      appPreference.description = "${App.APP_NAME} newbie :)";
    }
    appPreference.phoneNumber = phoneNumber;
    appPreference.dialCode = dialCode;
    appPreference.countryCode = countryCode;
    appPreference.preferredLanguage =
        data.result?.account?.preferredLanguage ?? "en";
    Constants.authToken = data.result!.auth!;
    resetFerryClient();

    if (data.result!.account!.picture != null &&
        data.result!.account!.userId != null) {
      appPreference.profileImage =
          "${Constants.profileImagePath}${data.result!.account!.userId}/${data.result!.account!.picture}";
    }
    navigator?.navigateScreen(AuthScreen.moveToHome, "");
  }

  @override
  void onClose() {
    super.onClose();
  }
}
