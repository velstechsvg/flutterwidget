
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/widgets/scroll_behaviour.dart';

import '../resources/app_colors.dart';
import '../resources/app_font.dart';
import '../resources/app_images.dart';
import 'custom_search_field.dart';
import 'handy_text.dart';

void showPickerSheet( {List<dynamic>? dropdownList ,
  String? dropDownType,
  ValueChanged<dynamic>? onItemSelected,
  BaseController? baseController,
  int? selectedItem =0 }){
  if(dropDownType == null)
    dropDownType = "language" ;
  List<Widget>  Widgetlist = List.generate(dropdownList!.length,(index){
    return  InkWell(
        onTap: () {
          debugPrint("selected: ${dropdownList[index]}");
          onItemSelected!(index);
        },
        child: Column(
          children: [
           if(index!=0) const SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: CustomText(text:dropdownList[index]["value"],
                    fontWeight: AppFont.medium,
                    color:  index==0 ? AppColors.primaryColor :AppColors.customTextColor,),
                ),

                if( index ==0)
                  SvgPicture.asset(selectedCountrySvg)
              ],
            ),
            const SizedBox(height: 16,),
            if( index !=dropdownList!.length-1)
              showDivider()

          ],
        )
    ) ;
  });
  baseController!.showBottomSheet(Widgetlist,isDismissible: true);

}