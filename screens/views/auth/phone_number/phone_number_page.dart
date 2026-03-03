import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/app_localizations.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/screens/binding/home_binding.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_page.dart';
import 'package:yottachat/screens/views/auth/otp_verify/otp_verify_page.dart';
import 'package:yottachat/screens/views/auth/phone_number/phone_number_controller.dart';
import 'package:yottachat/widgets/bottom_button.dart';
import 'package:yottachat/widgets/country_code_picker/country.dart';
import 'package:yottachat/widgets/launguage_picker_sheet.dart';
import 'package:yottachat/widgets/scroll_behaviour.dart';
import 'package:yottachat/widgets/show_done_view.dart';

import '../../../../resources/app_images.dart';
import '../../../../widgets/country_code_picker/function.dart';
import '../../../../widgets/country_picker_page.dart';
import '../../../../widgets/handy_text.dart';
import '../../../binding/auth_binding.dart';
import '../../custom_scaffold.dart';
import '../auth_navigator.dart';

class PhoneNumberPage extends StatefulWidget {
  String? from = "";

  PhoneNumberPage({Key? key, this.from}) : super(key: key);

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    implements AuthNavigator {
  final PhoneNumberController controller = Get.find();
  final listViewScrollController = ScrollController();

  @override
  void initState() {
    controller.navigator = this;
    controller.passingArg = Get.arguments;
    controller.phoneNumberController.text = "";
    Future.delayed(const Duration(milliseconds: 300))
        .then((value) => getCountryCode());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: showBodyContent(context),
        ),
        isShowAppBar: true,
        isBackButtonNeeded: true,
        resizeToAvoidBottomInset: false,
        customAppBarFunction: () => navigateScreen(AuthScreen.getStarted, ""),
      ),
    );
  }

  Widget showBodyContent(context) {
    return InputDoneView(
      controller,
      parentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ScrollConfiguration(
              behavior: ListViewScrollBehavior(),
              child: ListView(
                padding: const EdgeInsetsDirectional.only(
                    start: 25.0, end: 25.0, top: 0),
                controller: listViewScrollController,
                children: <Widget>[
                  const SizedBox(
                    height: 14.0,
                  ),
                  CustomText(
                      text: "${"your_mobile_no".tr}",
                      size: AppDimen.textSize_24,
                      fontWeight: FontWeight.bold),
                  const SizedBox(
                    height: 7.0,
                  ),
                  CustomText(
                    text: "${"phone_no_content".tr}",
                    size: AppDimen.textSize_16,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  getPhoneNumberTextField(),
                  const SizedBox(height: 25.0),
                  getLanguageWidget(),
                ],
              ),
            ),
          ),
          getInstruction(context),
          SizedBox(height: 15.0),
          getSubmitButton(context)
        ],
      ),
    );
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!controller.isLoading.value) {
          FocusScope.of(context).unfocus();
          controller.checkNetwork(context, () {
            controller.validatePhoneNumber(context);
          });
        }
      },
      child: Obx(() => BottomButton(
            buttonText: 'next'.tr,
            isLoading: controller.isLoading.value,
          )),
    );
  }

  Widget getLanguageWidget() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            showPickerSheet(
                dropdownList: controller.launguages,
                dropDownType: 'launguage',
                baseController: controller,
                onItemSelected: (value) {
                  Map<String, dynamic>? _pickerItem =
                      controller.launguages[value];
                  if (_pickerItem != null) {
                    controller.appPreference.preferredLanguage =
                        _pickerItem["id"];
                    controller.languageCodeObs.value = _pickerItem["discode"];
                    LocalizationService().changeLocale(_pickerItem["id"]);
                    controller.launguages.clear();
                    controller.formLanguageArray();
                  }
                  Get.back();
                });
          },
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: AppColors.textfieldBorderColor, width: 1.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  languageIconSvg,
                  height: 18.0,
                  width: 18.0,
                  color: AppColors.black,
                ),
                const SizedBox(
                  width: 5,
                ),
                Obx(
                  () => CustomText(
                    text: controller.languageCodeObs.value,
                    size: AppDimen.textSize_16,
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                SizedBox(
                    width: 12,
                    height: 7,
                    child: SvgPicture.asset(downArrowSvg)),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        CustomText(
          text: "*".tr,
          color: AppColors.errorRed,
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 30.0),
            alignment: AlignmentDirectional.topStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CustomText(
                text: "choose_your_primary_language".tr,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                size: AppDimen.textSize_14,

                //  maxLines: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  navigateScreen(AuthScreen screen, String param) {
    if (screen == AuthScreen.otpPage) {
      Get.to(() => const OtpVerifyPage(),
          binding: AuthBinding(),
          arguments: {
            "phoneNumber": controller.phoneNumberController.text.toString(),
            "countryCode": controller.countryCode,
            "dialCode": controller.dialCode.value,
            "country": controller.country
          },
          routeName: "/otpVerifyPage");
    } else if (screen == AuthScreen.getStarted) {
      if (widget.from == "getStartedPage") {
        isShowPopup = false;
        Get.to(() => const GetStartedPage(),
            binding: AuthBinding(),
            arguments: {"isLogin": "false"},
            routeName: "/getStartedPage");
      } else {
        Get.back();
      }
    }
  }

  @override
  showDialog() {}

  getInstruction(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, right: 28.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "*".tr,
            color: AppColors.errorRed,
          ),
          Flexible(
            child: CustomText(
              text: "by_continuing_you_may_get_sms_for_verification".tr,
              textAlign: TextAlign.start,
              size: AppDimen.textSize_14,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhoneNumberTextField() {
    return Obx(() => CountryCodeTextField(
          flagImage: controller.selectedFlag.value,
          dialCode: controller.dialCode.value,
          isRTL: controller.isDirectionRTL(context),
          textEditingController: controller.phoneNumberController,
          navigateToCountryPicker: () {
            Get.to(
                () => CountryPickerPage(
                    selectedCountry: controller.country.flag,
                    isRTL: controller.isDirectionRTL(context),
                    onSelected: (country) {
                      controller.country = country;
                      controller.countryCode = controller.country.countryCode;
                      controller.dialCode.value =
                          controller.country.callingCode;
                      controller.selectedFlag.value = controller.country.flag;
                      Get.back();
                    }),
                routeName: "/pickerPage");
          },
        ));
  }

  getCountryCode() async {
    Country? country =
        const Country("United States", "flags/usa.png", "US", "+1");
    controller.country = country;
    controller.selectedFlag.value = country.flag;
    controller.dialCode.value = country.callingCode;
    controller.countryCode = country.countryCode;
    controller.dialCode.refresh();
  }
}
