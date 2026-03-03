import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/custom_widgets_profile.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:yottachat/widgets/handy_text.dart';
import 'package:yottachat/constant.dart' as Constants;
import '../../../../utils/click_utils.dart';
import '../../../../widgets/custom_widgets_help.dart';
import '../../custom_scaffold.dart';
import '../profile_controller.dart';

class SupportView extends StatefulWidget {
  const SupportView({Key? key}) : super(key: key);

  @override
  _SupportViewState createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final ProfileController controller = Get.find();
  bool isEmailClicked = false;
  bool isCallClicked = false;
  bool isSkypeClicked = false;

  @override
  void initState() {
    controller.isLoadSupportUrl.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getSiteSettings(Constants.securityKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      body: Obx(() => controller.isLoadSupportUrl.value
          ? controller.showCenterLoading(context)
          : showBodyContent(context)),
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget showBodyContent(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        10.toHeight(),
        CustomText(
          text: "help".tr,
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_24,
        ),
        20.toHeight(),
        InkWell(
            onTap: () => {
                  ClickUtils.debounce(() {
                    UrlLauncher.launchUrl(Uri.parse(
                        "mailto:${controller.appPreference.adminEmail}"));
                  })
                },
            child: getNavigationItemsHelp(emailSvg, "email".tr,
                controller.appPreference.adminEmail ?? "")),
        20.toHeight(),
        InkWell(
            onTap: () {
              ClickUtils.debounce(() {
                String telphone =
                    "tel://${controller.appPreference.adminPhoneNumber}";
                UrlLauncher.launchUrl(Uri.parse(telphone));
              });
            },
            child: getNavigationItemsHelp(
              callSvg,
              "call".tr,
              controller.appPreference.adminPhoneNumber ?? "",
            )),
        20.toHeight(),
        InkWell(
            onTap: () {
              ClickUtils.debounce(() {
                String skype = controller.appPreference.adminSkype!;
                UrlLauncher.canLaunchUrl(Uri.parse(skype)).then((value) async {
                  if (await canLaunchUrl(Uri.parse('skype:username'))) {
                    UrlLauncher.launchUrl(Uri.parse("skype:username"),
                        mode: LaunchMode.externalApplication);
                  } else {
                    UrlLauncher.launchUrl(
                        Uri.parse("https://login.live.com/login.srf"),
                        mode: LaunchMode.externalApplication);
                  }
                });
              });
            },
            child: getNavigationItemsHelp(
              helpSkypeSvg,
              "skype".tr,
              controller.appPreference.adminSkype ?? "",
            )),
      ],
    ).toPad(horizontal: 20.4);
  }
}
