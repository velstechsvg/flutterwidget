import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/screens/views/custom_scaffold.dart';
import 'package:yottachat/screens/views/profile/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return const PrivacyPolicyState();
  }
}

class PrivacyPolicyState extends StatefulWidget {
  const PrivacyPolicyState({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyState> createState() => _PrivacyPolicyStateState();
}

class _PrivacyPolicyStateState extends State<PrivacyPolicyState> {
  final ProfileController controller = Get.find();

  @override
  void initState() {
    controller.checkNetwork(context, () async {
      controller.htmlContent.value = "";
      await Future.delayed(const Duration(milliseconds: 300)).then((val){
        controller.getStaticContent(context);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.white,
      body: showBodyContent(context),
      appBarBGColor: AppColors.white,
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget showBodyContent(context) {
    return Obx(() => controller.htmlContent.value.isNotEmpty
        ? Container(
      color: AppColors.white,
      margin: const EdgeInsetsDirectional.only(),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          CustomText(
            text: isShowPrivacy.value ? "privacy_policy".tr : "legal".tr,
            size: AppDimen.textSize_24,
            fontWeight: AppFont.bold,
          ),
          20.toHeight(),
          HtmlWidget(controller.htmlContent.value.replaceAll("\"", ""),
              onTapUrl: (url) async {
                bool? result = await _onUrlLaunch(url);
                result ??= false;
                return result;
              }, customStylesBuilder: (element) {
                if (element.localName == "p" ||
                    element.localName == "body" ||
                    element.localName == "h1" ||
                    element.localName == "h2") {
                  return {'padding': '0', 'margin': '0'};
                } else if (element.localName == "a") {
                  return {"color": "blue"};
                }
                return null;
              }),
          20.toHeight(),
        ],
      ),
    ).toPad(start: 20.0, end: 20.0, top: 10.0)
        : showCenterLoading(context));
  }


  Widget showCenterLoading(context, [loadingFile, Size]) {
    return Container(
      width: Size ?? MediaQuery.of(context).size.width,
      height: Size ?? MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Center(
        child: SizedBox(
          width: Size ?? 100,
          height: Size ?? 100,
          child: Lottie.asset(loadingFile ?? "assets/loader.json"),
        ),
      ),
    );
  }

  _onUrlLaunch(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
