import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import 'handy_text.dart';

Widget getNavigationItemsHelp(
    String initialIcon, String navTitle, String navDesc) {
  return Container(
    padding: pad(w: 18, h: 14),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textfieldBorderColor,
          width: 1,
        )),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    initialIcon,
                  ),
                  5.toWidth(),
                  CustomText(
                    text: navTitle,
                    fontWeight: AppFont.medium,
                  )
                ],
              ),
              5.toHeight(),
              CustomText(text: navDesc)
            ],
          ),
        ),
        SvgPicture.asset(
          rightArrowSvg,
          matchTextDirection: true,
        )
      ],
    ),
  );
}
