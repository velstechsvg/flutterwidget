import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/screens/views/explore/explore_view.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../config/client.dart';
import '../../../constant.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/bottom_button.dart';
import '../../../widgets/contact_item.dart';
import '../../../widgets/country_picker_page.dart';
import '../../../widgets/profile_image_view.dart';
import '../chat/chat_view.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';
import 'package:yottachat/constant.dart' as Constants;

import 'new_group_controller.dart';

class NewGroup extends StatefulWidget {
  const NewGroup({Key? key}) : super(key: key);

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> implements HomeNavigator {
  final NewGroupController controller = Get.find();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  List<Map<String, dynamic>> _allContactsList = <Map<String, dynamic>>[];
  Map<String, dynamic> contactsList = <String, dynamic>{};
  Map<String, String> updatedGroupImage = <String, String>{};

  List<Map<String, dynamic>> _updatedGroupInfo = <Map<String, dynamic>>[];
  bool _isEdit = false;
  bool _isUserLeft = false;

  @override
  void initState() {
    controller.navigator = this;
    _allContactsList = Get.arguments["allGroupContacts"] ?? [];
    _isEdit = Get.arguments["isEdit"] ?? false;
    _isUserLeft = Get.arguments["isLeft"] ?? false;
    if (Get.arguments["allGroupContacts"] != null) {
      Get.arguments["allGroupContacts"].forEach((element) {
        if (element["isSelected"].toString() == "1") {
          controller.selectedGroupContacts.value.add(element);
        }
      });
    }
    contactsList = Get.arguments["selectedContact"] ?? <String, dynamic>{};
    if (Get.arguments["selectedContact"] != null) {
      controller.groupNameController.text = Get.arguments["selectedContact"]["groupName"] ?? '';
    }
    if (_isEdit) {
      controller.getGroupInfo(context, contactsList["groupId"]);
    }
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
      customAppBarFunction: () {
        if (_allContactsList.isNotEmpty) {
          Get.back(result: _allContactsList);
        } else if (_isEdit && _updatedGroupInfo.isNotEmpty) {
          Get.back(result: _updatedGroupInfo);
        } else if(updatedGroupImage.isNotEmpty) {
          updatedGroupImage["groupImage"] =
          updatedGroupImage["groupImage"]?.replaceAll(Constants.groupImagePath, "" ) ?? "";
          Get.back(result: updatedGroupImage);
        } else {
          Get.back();
        }
      },
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    if (screen == HomeScreens.chatView) {
      Get.offAll(() => const ChatView(),
          arguments: {
            "selectedGroupContacts": _allContactsList,
            "allContacts": _allContactsList,
            "selectedContact": _allContactsList,
            "isGroupChat": true
          },
          routeName: "/chatView");
    } else {
      Get.to(() => ExploreView(), routeName: "/homePage")!.then((list) {
        controller.contactsListItem.refresh();
      });
    }
  }

  @override
  showDialog() {}

  _showBodyContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        12.toHeight(),
        CustomText(
          text: _isEdit ? 'group_info'.tr : 'new_group'.tr,
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_24,
        ).toPad(horizontal: 24),
        24.toHeight(),
        getProfileImageView(context).toPad(horizontal: 24),
        10.toHeight(),
        showCustomTextField(
          textEditingController: controller.groupNameController,
          textInputAction: TextInputAction.next,
          characterlength: 100,
          maxLines: true,
          focusNode: _firstNameFocusNode,
          labelText: '',
          isEditable: !_isUserLeft,
          onSubmitted: (value) {
            _firstNameFocusNode.unfocus();
            _lastNameFocusNode.requestFocus();
          },
          hintText: Platform.isIOS && controller.isDirectionRTL(context)
              ? " ${'enter_group_name'.tr}"
              : 'enter_group_name'.tr,
        ).toPad(horizontal: 24),
        24.toHeight(),
        Obx(() => controller.selectedGroupContacts.isNotEmpty
            ? CustomText(
                text: 'participants'.tr,
                fontWeight: AppFont.bold,
                size: AppDimen.textSize_24,
              ).toPad(horizontal: 24)
            : const SizedBox.shrink()),
        Expanded(
          child: Obx(
            () => ContactListView(
              onItemLongClick: (index) {},
              contactsList: controller.selectedGroupContacts.value,
              onItemSelected: (index) {},
              onItemDeleteSelected: (index) {
                showRemoveGroupUserPopup(index);
              },
              selectedPage: 'newGroup',
              trailWidget:
                  controller.adminId.value == appPreference.userID || !_isEdit
                      ? SvgPicture.asset(contactRemoveSvg)
                      : const SizedBox.shrink(),
            ),
          ),
        ),
        Obx(() => Visibility(
            visible: !_isUserLeft && controller.isGroupNameChanged.value,
            child: getSubmitButton(context).toPad(horizontal: 24)
           ),
        ),
      ],
    );
  }

  showRemoveGroupUserPopup(int index) {
    Map<String, dynamic> contactsItem = controller.selectedGroupContacts.value[index];
    controller.showCommonBottomSheet(
        title: "remove_from_group".tr,
        description: 'remove_group_message'.trParams({
          "name":
              "${contactsItem['firstName']} ${contactsItem['lastName'] ?? ''}",
        }),
        OkButtonLabel: "remove".tr,
        OkButtonCallback: () {
          controller.checkNetwork(Get.context, () {
            if (_isEdit) {
              String threadId = contactsList['id'];
              String groupId = contactsList['groupId'];
              String contactId = controller.selectedGroupContacts.value[index]['receiverId'];
              controller.selectedGroupContacts.remove(contactsItem);
              selectedContactsCount.value = 0;
              controller.deleteGroup(context, groupId, threadId, contactId, "${contactsItem['firstName']} ${contactsItem['lastName'] ?? ''}");
            } else {
              controller.selectedGroupContacts.remove(contactsItem);
              Get.back();
            }
          });
        });
  }

  Widget getProfileImageView(context) {
    return Obx(() => Stack(
          children: [
            controller.showCenterLoading(context, "assets/loader.json", 102.0),
            ProfileImageView(
              controller: controller,
              isFrom: "newGroupPage",
              profileImage: controller.groupImage.value,
              placeHolderImage: defaultGroupImageSvg,
              isLoading: false,
              groupId: contactsList['groupId'] ?? "",
              alignment: AlignmentDirectional.centerStart,
              imageSize: 100,
              isEditable: !_isUserLeft,
              onSelected: (image) {
                controller.uploadImage(context, image.path, "group",contactsList['groupId']).then((value) {
                  controller.groupImage.value = value;
                  updatedGroupImage['groupImage'] = value;
                });
              },
              editingWidget: Container(
                  height: 25.0,
                  width: 25.0,
                  margin: EdgeInsetsDirectional.only(end: 0, bottom: 8),
                  child: SvgPicture.asset(editProfileImageSvg)),
            ),
          ],
        ));
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
        onTap: () async {
          if (!controller.isLoading.value) {
            _validateInputs();
          }
        },
        child: BottomButton(
                disablePadding: true,
                buttonText: _isEdit ? 'save'.tr : 'create_a_group'.tr,
                isLoading: controller.isLoading.value,
              )
          );
  }

  void _validateInputs() {
    if (!controller.groupNameController.text.isBlank!) {
      if (!_isEdit) {
        controller.createGroup(context);
      } else {
        controller.createGroup(context,contactsList["groupId"]);
      }
    } else {
      controller.showSnackBar("please_enter_group_name".tr, context);
    }
  }

}
