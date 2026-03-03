import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';

class AddButton extends GetView {
  final String buttonText;
  final String imagePath;
  final bool? isLoading;



  const AddButton({
    Key? key,
    this.buttonText = "",
    this.imagePath ="",
    this.isLoading = false,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsetsDirectional.only(start: 20,end: 20, bottom: 20),
        padding: const EdgeInsetsDirectional.only(start: 20,end: 15),
        height: 45.0,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: isLoading!? Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: const CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 2.0,
          ),
        ): Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(buttonText, style: const TextStyle(color: AppColors.white, fontSize: AppDimen.textSize_16 , fontWeight: FontWeight.bold),),
            const SizedBox(width: 10),
            imagePath.isNotEmpty ?
            SvgPicture.asset(imagePath, color: AppColors.white,)
                : const SizedBox.shrink()
          ],
        ));
  }
}
