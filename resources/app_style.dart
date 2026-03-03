import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimen.dart';
import 'app_font.dart';

class AppStyles {

  // Light Theme
  static ThemeData lightTheme(){
    if(Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: AppColors.white,
        ),
      );
    }
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      primaryColor: AppColors.primaryColor,
      primaryColorLight: AppColors.primaryColor,
      primaryColorDark: AppColors.primaryColor,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.black,
        fontFamily: AppFont.font,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.black,
        selectionHandleColor: AppColors.selectionColor,
        selectionColor: AppColors.selectionColor
      ),
      scrollbarTheme: ScrollbarThemeData().copyWith(
        thumbColor: WidgetStateProperty.all(AppColors.textfieldBorderColor),
      ),
      appBarTheme: const AppBarTheme(
        color: AppColors.black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(fontSize:AppDimen.textSize_20,
            fontFamily: AppFont.font,
            fontWeight: FontWeight.w500,color: AppColors.white),
        toolbarTextStyle: TextStyle(fontSize:AppDimen.textSize_20,
            fontFamily: AppFont.font,
            fontWeight: FontWeight.w500,color: AppColors.white),
      ),
      tooltipTheme: const TooltipThemeData(
          textStyle: TextStyle(
            color: AppColors.black,
          )),
      snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppDimen.textSize_16,
            fontFamily: AppFont.font,
          )),
      dialogTheme: const DialogTheme(
        contentTextStyle: TextStyle(
          fontFamily: AppFont.font,
          color: AppColors.black,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(

        hintStyle: TextStyle(
            color: AppColors.textFieldHintColor,
            fontSize: AppDimen.textSize_16,
            fontWeight: FontWeight.w300,
            fontFamily: AppFont.font,

        ),
        labelStyle: TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: AppDimen.textSize_16,
            fontWeight: FontWeight.bold,
            fontFamily: AppFont.font
        ),
        errorStyle: TextStyle(
            color: AppColors.errorRed,
            fontWeight: FontWeight.w300,
            fontSize: AppDimen.textSize_14,
            fontFamily: AppFont.font
        ),


      ),
    );
  }
}