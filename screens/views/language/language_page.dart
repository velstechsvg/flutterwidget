import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yottachat/resources/app_font.dart';

import '../../../app_localizations.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/custom_search_field.dart';
import '../../../widgets/handy_text.dart';
import '../../../widgets/launguage_picker_sheet.dart';
import '../custom_scaffold.dart';
import 'language_controller.dart';
import 'language_navigator.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  LanguagePageState createState() => LanguagePageState();
}

class LanguagePageState extends State<LanguagePage>
    implements SettingsNavigator {
  final LanguageController controller = Get.find();

  @override
  void initState() {
    controller.navigator = this;

    super.initState();
  }

  @override
  showDialog() {}

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      body: showBodyContent(context),
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget showBodyContent(context) {
    return Obx(
      () => !controller.isLoading.value
          ? SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                  start: 20.2, end: 20.0, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "language".tr,
                    size: AppDimen.textSize_24,
                    fontWeight: AppFont.bold,
                  ),
                  addLanguageView(context),
                ],
              ))
          : controller.showCenterLoading(context),
    );
  }

  Widget addLanguageView(context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(
              text: "preferred_language".tr,
              size: AppDimen.textSize_16,
              fontWeight: FontWeight.bold),
          const SizedBox(
            height: 5,
          ),
          CustomText(
            text: "language_desc".tr,
            size: AppDimen.textSize_16,
            fontWeight: AppFont.regular,
          ),
          addDropDownView(context, false)
        ]));
  }

  Widget addDropDownView(ctx, bool isForCurrency) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: InkWell(
          onTap: () {
            showPickerSheet(
                dropdownList: controller.launguages,
                dropDownType: 'launguage',
                baseController: controller,
                onItemSelected: (value) {
                  Map<String, dynamic>? _pickerItem =
                      controller.launguages[value];
                  if (_pickerItem != null) {
                    controller.checkNetwork(ctx, () {
                      controller.updateProfileSettings(
                          ctx, "preferredLanguage", _pickerItem["id"]);
                    });
                    LocalizationService().changeLocale(_pickerItem["id"]);
                    controller.appPreference.preferredLanguage =
                        _pickerItem["id"];
                    controller.launguages.clear();
                    controller.formLanguageArray();
                  }
                  Get.back();
                });
          },
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                CustomText(
                  text: controller.getLanguageName(),
                  size: AppDimen.textSize_16,
                  fontWeight: AppFont.medium,
                ),
                SvgPicture.asset(downArrowSvg)
              ]),
              const SizedBox(
                height: 13,
              ),
              showDivider()
            ],
          ),
        ));
  }

  String getCurrencySymbol(String? currency) {
    var format = NumberFormat.simpleCurrency(name: currency);
    return format.currencySymbol;
  }

  @override
  navigateScreen(SettingScreens screen, String param) {
    // TODO: implement navigateScreen
    throw UnimplementedError();
  }
}
