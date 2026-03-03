import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/screens/binding/home_binding.dart';
import 'package:yottachat/screens/views/auth/auth_navigator.dart';
import 'package:yottachat/screens/views/auth/signup/signup_controller.dart';
import 'package:yottachat/screens/views/explore/explore_view.dart';
import 'package:yottachat/screens/views/home_page/home_page.dart';
import 'package:yottachat/widgets/bottom_button.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/scroll_behaviour.dart';

import '../../../../app.dart';
import '../../../../config/client.dart';
import '../../../../widgets/handy_text.dart';
import '../../../../widgets/profile_image_view.dart';
import '../../custom_scaffold.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignUpViewState();
  }
}

class SignUpViewState extends State<SignUpView> implements AuthNavigator {
  final listViewScrollController = ScrollController();
  final SignUpController controller = Get.find();

  var argumentsArr = Get.arguments;
  final focus = FocusNode();

  @override
  void initState() {
    controller.navigator = this;
    controller.setInitialValue(argumentsArr);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showExitConfirmPopup(context);
      },
      child: CustomScaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: _showContentData(context),
        ),
        isShowAppBar: false,
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget showCustomAppBar(context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 80),
      child: InkWell(
        onTap: () {
          showExitConfirmPopup(context);
        },
        child: Container(
            width: 46,
            height: 46,
            margin: const EdgeInsetsDirectional.only(
                start: AppDimen.textSize_20, top: AppDimen.textSize_16),
            child: SvgPicture.asset(
              clearSearchSvg,
              matchTextDirection: true,
            )),
      ),
    );
  }

  Widget _showContentData(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showCustomAppBar(context),
            Expanded(
              child: ScrollConfiguration(
                behavior: ListViewScrollBehavior(),
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsetsDirectional.only(
                      start: 25.0, end: 25.0, top: 10),
                  controller: listViewScrollController,
                  shrinkWrap: true,
                  children: <Widget>[
                    20.toHeight(),
                    CustomText(
                      text: "complete_your_profile".tr,
                      fontWeight: FontWeight.bold,
                      size: AppDimen.textSize_24,
                    ),
                    const SizedBox(height: 7),
                    CustomText(
                      text:
                          "upload_your_profile_and_set_your_name_for_easy_to_find_you_by_your_friends"
                              .tr,
                      size: AppDimen.textSize_16,
                    ),
                    const SizedBox(height: 35),
                    getProfileImageView(context),
                    const SizedBox(height: 38),
                    TextField(
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      controller: controller.firstNameController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsetsDirectional.only(end: 6.0),
                        border: InputBorder.none,
                        hintText:
                            Platform.isIOS && controller.isDirectionRTL(context)
                                ? " ${"enter_your_name".tr}"
                                : "enter_your_name".tr,
                      ),
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: AppDimen.textSize_16,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 1,
                      color: AppColors.textfieldBorderColor,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  if (!controller.isLoading.value) {
                    controller.validateInputFields(context);
                  }
                },
                child: Obx(
                  () => Container(
                    color: AppColors.white,
                    child: BottomButton(
                        buttonText: "finish".tr,
                        isLoading: controller.isSignUpLoading.value),
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  Widget getProfileImageView(context) {
    return Obx(() => Stack(
          children: [
            Align(
                alignment: AlignmentDirectional.center,
                child: controller.showCenterLoading(
                    context, "assets/loader.json", 155.0)),
            ProfileImageView(
              controller: controller,
              profileImage: controller.profileImage.value,
              isLoading: controller.isLoading.value,
              placeHolderImage: placeHolderProfileImageSvg,
              imageSize: 150,
              onSelected: (image) {
                controller.imageFile = image;
                if (controller.isCalledProfilePage.value) {
                  Get.back();
                }
                controller
                    .uploadImage(context, controller.imageFile!.path,"signup")
                    .then((value) {
                  if (value == null) {
                    controller.isLoading.value = false;
                    controller.showSnackBar("you_offline".tr, context);
                  } else {
                    appPreference.profileImage = value;
                    controller.profileImage.value = appPreference.profileImage!;
                  }
                });
              },
              editingWidget: Container(
                  height: 35.0,
                  width: 35.0,
                  margin: EdgeInsetsDirectional.only(end: 5, bottom: 2),
                  child: SvgPicture.asset(editProfileImageSvg)),
            )
          ],
        ));
  }

  showExitConfirmPopup(context) {
    controller.showCommonBottomSheet(
        description: "are_you_sure_you_want_to_exit".tr,
        OkButtonLabel: "exit".tr,
        OkButtonCallback: () {
          App().closeApp();
        });
  }

  @override
  navigateScreen(AuthScreen screen, String param) {
    if (screen == AuthScreen.moveToHome) {
      Get.offAll(ExploreView(), binding: HomeBinding());
    }
  }

  @override
  showDialog() {}
}
