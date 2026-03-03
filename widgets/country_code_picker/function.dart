import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../resources/app_colors.dart';
import '../scroll_behaviour.dart';
import 'country.dart';
import 'country_code_picker.dart';
import 'package:intl/intl.dart' as intl;

///This function returns list of countries
Future<List<Country>> getCountries(BuildContext context) async {
  String rawData = await DefaultAssetBundle.of(context)
      .loadString('assets/country_codes.json');
  final parsed = json.decode(rawData.toString()).cast<Map<String, dynamic>>();
  return parsed.map<Country>((json) => new Country.fromJson(json)).toList();
}

///This function returns an user's current country. User's sim country code is matched with the ones in the list.
///If there is no sim in the device, first country in the list will be returned.
Future<Country> getDefaultCountry(BuildContext context) async {
  final list = await getCountries(context);
  var currentCountry;
  try {
    final countryCode = await FlutterSimCountryCode.simCountryCode;
    debugPrint("getDefaultCountry: ${countryCode}");
    currentCountry =
        list.firstWhere((element) => element.countryCode == countryCode);
  } catch (e) {
    currentCountry = list.first;
  }
  return currentCountry;
}

List<BoxShadow> getBoxShadow([shadowColor]) {
  return [
    BoxShadow(
        color: shadowColor ?? AppColors.primaryColor.withAlpha(50),
        spreadRadius: 1,
        blurRadius: 8,
        offset: Offset(0, 3))
  ];
}

EdgeInsetsGeometry pad({
  double start = 0,
  double end = 0,
  double top = 0,
  double bottom = 0,
  double? w,
  double? h,
}) {
  return EdgeInsetsDirectional.only(
      start: w ?? start, end: w ?? end, top: h ?? top, bottom: h ?? bottom);
}

///This function returns an country whose [countryCode] matches with the passed one.
Future<Country?> getCountryByCountryCode(
    BuildContext context, String countryCode) async {
  final list = await getCountries(context);
  return list.firstWhere((element) => element.countryCode == countryCode);
}

Future<Country?> getCountryByCallingCode(
    BuildContext context, String countryCode) async {
  final list = await getCountries(context);
  return list.firstWhere((element) => element.callingCode == countryCode);
}

Future<Country?> showCountryPickerSheet(BuildContext context,
    {Widget? title,
    Widget? cancelWidget,
    double cornerRadius: 35,
    bool focusSearchBox: false,
    double heightFactor: 0.9}) {
  assert(heightFactor <= 0.9 && heightFactor >= 0.4,
      'heightFactor must be between 0.4 and 0.9');
  return showModalBottomSheet<Country?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cornerRadius),
              topRight: Radius.circular(cornerRadius))),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFactor,
          child: Column(
            children: <Widget>[
              SizedBox(height: 16),
              Stack(
                children: <Widget>[
                  cancelWidget ??
                      Positioned(
                        right: 8,
                        top: 4,
                        bottom: 0,
                        child: TextButton(
                            child: Text('cancel'.tr),
                            onPressed: () => Navigator.pop(context)),
                      ),
                  Center(
                    child: title ??
                        Text(
                          'choose_region'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: CountryPickerWidget(
                  onSelected: (country) => Navigator.of(context).pop(country),
                ),
              ),
            ],
          ),
        );
      });
}

Future<Country?> showCountryPickerDialog(
  BuildContext context, {
  Widget? title,
  double cornerRadius: 35,
  bool focusSearchBox: false,
}) {
  return showDialog<Country?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(cornerRadius),
            )),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Stack(
                  children: <Widget>[
                    Positioned(
                      right: 8,
                      top: 4,
                      bottom: 0,
                      child: TextButton(
                          child: Text('cancel'.tr),
                          onPressed: () => Navigator.pop(context)),
                    ),
                    Center(
                      child: title ??
                          Text(
                            'choose_region'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    ),
                  ],
                ),
                16.toHeight(),
                Expanded(
                  child: CountryPickerWidget(
                    onSelected: (country) => Navigator.of(context).pop(country),
                  ),
                ),
              ],
            ),
          ));
}

extension DoubleExtension on num {
  Widget toWidth() {
    return SizedBox(
      width: this.toDouble(),
    );
  }

  Widget toHeight() {
    return SizedBox(
      height: this.toDouble(),
    );
  }
}

extension flexWidgetsExtension on List<Widget> {
  Widget toRow(
      {MainAxisSize? mainAxisSize,
      MainAxisAlignment? mainAxisAlignment,
      TextDirection? textDirection,
      VerticalDirection? verticalDirection,
      TextBaseline? textBaseline,
      Clip? clipBehavior,
      CrossAxisAlignment? crossAxisAlignment}) {
    return flexWidget(
        direction: Axis.horizontal,
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        clipBehavior: clipBehavior,
        crossAxisAlignment: crossAxisAlignment);
  }

  Widget toColumn(
      {MainAxisSize? mainAxisSize,
      MainAxisAlignment? mainAxisAlignment,
      TextDirection? textDirection,
      VerticalDirection? verticalDirection,
      TextBaseline? textBaseline,
      Clip? clipBehavior,
      CrossAxisAlignment? crossAxisAlignment}) {
    return flexWidget(
        direction: Axis.vertical,
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        clipBehavior: clipBehavior,
        crossAxisAlignment: crossAxisAlignment);
  }

  Widget toStack(
      {AlignmentGeometry? alignment,
      TextDirection? textDirection,
      StackFit? fit,
      TextBaseline? textBaseline,
      Clip? clipBehavior,
      CrossAxisAlignment? crossAxisAlignment}) {
    return Stack(
      children: this,
      textDirection: textDirection,
      alignment: alignment ?? AlignmentDirectional.topStart,
      clipBehavior: clipBehavior ?? Clip.hardEdge,
      fit: fit ?? StackFit.loose,
    );
  }

  Widget toScroll() {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: this,
    ).addScrollConfig();
  }

  Widget flexWidget(
      {required Axis direction,
      MainAxisSize? mainAxisSize,
      MainAxisAlignment? mainAxisAlignment,
      TextDirection? textDirection,
      VerticalDirection? verticalDirection,
      TextBaseline? textBaseline,
      Clip? clipBehavior,
      CrossAxisAlignment? crossAxisAlignment}) {
    return Flex(
      direction: direction,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      textDirection: textDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior ?? Clip.none,
      children: this,
    );
  }
}

extension PaddingExtension on Widget {
  Widget toPad({
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
    double? horizontal,
    double? vertical,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: horizontal ?? start,
          end: horizontal ?? end,
          top: vertical ?? top,
          bottom: vertical ?? bottom),
      child: this,
    );
  }

  Widget addScrollConfig() {
    return ScrollConfiguration(behavior: ListViewScrollBehavior(), child: this);
  }

  Widget toStretch({int flex = 1, bool isFillSpace = true}) {
    return Flexible(
      flex: flex,
      child: this,
      fit: isFillSpace ? FlexFit.tight : FlexFit.loose,
    );
  }
}

extension StringOperations on String {
  toUpperLowerCase() {
    return isNotEmpty ? (this[0].toUpperCase() + substring(1)) : "";
  }
}
