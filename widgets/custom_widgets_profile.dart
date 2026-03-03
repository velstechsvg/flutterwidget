import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import 'custom_search_field.dart';
import 'handy_text.dart';

Widget getNavigationItems(String initialIcon, String navTitle,
    [bool isDividerEnable = false]) {
  return Column(
    children: [
      const SizedBox(
        height: 10.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(initialIcon),
          Expanded(
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 25.0, end: 12.0),
              child: Row(
                children: [
                  Expanded(
                      child: CustomText(
                    text: navTitle,
                    fontWeight: AppFont.medium,
                  )),
                  SvgPicture.asset(
                    rightArrowSvg,
                    matchTextDirection: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10.0,
      ),
      isDividerEnable
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsetsDirectional.only(start: 60.0),
              child: showDivider(),
            ),
    ],
  );
}
