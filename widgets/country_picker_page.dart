import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import '../resources/app_colors.dart';
import '../resources/app_dimen.dart';
import '../screens/views/custom_scaffold.dart';
import 'country_code_picker/country.dart';
import 'country_code_picker/country_code_picker.dart';
import 'handy_text.dart';

class CountryPickerPage extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<Country>? onSelected;
  final bool? isRTL;

  CountryPickerPage(
      {Key? key, this.selectedCountry, this.onSelected, this.isRTL})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      isShowAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          child: CountryPickerWidget(
              searchHintText: "search_here".tr,
              selectedCountry: selectedCountry!,
              isRTL: isRTL ?? false,
              onSelected: onSelected),
        ),
      ),
    );
  }
}

Widget CountryCodeTextField({
  String? flagImage,
  Function? navigateToCountryPicker,
  String? dialCode,
  String? hintText,
  bool? isRTL,
  bool? isEditable,
  TextEditingController? textEditingController,
}) {
  if (isEditable == null) isEditable = true;
  if (hintText == null)
    hintText = "${"enter".tr} ${"your_mobile_no".tr.toLowerCase()}";
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: AppColors.textfieldBorderColor),
      ),
    ),
    child: Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (isEditable!) navigateToCountryPicker!();
          },
          child: Row(
            children: [
              Image.asset(
                flagImage ?? "flags/usa.png",
                package: countryCodePackageName,
                width: 27.0,
              ),
              6.toWidth(),
              CustomText(
                text: dialCode!,
                color: AppColors.secondaryTextColor,
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 23,
          color: AppColors.textfieldBorderColor,
        ).toPad(start: 14),
        14.toWidth(),
        Expanded(
          child: TextField(
            autofocus: false,
            keyboardType: TextInputType.numberWithOptions(signed: true),

            controller: textEditingController,
            enabled: isEditable ?? true,
            cursorColor: AppColors.black,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  Platform.isIOS && isRTL! ? " ${hintText}" : "${hintText}",
            ),
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: AppDimen.textSize_16,
            ),
          ).toPad(top: isRTL! ? 2.0 : 0.0),
        )
      ],
    ),
  );
}
