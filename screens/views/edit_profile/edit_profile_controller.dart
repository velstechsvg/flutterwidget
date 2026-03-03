import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/graphql/settings/update_profile_settings/__generated__/updateProfileSettings.data.gql.dart';
import 'package:yottachat/graphql/settings/update_profile_settings/__generated__/updateProfileSettings.req.gql.dart';
import 'package:yottachat/graphql/update_user_profile/__generated__/update_profile.data.gql.dart';
import 'package:yottachat/graphql/update_user_profile/__generated__/update_profile.req.gql.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import '../../../app.dart';
import '../camera_screen/camera_controller.dart';
import '../profile/profile_page.dart';

class EditProfileController extends BaseController {
  HomeNavigator? navigator;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  var isProfileUpdate = false.obs;
  var isCalledProfilePage = false.obs;
  var profileImage = "".obs;
  var cameras;

  @override
  void onReady() {
    firstNameController.text = appPreference.firstName!;
    availableCameras().then((value) {
      cameras = value;
    });
    if (appPreference.description != null) {
      aboutController.text = appPreference.description!;
    } else {
      aboutController.text = "${App.APP_NAME} newbie :)";
    }
    emailController.text = appPreference.email!;
    phoneNumberController.text =
        appPreference.dialCode! + "  ${appPreference.phoneNumber!}";
    profileImage.value = appPreference.profileImage!;
    super.onReady();
  }

  @override
  void onResumed() {}

  @override
  void onHidden() {}

  getCountryDetails(context) async {
    country =
        (await getCountryByCountryCode(context, appPreference.countryCode!))!;
  }

  vaildateEdit(BuildContext context) {
    if (firstNameController.text.trim().isNotEmpty &&
        aboutController.text.trim().isNotEmpty) {
      isProfileUpdate.value = true;
      updateProfile(context);
    } else {
      isProfileUpdate.value = false;
      showSnackBar('please_enter_About'.tr,context);
    }
  }

  updateProfile(context) {
    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GUpdateProfileSettingsReq((b) => b
      ..vars.deviceId = appPreference.deviceID
      ..vars.deviceType = appType
      ..vars.fieldName = "firstName"
      ..vars.fieldValue = firstNameController.text
      ..vars.build());

    FerryLoggerClient.makeRequest(params).listen((res) async {
      try {
        var response = res.data as GUpdateProfileSettingsData;
        if (response.updateProfileSettings!.status == 200) {
          appPreference.firstName = firstNameController.text;
          updateDescription(context);
        } else if (response.updateProfileSettings!.status == 400) {
          isProfileUpdate.value = false;
          showSnackBar(response.updateProfileSettings!.errorMessage!, context);
        } else {
          isProfileUpdate.value = false;
          showUserLogout(
              response.updateProfileSettings!.errorMessage!, context);
        }
      } catch (e) {
        isProfileUpdate.value = false;
        checkNetwork(context, () {
          isProfileUpdate.value = true;
          updateProfile(context);
        });
      }
    });
  }

  updateDescription(context) {
    String appType = Platform.isAndroid ? "android" : "ios";
    final params = GUpdateProfileSettingsReq((b) => b
      ..vars.deviceId = appPreference.deviceID
      ..vars.deviceType = appType
      ..vars.fieldName = "description"
      ..vars.fieldValue = aboutController.text
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      try {
        if (res != null) {
          var response = res.data as GUpdateProfileSettingsData;
          if (response.updateProfileSettings!.status == 200) {
            appPreference.firstName = firstNameController.text;
            appPreference.description = aboutController.text;
            isProfileUpdate.value = false;
            Get.back();
          } else if (response.updateProfileSettings!.status == 400) {
            isProfileUpdate.value = false;
            showSnackBar(
                response.updateProfileSettings!.errorMessage!, context);
          } else {
            isProfileUpdate.value = false;
            showUserLogout(
                response.updateProfileSettings!.errorMessage!, context);
          }
        }
      } catch (e) {
        isProfileUpdate.value = false;
        checkNetwork(context, () {
          isProfileUpdate.value = true;
          updateDescription(context);
        });
      }
    });
  }
}
