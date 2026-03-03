import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';

class BottomNavBarItemIcon extends GetView {
  final Color? bgColor;
  final String imagePath;
  final bool isSelected;


  const BottomNavBarItemIcon({
    Key? key,
    this.bgColor,
    this.imagePath = "",
    this.isSelected = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(10),
      decoration: BoxDecoration(
          color: isSelected ? AppColors.bottomNavItemBG : AppColors.white,
          borderRadius: BorderRadius.circular(10)),
      child: SvgPicture.asset(
        imagePath,
        color: isSelected
            ? AppColors.black
            : AppColors.gray,
        width: 19,
        height: 20,
      ),
    );
  }
}
