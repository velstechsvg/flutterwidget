import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/widgets/handy_text.dart';
import 'package:yottachat/widgets/svg_shadow.dart';

import '../config/client.dart';
import '../constant.dart';
import '../resources/app_images.dart';
import 'country_code_picker/function.dart';

class BottomButton extends GetView {
  final String buttonText;
  final String imagePath;
  final bool? isLoading;
  final bool? isBottomSheet;
  final double? width;
  final bool disablePadding;
  final BoxDecoration? decoration;
  final Color buttonTextColor;

  const BottomButton({
    Key? key,
    this.buttonText = "",
    this.imagePath = "",
    this.isLoading = false,
    this.isBottomSheet = false,
    this.width,
    this.disablePadding = false,
    this.decoration,
    this.buttonTextColor = AppColors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("BottomButton isLoading ${isLoading}");
    return SimpleShadow(
      opacity: 0.3,
      color: AppColors.primaryColor,
      child: Container(
          alignment: Alignment.center,
          margin: pad(
              start: disablePadding ? 0 : 20,
              end: disablePadding ? 0 : 20,
              bottom: isBottomSheet != null && isBottomSheet! ? 0 : 20),
          width: width ?? MediaQuery.of(context).size.width,
          height: AppDimen.button_height,
          decoration: decoration ??
              BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
          child: isLoading!
              ? Container(
                  height: 20,
                  width: 20,
                  child: const CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.0,
                  ),
                )
              : [
                  Text(
                    buttonText,
                    style: TextStyle(
                        color: buttonTextColor,
                        fontSize: AppDimen.textSize_18,
                        fontWeight: AppFont.medium),
                  ),
                  8.toWidth(),
                  SvgPicture.asset(
                    leftArrowSvg,
                    color: AppColors.white,
                    height: AppDimen.textSize_12,
                    width: AppDimen.textSize_12,
                    matchTextDirection: true,
                  ).toPad(
                      top: appPreference.preferredLanguage == "ru" ? 3.0 : 0.0)
                ].toRow(mainAxisSize: MainAxisSize.min)),
    );
  }
}

Widget CancelButton({String? buttonText}) {
  return InkWell(
    onTap: () => Get.back(),
    child: Container(
      height: 50,
      padding: pad(start: 20, end: 20),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 1, color: AppColors.white)),
      alignment: AlignmentDirectional.center,
      child: CustomText(
          text: buttonText ?? "cancel".tr,
          color: AppColors.primaryColor,
          fontWeight: AppFont.medium,
          size: AppDimen.textSize_18),
    ),
  );
}
