import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/widgets/country_code_picker/country.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/country_code_picker/function.dart';
import '../../../widgets/country_picker_page.dart';
import '../../../widgets/profile_image_view.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';
import 'chat_controller.dart';

class ContactInfo extends StatefulWidget {
  const ContactInfo({Key? key}) : super(key: key);

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> implements HomeNavigator {
  final ChatController controller = Get.find();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  RxString _countryflag = 'flags/usa.png'.obs;
  RxString _dialCode = '+1'.obs;
  RxString phoneCountryCode = 'US'.obs;
  var countryCode = "USA".obs;

  @override
  void initState() {
    controller.navigator = this;
    controller.selectedContactItem = Get.arguments["selectedContact"];
    controller.getContactInfo(context).then((value) {
      _phoneNumberController.text = controller.contactInfo['phoneNumber'] ?? "";
      _nameController.text =
          "${controller.contactInfo['firstName'] ?? ""} ${controller.contactInfo['lastName'] ?? ""}";
      _aboutController.text = controller.contactInfo['description'] ?? "";
      countryCode.value = controller.contactInfo['dialCode'] ?? "";
      phoneCountryCode.value = controller.contactInfo['phoneCountryCode'] ?? "";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: _showBodyContent(context),
      isShowAppBar: true,
      isBackButtonNeeded: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {}

  @override
  showDialog() {}

  _showBodyContent(BuildContext context) {
    return Obx(() {
      if (controller.contactInfo.values.isEmpty) {
        return controller.showCenterLoading(context);
      }
      else {
        _phoneNumberController.text =
            controller.contactInfo['phoneNumber'] ?? "";
        _nameController.text =
            "${controller.contactInfo['firstName'] ?? ""} ${controller.contactInfo['lastName'] ?? ""}";
        _aboutController.text = controller.contactInfo['description'] ?? "";
        countryCode.value = controller.contactInfo['dialCode'] ?? "";
        phoneCountryCode.value =
            controller.contactInfo['phoneCountryCode'] ?? "";
        return [
          const SizedBox(
            height: 12,
          ),
          CustomText(
            text: 'contact_info'.tr,
            fontWeight: AppFont.bold,
            size: AppDimen.textSize_24,
          ),
          const SizedBox(
            height: 24,
          ),
          ProfileImageView(
            controller: controller,
            profileImage:
                "${Constants.profileImagePath + controller.contactInfo['id']}/" +
                        controller.contactInfo['image'] ??
                    '',
            imageSize: 102,
            isEditable: false,
            editingWidget: Container(
                height: 16.0,
                width: 16.0,
                decoration: BoxDecoration(
                    color: AppColors.white, shape: BoxShape.circle),
                margin: EdgeInsetsDirectional.only(end: 3, bottom: 10),
                padding: EdgeInsetsDirectional.all(1),
                child: Obx(() => controller.isReceiverOnline.value
                    ? SvgPicture.asset(
                        editProfileImageSvg,
                  colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                      )
                    : SvgPicture.asset(
                        editProfileImageSvg,
                  colorFilter: const ColorFilter.mode(AppColors.borderColor, BlendMode.srcIn),
                      ))),
            alignment: AlignmentDirectional.topStart,
          ),
          const SizedBox(
            height: 16,
          ),
          showCustomTextField(
              textEditingController: _nameController,
              isEditable: false,
              labelText: 'name'.tr,
              hintText: 'enter_first_name'.tr),
          const SizedBox(
            height: 24,
          ),
          showCustomTextField(
              textEditingController: _aboutController,
              isEditable: false,
              maxLines: true,
              labelText: 'about'.tr,
              hintText: 'enter_last_name'.tr),
          const SizedBox(
            height: 24,
          ),
          CustomText(
              text: 'phone_number'.tr,
              size: AppDimen.textSize_14,
              color: AppColors.chatStatusColor),
          const SizedBox(
            height: 5,
          ),
          getPhoneNumberTextField(),
        ].toScroll().toPad(horizontal: 24, bottom: 40);
      }
    });
  }

  Widget getPhoneNumberTextField() {
    getCountryCode();
    return CountryCodeTextField(
      flagImage: _countryflag.value,
      dialCode: _dialCode.value,
      isEditable: false,
      isRTL: controller.isDirectionRTL(context),
      textEditingController: _phoneNumberController,
      navigateToCountryPicker: () {},
    );
  }

  getCountryCode() async {
    Country? country =
        const Country("United States", "flags/usa.png", "US", "+1");
    country = (await getCountryByCountryCode(context, phoneCountryCode.value));
    _countryflag.value = country?.flag ?? "flags/usa.png";
    _dialCode.value = country?.callingCode ?? "+1";
    _dialCode.refresh();
  }
}
