import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yottachat/app.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/screens/binding/auth_binding.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_page.dart';
import 'package:yottachat/screens/views/custom_scaffold.dart';
import 'package:yottachat/screens/views/edit_profile/edit_profile.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'package:yottachat/screens/views/profile/delete_account/delete_account.dart';
import 'package:yottachat/screens/views/profile/privacy_policy/privacy_policy.dart';
import 'package:yottachat/screens/views/profile/profile_controller.dart';
import 'package:yottachat/screens/views/profile/support/support_view.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/custom_widgets_profile.dart';
import 'package:yottachat/widgets/handy_text.dart';
import 'package:yottachat/widgets/scroll_behaviour.dart';

import '../../../constant.dart';
import '../../../widgets/bottom_button.dart';
import '../language/language_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements HomeNavigator {
  final ProfileController controller = Get.find();

  @override
  void initState() {
    controller.navigator = this;
    controller.getSiteSettings(Constants.securityKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => !controller.isLoading.value
        ? CustomScaffold(
            backgroundColor: AppColors.white,
            body: showBodyContent(context),
            isShowAppBar: true,
            isBackButtonNeeded: true,
            resizeToAvoidBottomInset: true,
            customAppBarFunction: () {
              Get.back();
            },
          )
        : Container(
            color: AppColors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: controller.showCenterLoading(context)));
  }

  Widget showBodyContent(BuildContext context) {
    return ScrollConfiguration(
      behavior: ListViewScrollBehavior(),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          10.toHeight(),
          CustomText(
            text: "settings".tr,
            size: AppDimen.textSize_24,
            fontWeight: FontWeight.bold,
          ).toPad(horizontal: AppDimen.textSize_20),
          InkWell(
              onTap: () => navigateScreen(HomeScreens.editProfile, ""),
              child: Obx(() => getEditProfileView(context))),
          24.toHeight(),
          Column(
            children: [
              InkWell(
                  onTap: () {
                    navigateScreen(HomeScreens.deleteAccount, "");
                  },
                  child: getNavigationItems(
                    manageAccountSvg,
                    "manage_your_account".tr,
                  )),
              InkWell(
                onTap: () {
                  navigateScreen(HomeScreens.language, "");
                },
                child: getNavigationItems(
                  languageSvg,
                  "language".tr,
                ),
              ),
              InkWell(
                onTap: () {
                  isShowPrivacy.value = true;
                  navigateScreen(HomeScreens.privacyPolicy, "");
                },
                child: getNavigationItems(
                  privacySvg,
                  "privacy_policy".tr,
                ),
              ),
              InkWell(
                onTap: () {
                  isShowPrivacy.value = false;
                  navigateScreen(HomeScreens.privacyPolicy, "");
                },
                child: getNavigationItems(
                  legalSvg,
                  "legal".tr,
                ),
              ),
              InkWell(
                onTap: () {
                  navigateScreen(HomeScreens.support, "");
                },
                child: getNavigationItems(
                  helpSvg,
                  "help".tr,
                ),
              ),
              InkWell(
                onTap: () {
                  showExitConfirmPopup(context);
                },
                child: getNavigationItems(logOutSvg, "sign_out".tr, true),
              ),
            ],
          ).toPad(horizontal: AppDimen.textSize_20),
          40.toHeight(),
          Obx(() => controller.version.value.isNotEmpty
              ? getVersionView(context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget getEditProfileView(context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: AppColors.searchFieldBoxColor,
        margin: pad(top: 20.0),
        child: Row(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                        imageUrl: controller.profileImage.value,
                        height: 60.0,
                        width: 60.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            SizedBox(
                                width: 50,
                                height: 50,
                                child: Lottie.asset("assets/loader.json"),),
                        errorWidget: (context, url, error) =>
                           SizedBox(
                             width: 50,
                             height: 50,
                             child: Lottie.asset("assets/loader.json"),),
                      )
                    ,
              ),
            ),
            Expanded(
                flex: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                            text: controller.firstName.value,
                            size: AppDimen.textSize_18,
                            fontWeight: FontWeight.bold)
                        .toPad(start: 20.0),
                    7.toHeight(),
                    CustomText(
                      text: controller.description.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.hintTextColor,
                      size: AppDimen.textSize_14,
                    ).toPad(start: 20.0),
                  ],
                )),
            Expanded(
                flex: 11,
                child: SvgPicture.asset(
                  editProfileSvg,
                  matchTextDirection: true,
                  color: AppColors.black,
                ))
          ],
        ).toPad(top: 15.0, start: 20, end: 12, bottom: 15));
  }

  Widget getSignOutView(context) {
    return InkWell(
      onTap: () => showExitConfirmPopup(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("sign_out".tr,
              style: const TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFont.font,
                  fontSize: AppDimen.textSize_16,
                  fontWeight: FontWeight.w500)),
          10.toWidth(),
          SvgPicture.asset(logoutSvg)
        ],
      ),
    );
  }

  Widget getVersionView(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset(
        versionInfoSvg,
        matchTextDirection: true,
      ),
      3.toWidth(),
      CustomText(
        text: controller.version.value,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w500,
        size: AppDimen.textSize_16,
      )
    ]);
  }

  showExitConfirmPopup(context) {
    controller.showCommonBottomSheet(
        title: "sign_out".tr,
        description: "exit_confirmation_one".tr,
        OkButtonLabel: "sign_out".tr,
        OkButtonCallback: () {
          controller.isLoading.value = true;
          controller.checkNetwork(context, () {
            controller.userSignout(context);
          });
          Get.back();
        });
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    switch (screen) {
      case HomeScreens.editProfile:
        Get.to(() => const EditProfile(), routeName: "/editProfilePage");
        break;
      case HomeScreens.getStarted:
        isShowPopup = false;
        Get.offAll(() => const GetStartedPage(),
            binding: AuthBinding(),
            arguments: {"isLogin": param},
            routeName: "/getStartedPage");
        break;
      case HomeScreens.trustedContacts:
        break;
      case HomeScreens.deleteAccount:
        Get.to(() => const DeleteAccount(), routeName: "/deleteAccount");
        break;
      case HomeScreens.privacyPolicy:
        Get.to(() => const PrivacyPolicy(), routeName: "/privacyPolicy");
        break;
      case HomeScreens.settings:
        break;
      case HomeScreens.payment:
        break;
      case HomeScreens.support:
        Get.to(() => const SupportView(), routeName: "/supportViewPage");
        break;
      case HomeScreens.language:
        Get.to(() => const LanguagePage(), routeName: "/settingsPage");
        break;
      default:
        break;
    }
  }

  @override
  showDialog() {}

  @override
  void dispose() {
    Get.delete<ProfileController>();
    super.dispose();
  }
}
