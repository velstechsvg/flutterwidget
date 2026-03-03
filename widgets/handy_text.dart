import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';

class CustomText extends GetView{
  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final bool isSoftWrap;
  final TextOverflow overflow;
  final dynamic maxLines;

   const CustomText({Key? key,
    required this.text,
    this.size = AppDimen.textSize_16,
    this.fontWeight = AppFont.regular,
    this.color = AppColors.secondaryTextColor,
    this.textAlign = TextAlign.start,
    this.isSoftWrap = true,
    this.overflow = TextOverflow.visible,
     this.maxLines
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    return Text(
      text,
      style: TextStyle(
          color: color,
          letterSpacing: -0.5,
          fontSize: size,
          fontFamily: AppFont.font,
          fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      softWrap: isSoftWrap,
      overflow: overflow,

      maxLines: maxLines ?? defaultTextStyle.maxLines,
    );
  }

}

Widget showCustomTextField({
  TextEditingController? textEditingController,
  TextInputType? textInputType = TextInputType.text,
  bool? isDigitOnly = false,
  bool? isEditable = true,
  int? characterlength = 5000,
  bool maxLines = false,
  String? hintText = '',
  String labelText = '',
  TextInputAction? textInputAction = TextInputAction.done,
  ValueChanged<String>? onSubmitted,
  FocusNode? focusNode,


}){
  List<TextInputFormatter>?  textFormatter = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(characterlength),
  ];
  if(isDigitOnly!)
    textFormatter.add(FilteringTextInputFormatter.digitsOnly);

  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: AppColors.textfieldBorderColor),
      ),
    ),

    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(labelText.isNotEmpty)
        CustomText(text: labelText,size : AppDimen.textSize_14, color: AppColors.chatStatusColor, ),
        TextField(
          autofocus: false,
          maxLines: maxLines ? null : 1,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          controller: textEditingController!,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          enabled:  isEditable ?? true,
          cursorColor: AppColors.black,
          inputFormatters: textFormatter,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText:hintText,
          ),
          style: const TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: AppDimen.textSize_16,

          ),
        ),
      ],
    ),
  );
}


