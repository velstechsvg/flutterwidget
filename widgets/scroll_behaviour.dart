import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../resources/app_colors.dart';
import 'custom_popup_menu.dart';
import 'custom_search_field.dart';

class ListViewScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

showMenuItem(
    {required Function onSelected, List<String>? menuItems, isShowArrow}) {
  final children = <PopupMenuEntry>[];

  for (int i = 0; i < menuItems!.length; i++) {
    children.add(PopupMenuItem(
        value: menuItems![i],
        //i,

        height: 50,
        padding:
            const EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0, right: 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                      child: CustomText(
                    text: menuItems![i],
                    fontWeight: AppFont.medium,
                  )),
                  if (isShowArrow)
                    SvgPicture.asset(
                      rightArrowSvg,
                      matchTextDirection: true,
                    )
                ],
              ),
            ),
            if (i < (menuItems!.length - 1)) showDivider(),
          ],
        )));
  }

  return PopupMenuButton(
      offset: const Offset(0, 30),
      padding: const EdgeInsets.all(0.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      child: Container(
          width: 35,
          alignment: AlignmentDirectional.centerEnd,
          child: SvgPicture.asset(menuIconSvg)),
      onSelected: (value) {
        onSelected.call(value);
      },
      itemBuilder: (context) => children);
}

showPopupMenu(
    {required Function onSelected,
    List<String>? menuItems,
    bool? isShowArrow,
    required CustomPopupMenuController popupcontroller}) {
  final children = <Widget>[];
  for (int i = 0; i < menuItems!.length; i++) {
    children.add(InkWell(
        onTap: () {
          print(
              "_popupMenuController.menuIsShowing: ${popupcontroller.menuIsShowing} =");
          popupcontroller.toggleMenu();
          onSelected.call(menuItems![i], popupcontroller);
        },
        child: Container(
          height: 46,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              16.toWidth(),
              Expanded(
                  child: CustomText(
                text: menuItems![i],
                fontWeight: AppFont.medium,
              )),
              if (isShowArrow != null && isShowArrow) 16.toWidth(),
              if (isShowArrow != null && isShowArrow)
                SvgPicture.asset(
                  rightArrowSvg,
                  matchTextDirection: true,
                ),
              SizedBox(
                width: isShowArrow == null || !isShowArrow ? 40 : 16,
              ),
            ],
          ),
        )));
    if (menuItems!.length > 1 && i < menuItems!.length - 1) {
      children.add(showDivider());
    }
  }

  return CustomPopupMenu(
      menuBuilder: () => Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
      pressType: PressType.singleClick,
      controller: popupcontroller,
      showArrow: false,
      verticalMargin: 9,
      horizontalMargin: 25,
      barrierColor: Colors.transparent,
      child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          alignment: AlignmentDirectional.center,
          child: SvgPicture.asset(
            menuIconSvg,
          )));
}
