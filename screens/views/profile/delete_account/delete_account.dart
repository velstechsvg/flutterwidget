import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:yottachat/app.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/screens/views/custom_scaffold.dart';
import 'package:yottachat/screens/views/profile/profile_controller.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import '../../../../widgets/bottom_button.dart';
import '../../../../widgets/handy_text.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DeleteAccountState();
  }
}

class DeleteAccountState extends StatefulWidget {
  const DeleteAccountState({Key? key}) : super(key: key);

  @override
  State<DeleteAccountState> createState() => _DeleteAccountStateState();
}

class _DeleteAccountStateState extends State<DeleteAccountState> {
  @override
  void initState() {
    super.initState();
  }

  final ProfileController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      body: showBodyContent(context),
      appBarBGColor: AppColors.white,
      //isShowAppBar:  !controller.isLoading.value ? true:false,
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget showBodyContent(context) {
    return Stack(
      children: [
        Obx(() => !controller.isLoading.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "manage_your_account".tr,
                    fontWeight: FontWeight.bold,
                    size: AppDimen.textSize_24,
                  ),
                  20.toHeight(),
                  CustomText(
                    text: "delete_account".tr,
                    fontWeight: FontWeight.bold,
                    size: AppDimen.textSize_16,
                  ),
                  5.toHeight(),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.secondaryTextColor,
                        fontWeight: AppFont.medium,
                        fontSize: AppDimen.textSize_16,
                        fontFamily: AppFont.font,
                      ),
                      children: [
                        TextSpan(
                          text: "${"caution".tr}: ",
                          style: const TextStyle(
                            fontWeight: AppFont.bold,
                          ),
                        ),
                        TextSpan(
                          text: "delete_content".trArgs([(App.APP_NAME ?? "")]),
                          style: const TextStyle(
                            fontWeight: AppFont.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  15.toHeight(),
                  InkWell(
                    onTap: () {
                      showExitConfirmPopup(context);
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: CustomText(
                            color: AppColors.primaryColor,
                            text: "delete_permanently".tr,
                            size: AppDimen.textSize_16,
                          ),
                        ),
                        SvgPicture.asset(
                          rightArrowSvg,
                          color: AppColors.primaryColor,
                          matchTextDirection: true,
                        ).toPad(horizontal: 5, top: 2)
                      ],
                    ),
                  ),
                ],
              )
            : controller.showCenterLoading(context))
      ],
    ).toPad(start: 20.0, end: 20.0, top: 20.0);
  }

  showExitConfirmPopup(context) {
    controller.showCommonBottomSheet(
        title: "delete_account_title".tr,
        description: "delete_title".tr,
        OkButtonLabel: "delete".tr,
        OkButtonCallback: () {
          controller.checkNetwork(context, () {
            controller.isLoading.value = true;
            controller.deleteUser(context);
          });
          Get.back();
        });
  }
}
