import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/screens/views/base_controller.dart';

import 'country_code_picker/function.dart';
import 'handy_text.dart';

class InputDoneView extends GetView {
 late BaseController controller ;
 Widget parentWidget ;
  InputDoneView(BaseController controller, {required this.parentWidget} ){
    this.controller = controller;
  }
  @override
  Widget build(BuildContext context) {
   return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        parentWidget,
        Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 0.0,
            left: 0.0,
            child: MediaQuery.of(context).viewInsets.bottom >= 175.0
                ? _showDoneView(context)
                : 0.toHeight(),
        ),
      ]),
    );

  }

 Widget _showDoneView(BuildContext context){
   return Container(
      width: double.infinity,
      color: AppColors.keyboardColor,
      child: Align(
        alignment: controller.isDirectionRTL(context) ?Alignment.topLeft :  Alignment.topRight,
        child: CupertinoButton(
          padding: pad(end: 24),
          onPressed: () {
            if (FocusManager.instance.primaryFocus != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Text(
              "done".tr,
              style: const TextStyle(color: AppColors.black,fontWeight: FontWeight.bold)
          ),
        ).toPad(top: 4.0),
      ),
    );
  }
}

showEmptyView({emptyImage, emptyText, context}) {
  return Expanded(
    child: Container(
        alignment: AlignmentDirectional.center,
        padding: pad(start: 26, end: 26,bottom: ((MediaQuery.of(context).size.height-120)/2)-200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(emptyImage),
            23.toHeight(),
            CustomText(text: emptyText, color: AppColors.textFieldHintColor,textAlign: TextAlign.center,),
          ],
        )
    ),
  );
}


