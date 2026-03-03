import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:built_collection/built_collection.dart';

import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../config/client.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/bottom_button.dart';
import '../../../widgets/country_code_picker/country.dart';
import '../../../widgets/country_picker_page.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';
import 'new_contact_controller.dart';
import 'package:yottachat/constant.dart' as Constants;

class NewContact extends StatefulWidget {
  const NewContact({Key? key}) : super(key: key);

  @override
  State<NewContact> createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> implements HomeNavigator {
  final NewContactController controller = Get.find();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final RxString _countryFlag = 'flags/usa.png'.obs;

  @override
  void initState() {
    controller.navigator = this;
    _countryFlag.value = Constants.country.flag;
    controller.dialCode.value = Constants.country.callingCode ?? "+1";
    if (Get.arguments["editContact"] != null) {
      controller.contactsList.value = Get.arguments["editContact"];
      controller.firstNameController.text =
          controller.contactsList.first['firstName'];
      controller.lastNameController.text =
          controller.contactsList.first['lastName'];
      controller.dialCode.value = controller.contactsList.first['dialCode'];
      controller.phoneCountryCode.value =
          controller.contactsList.first['phoneCountryCode'];
      controller.phoneNumberController.text =
          controller.contactsList.first['phoneNumber'];
      getCountryCode();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: _showBodyContent(context),
      isShowAppBar: true,
      action: [
        InkWell(
            onTap: () {
              showDeleteConfirmPopup(context);
            },
            child: Obx(() => controller.contactsList.isNotEmpty
                ? SvgPicture.asset(
                    deleteChatSvg,
                    matchTextDirection: true,
                  ).toPad(end: 25)
                : const SizedBox.shrink()))
      ].toRow(),
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    // TODO: implement navigateScreen
    throw UnimplementedError();
  }

  @override
  showDialog() {}

  _showBodyContent(BuildContext context) {
    return Stack(children: [
      [
        12.toHeight(),
        CustomText(
          text: controller.contactsList.value.isNotEmpty
              ? 'edit_contact'.tr
              : 'new_contact'.tr,
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_24,
        ),
        16.toHeight(),
        showCustomTextField(
            textEditingController: controller.firstNameController,
            textInputAction: TextInputAction.next,
            focusNode: _firstNameFocusNode,
            labelText: 'first_name'.tr,
            onSubmitted: (value) {
              _firstNameFocusNode.unfocus();
              _lastNameFocusNode.requestFocus();
            },
            hintText: Platform.isIOS && controller.isDirectionRTL(context)
                ? " ${'enter_first_name'.tr}"
                : 'enter_first_name'.tr),
        24.toHeight(),
        showCustomTextField(
            textEditingController: controller.lastNameController,
            textInputAction: TextInputAction.done,
            focusNode: _lastNameFocusNode,
            labelText: 'last_name'.tr,
            hintText: Platform.isIOS && controller.isDirectionRTL(context)
                ? " ${'enter_last_name'.tr}"
                : 'enter_last_name'.tr),
        24.toHeight(),
        CustomText(
            text: 'phone_number'.tr,
            size: AppDimen.textSize_14,
            color: AppColors.chatStatusColor),
        5.toHeight(),
        getPhoneNumberTextField(),
        120.toHeight(),
      ].toScroll().toPad(horizontal: 24),
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: getSubmitButton(context)))
    ]);
  }

  Widget getPhoneNumberTextField() {
    return Obx(() => CountryCodeTextField(
          flagImage: _countryFlag.value,
          dialCode: controller.dialCode.value,
          isEditable: controller.contactsList.isEmpty,
          isRTL: controller.isDirectionRTL(context),
          hintText: Platform.isIOS && controller.isDirectionRTL(context)
              ? " ${"enter".tr} ${"phone_number".tr.toLowerCase()}"
              : "${"enter".tr} ${"phone_number".tr.toLowerCase()}",
          textEditingController: controller.phoneNumberController,
          navigateToCountryPicker: () {
            Get.to(
                () => CountryPickerPage(
                    selectedCountry: controller.country.flag,
                    isRTL: controller.isDirectionRTL(context),
                    onSelected: (country) {
                      controller.country = country;
                      _countryFlag.value = controller.country.flag;
                      controller.dialCode.value =
                          controller.country.callingCode;
                      Get.back();
                    }),
                routeName: "/pickerPage");
          },
        ));
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        _validateInputs();
      },
      child: Obx(() => BottomButton(
            disablePadding: true,
            buttonText: 'save'.tr,
            isLoading: controller.isLoading.value,
          )),
    );
  }

  void _validateInputs() {
    if (!controller.firstNameController.text.isBlank!) {
      if (!controller.phoneNumberController.text.isBlank!) {
        controller.checkNetwork(context, () {
          controller.addUserContacts(context);
        });
      } else {
        controller.showSnackBar("please_enter_phone_number".tr, context);
      }
    } else {
      controller.showSnackBar("please_enter_first_name".tr, context);
    }
  }

  showDeleteConfirmPopup(context) {
    controller.showCommonBottomSheet(
        title: "delete_contact".tr,
        description: "are_you_sure_want_to_delete_contact".tr,
        OkButtonLabel: "delete".tr,
        OkButtonCallback: () {
          List<int> listId = [];
          listId.add(controller.contactsList.first['contactId']);
          ListBuilder<int?> builderList = ListBuilder<int?>(listId);
          controller.checkNetwork(context, () {
            controller.deleteUserContacts(context, builderList);
          });
        });
  }

  void getCountryCode() async {
    Country? country =
        const Country("United States", "flags/usa.png", "US", "+1");
    country = (await getCountryByCountryCode(
        context, controller.phoneCountryCode.value));
    _countryFlag.value = country?.flag ?? "flags/usa.png";
  }
}
