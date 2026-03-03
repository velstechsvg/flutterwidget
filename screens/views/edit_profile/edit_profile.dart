import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/screens/views/edit_profile/edit_profile_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'package:yottachat/widgets/country_code_picker/country.dart';

import '../../../app.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/bottom_button.dart';
import '../../../widgets/country_code_picker/function.dart';
import '../../../widgets/country_picker_page.dart';
import '../../../widgets/handy_text.dart';
import '../../../widgets/profile_image_view.dart';
import '../custom_scaffold.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> implements HomeNavigator {
  final EditProfileController controller = Get.find();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  String _countryflag = 'flags/usa.png';
  RxString _dialCode = '+1'.obs;

  @override
  void initState() {
    controller.navigator = this;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // controller.isLoading.value = true;
    });

    _phoneNumberController.text = appPreference.phoneNumber!;
    _nameController.text = appPreference.firstName!;
    _aboutController.text = appPreference.description!;
    getCountryCode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: _showBodyContent(context),
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    if (screen == HomeScreens.goBack) {
      Get.back();
    }
  }

  @override
  showDialog() {}

  _showBodyContent(BuildContext context) {
    return Stack(children: [
      [
        12.toHeight(),
        CustomText(
          text: 'edit_profile'.tr,
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_24,
        ),
        24.toHeight(),
        Obx(() => [
              controller.showCenterLoading(
                  context, "assets/loader.json", 105.0),
              ProfileImageView(
                controller: controller,
                profileImage: appPreference.profileImage ?? '',
                imageSize: 102,
                isFrom: "editProfilePage",
                isLoading: controller.isLoading.value,
                editingWidget: Container(
                    height: 24.0,
                    width: 24.0,
                    margin: EdgeInsetsDirectional.only(end: 3, bottom: 8),
                    child: SvgPicture.asset(
                      editProfileImageSvg,
                    )),
                onSelected: (image) {
                  appPreference.profileImage = '';
                  controller.imageFile = image;
                  if (controller.isCalledProfilePage.value) {
                    Get.back();
                  }
                  controller
                      .uploadImage(context, controller.imageFile!.path, "")
                      .then((value) {
                    appPreference.profileImage = value;
                    controller.profileImage.value = appPreference.profileImage!;
                  });
                },
                alignment: AlignmentDirectional.topStart,
              ),
            ].toStack()),
        16.toHeight(),
        showCustomTextField(
            textEditingController: controller.firstNameController,
            labelText: 'your_name'.tr,
            hintText: Platform.isIOS && controller.isDirectionRTL(context)
                ? ' ${'your_name'.tr}'
                : 'your_name'.tr),
        24.toHeight(),
        showCustomTextField(
            maxLines: true,
            textEditingController: controller.aboutController,
            labelText: 'about'.tr,
            hintText: Platform.isIOS && controller.isDirectionRTL(context)
                ? ' ${'about'.tr}'
                : 'about'.tr),
        24.toHeight(),
        CustomText(
          text: 'phone_number'.tr,
          size: AppDimen.textSize_14,
          color: AppColors.chatStatusColor,
        ),
        5.toHeight(),
        getPhoneNumberTextField(),
        100.toHeight(),
      ].toScroll().toPad(horizontal: 24),
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: getSubmitButton(context))),
    ]);
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!controller.isProfileUpdate.value) {
          controller.vaildateEdit(context);
        }
      },
      child: Obx(() => BottomButton(
            disablePadding: true,
            buttonText: 'save'.tr,
            isLoading: controller.isProfileUpdate.value,
          )),
    );
  }

  Widget getPhoneNumberTextField() {
    return Obx(() => CountryCodeTextField(
          flagImage: _countryflag,
          dialCode: _dialCode.value,
          isEditable: false,
          isRTL: controller.isDirectionRTL(context),
          textEditingController: _phoneNumberController,
          navigateToCountryPicker: () {},
        ));
  }

  void getCountryCode() async {
    Country country = Country("United States", "flags/usa.png", "US", "+1");
    country =
        (await getCountryByCountryCode(context, appPreference.countryCode!))!;
    _countryflag = country.flag;
    _dialCode.value = country.callingCode;
    _dialCode.refresh();
  }
}
