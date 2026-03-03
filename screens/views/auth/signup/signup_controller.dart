import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/graphql/create_user/__generated__/create_user.data.gql.dart';
import 'package:yottachat/graphql/create_user/__generated__/create_user.req.gql.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/utils/place_search.dart';

import '../../../../app.dart';
import '../../../../constant.dart';
import '../auth_navigator.dart';

class SignUpController extends BaseController {
  AuthNavigator? navigator;
  TextEditingController? firstNameController = TextEditingController();
  TextEditingController? lastNameController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController selectedlocationController = TextEditingController();
  RxList<Predictions> locationList = <Predictions>[].obs;
  var isNeedToClear = false.obs;
  String selectedPlaceId = "";
  double? lat, lng;
  String city = "";
  String state = "";
  String address = "";
  String countryName = "";
  String zipCode = "";
  String phoneNumber = "";
  String phoneDialCode = "";
  String countryCode = "";
  var isSignUpLoading = false.obs;

  File? imageFile;

  var isProfileUpdate = false.obs;
  var cameras;
  var isCalledProfilePage = false.obs;
  var profileImage = "".obs;
  var sendImageFile = "".obs;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  setInitialValue(Map<String, dynamic> mapValue) {
    phoneNumber = mapValue["phoneNumber"];
    phoneDialCode = mapValue["phoneDialCode"];
    countryCode = mapValue["phoneCountryCode"];
  }

  validateInputFields(BuildContext context) {
    if (profileImage.value.isNotEmpty) {
      if (firstNameController?.text.toString().trim().isNotEmpty ?? false) {
        checkNetwork(context, () {
          createUser(context);
        });
      } else {
        showSnackBar("enter_first".tr, context);
      }
    } else {
      showSnackBar("please_upload_profile_picture".tr, context);
    }
  }

  createUser(BuildContext context) async {
    var sendImageFile =
        appPreference.profileImage?.replaceAll(Constants.profileImagePath, "");
    try {
      isSignUpLoading.value = true;
      final req = GcreateUserReq((b) => b
        ..vars.firstName =
            toBeginningOfSentenceCase(firstNameController?.text.trim())
        ..vars.lastName = lastNameController?.text.trim()
        ..vars.phoneDialCode = phoneDialCode
        ..vars.phoneCountryCode = countryCode
        ..vars.phoneNumber = phoneNumber
        ..vars.deviceType = Platform.isAndroid ? "android" : "ios"
        ..vars.deviceId = appPreference.deviceID
        ..vars.preferredLanguage = appPreference.preferredLanguage
        ..vars.picture = sendImageFile
        ..vars.build());
      FerryLoggerClient.makeRequest(req).listen((response) {
        if (response.data != null) {
          var res = response.data as GcreateUserData;
          var data = res.createUser;
          if (data != null) {
            if (data.status == 200) {
              var result = data.result;
              appPreference.accessToken = result?.userToken;
              authToken = result?.userToken;
              appPreference.userID = result?.userId;
              appPreference.firstName = result?.user?.firstName;
              if (result?.user?.description != null) {
                appPreference.description = result?.user?.description;
              } else {
                appPreference.description = "${App.APP_NAME} newbie :)";
              }
              appPreference.phoneNumber = result?.phoneNumber;
              appPreference.dialCode = phoneDialCode;
              appPreference.countryCode = countryCode;
              appPreference.preferredLanguage =
                  result?.user?.preferredLanguage ?? "en";
              resetFerryClient();
              navigator!.navigateScreen(AuthScreen.moveToHome, "");
            } else if (response.data?.createUser!.status == 400) {
              isSignUpLoading.value = false;
              showSnackBar(
                  response.data?.createUser!.errorMessage ??
                      "some_thing_error".tr,
                  context);
            } else {
              isSignUpLoading.value = false;
              showSnackBar("some_thing_error".tr, context);
            }
          } else {
            isSignUpLoading.value = false;
            showSnackBar("some_thing_error".tr, context);
          }
        } else {
          isSignUpLoading.value = false;
          showSnackBar("some_thing_error".tr, context);
        }
      });
    } catch (e) {
      Get.printInfo(info: "Service not found-->> ");
      try {
        isSignUpLoading.value = true;
        final req = GcreateUserReq((b) => b
          ..vars.firstName = firstNameController?.text.trim()
          ..vars.lastName = lastNameController?.text.trim()
          ..vars.phoneDialCode = phoneDialCode
          ..vars.phoneCountryCode = countryCode
          ..vars.phoneNumber = phoneNumber
          ..vars.deviceType = Platform.isAndroid ? "android" : "ios"
          ..vars.deviceId = appPreference.deviceID
          ..vars.picture = sendImageFile
          ..vars.preferredLanguage = appPreference.preferredLanguage
          ..vars.build());
        FerryLoggerClient.makeRequest(req).listen((response) {
          if (response.data != null) {
            var res = response.data as GcreateUserData;
            var data = res.createUser;
            if (data != null) {
              if (data.status == 200) {
                var result = data.result;
                appPreference.accessToken = result?.userToken;
                authToken = result?.userToken;
                appPreference.userID = result?.userId;
                appPreference.firstName = result?.user?.firstName;
                appPreference.phoneNumber = result?.phoneNumber;
                appPreference.dialCode = phoneDialCode;
                appPreference.countryCode = countryCode;
                appPreference.preferredLanguage =
                    result?.user?.preferredLanguage ?? "en";
                navigator!.navigateScreen(AuthScreen.moveToHome, "");
              } else if (response.data?.createUser!.status == 400) {
                isSignUpLoading.value = false;
                showSnackBar(
                    response.data?.createUser!.errorMessage ??
                        "some_thing_error".tr,
                    context);
              } else {
                isSignUpLoading.value = false;
                showSnackBar("some_thing_error".tr, context);
              }
            } else {
              isSignUpLoading.value = false;
              showSnackBar("some_thing_error".tr, context);
            }
          } else {
            isSignUpLoading.value = false;
            showSnackBar("some_thing_error".tr, context);
          }
        });
      } catch (e) {
        checkNetwork(context, () {
          createUser(context);
        });
      }
    }
  }

  getAddressFromLatLng(
      BuildContext context, double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    var name = (placemarks.first.name != null && placemarks.first.name != "")
        ? "${placemarks.first.name}, "
        : "";
    var locality =
        (placemarks.first.locality != null && placemarks.first.locality != "")
            ? "${placemarks.first.locality}, "
            : "";
    var subAdministrativeArea =
        (placemarks.first.subAdministrativeArea != null &&
                placemarks.first.subAdministrativeArea != "")
            ? "${placemarks.first.subAdministrativeArea}, "
            : "";
    var administrativeArea = (placemarks.first.administrativeArea != null &&
            placemarks.first.administrativeArea != "")
        ? "${placemarks.first.administrativeArea}, "
        : "";
    var country =
        (placemarks.first.country != null && placemarks.first.country != "")
            ? "${placemarks.first.country}, "
            : "";
    var postalCode = (placemarks.first.postalCode != null &&
            placemarks.first.postalCode != "")
        ? "${placemarks.first.postalCode}"
        : "";
    var locationFromLatLng = name +
        locality +
        subAdministrativeArea +
        administrativeArea +
        country +
        postalCode;
  }
}
