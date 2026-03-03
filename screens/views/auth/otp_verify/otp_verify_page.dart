import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/screens/binding/home_binding.dart';
import 'package:yottachat/screens/views/auth/signup/signup_view.dart';
import 'package:yottachat/widgets/bottom_button.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';
import 'package:yottachat/widgets/show_done_view.dart';

import '../../../../utils/click_utils.dart';
import '../../custom_scaffold.dart';
import '../../explore/explore_view.dart';
import '../auth_navigator.dart';
import 'otp_verify_page_controller.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({Key? key}) : super(key: key);

  @override
  _OtpVerifyPageState createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage>
    implements AuthNavigator {
  final OtpVerifyController controller = Get.find();
  Map<String, dynamic>? pickerItem;
  var argumentsArr = Get.arguments;

  @override
  void initState() {
    controller.navigator = this;
    controller.passingArg = Get.arguments;
    controller.phoneNumber = controller.passingArg["phoneNumber"];
    controller.dialCode = controller.passingArg["dialCode"];
    controller.countryCode = controller.passingArg["countryCode"];
    controller.pinvalue = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: showBodyContent(context),
      ),
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget showBodyContent(context) {
    return InputDoneView(controller,
        parentWidget: [
          [
            20.toHeight(),
            CustomText(
              text: "send_you_a_code".tr,
              size: AppDimen.textSize_24,
              fontWeight: FontWeight.bold,
            ),
            7.toHeight(),
            CustomText(
              text: "enter_code".tr,
              size: AppDimen.textSize_16,
              color: AppColors.secondaryTextColor,
              fontWeight: AppFont.regular,
            ),
            CustomText(
              text: '${controller.dialCode} ${controller.phoneNumber}',
              size: AppDimen.textSize_16,
              color: AppColors.secondaryTextColor,
              fontWeight: AppFont.medium,
            ),
            25.toHeight(),
            PinInputTextField(
              toolbarOptions: const ToolbarOptions(
                selectAll: false,
                copy: false,
                paste: true,
              ),
              pinLength: 4,
              focusNode: controller.pinInputFocus,
              controller: controller.pinEditingController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
              enabled: true,
              onChanged: (pin) {
                controller.pinvalue = pin;
              }, decoration: _pinDecoration(),
            ),
            35.toHeight(),
            resentOTP(context),
            35.toHeight(),
            getDefaultOTP(context),
          ].toScroll().toPad(horizontal: 24).toStretch(isFillSpace: false),
          getSubmitButton(context)
        ].toColumn());
  }

  PinDecoration _pinDecoration() {
    return UnderlineDecoration(
    colorBuilder: const FixedColorBuilder(AppColors.textfieldBorderColor),
    hintText: "0000",
    hintTextStyle: const TextStyle(
        color: AppColors.pinInputTextFieldHintTextColor,
        fontSize: AppDimen.textSize_24),
    bgColorBuilder: const FixedColorBuilder(AppColors.white),
    lineHeight: 1.5);
  }

  Widget resentOTP(BuildContext context) {
    return [
      CustomText(
        text: 'did_not_receive_otp'.tr,
        fontWeight: AppFont.medium,
        size: AppDimen.textSize_14,
      ),
      3.toWidth(),
      InkWell(
        onTap: () {
          closeKeyboard();
          controller.isLoading.value = true;
          controller.pinEditingController.clear();
          controller.pinvalue = "";
          controller.checkNetwork(context, () {
            controller.sendVerificationOTP(context);
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          child: CustomText(
            text: 'resend'.tr,
            fontWeight: AppFont.medium,
            size: AppDimen.textSize_14,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    ].toRow();
  }

  Widget getDefaultOTP(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.pinEditingController.text = "1234";
        controller.pinvalue = "1234";
        closeKeyboard();
      },
      child: Center(
        child: Container(
            padding: pad(h: 11.0, w: 16.0),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.0),
              color: AppColors.defaultOtpBGColor,
            ),
            child: CustomText(
              text: 'your_otp_is_1234'.tr,
              size: AppDimen.textSize_14,
              fontWeight: AppFont.medium,
              color: AppColors.primaryColor,
            )),
      ),
    );
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () {
          ClickUtils.debounce(() {
            controller.checkNetwork(context, () {
              controller.vaildateOTP(context);
            });
          });
      },
      child: Obx(() => BottomButton(
            buttonText: 'next'.tr,
            isLoading: controller.isLoading.value,
          )),
    );
  }

  @override
  navigateScreen(AuthScreen screen, String param) {
    if (screen == AuthScreen.signup) {
      Get.to(() => const SignUpView(),
          arguments: {
            "phoneNumber": controller.phoneNumber,
            "phoneDialCode": controller.dialCode,
            "phoneCountryCode": controller.countryCode
          },
          routeName: "/signUpPage");
    } else if (screen == AuthScreen.moveToHome) {
      Get.offAll(ExploreView(),
          binding: HomeBinding(), routeName: "/home_page");
    }
  }

  @override
  showDialog() {}

  closeKeyboard() {
    controller.pinInputFocus.unfocus();
  }
}
