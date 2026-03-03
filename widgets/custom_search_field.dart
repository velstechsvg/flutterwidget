
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import '../resources/app_images.dart';

class CustomSearchField extends GetView{
  final TextStyle searchInputStyle;
  final bool focusSearchBox;
  final bool isRTL;
   final String searchHintText;
    TextEditingController controller= new TextEditingController();
  final ValueChanged<String>? onChanged;
   Widget suffixIcon;


    CustomSearchField({Key? key,
     this.searchInputStyle = const TextStyle(fontSize: 16),
     this.focusSearchBox = false,
     this.isRTL = false,
     this.searchHintText = "",
     this.onChanged,
      required  this.suffixIcon,
    required this.controller ,



  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   TextField(
        style: searchInputStyle,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        autofocus: focusSearchBox,
        contextMenuBuilder: (context,editableTextState){
          final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
          debugPrint("contextMenuBuilder: ${buttonItems}");
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        selectionControls: customMaterialTextSelectionControls(Colors.transparent),
        inputFormatters: <TextInputFormatter> [
          LengthLimitingTextInputFormatter(70),
        ],
        decoration: InputDecoration(
          filled: true,
            fillColor: AppColors.searchFieldBoxColor,
          isCollapsed: true,

          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(6),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: pad(top:14, bottom: 15.0,start: 5,end: 10),
          isDense: true,

          hintText:Platform.isIOS && isRTL! ? " ${searchHintText}" : "${searchHintText}",
          prefixIcon: Container(
               margin:   pad(start:8),
              child: SvgPicture.asset(searchSvg,fit: BoxFit.scaleDown,)
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 30,
          ),

          suffixIconConstraints: BoxConstraints(
            minWidth: 30,
          ),
        ),
        textInputAction: TextInputAction.done,
        controller: controller,
        onChanged: onChanged,
      ).toPad(horizontal: 24);
  }

}

class customMaterialTextSelectionControls extends MaterialTextSelectionControls {
  customMaterialTextSelectionControls(this.handleColor);
  final Color handleColor;
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) =>
      TextSelectionTheme(
          data: TextSelectionThemeData(selectionHandleColor: handleColor),
          child: Builder(builder: builder));
  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return _wrapWithThemeData((BuildContext context) =>
        super.buildHandle(context, type, textLineHeight));
  }
}

Widget showDivider(){
  return const Divider(height: 1.0, thickness: 1.0, color: AppColors.textfieldBorderColor);
}

