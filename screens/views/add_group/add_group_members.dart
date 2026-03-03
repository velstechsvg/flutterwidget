import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/screens/views/new_group/new_group.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/bottom_button.dart';
import '../../../widgets/contact_item.dart';
import '../../../widgets/custom_search_field.dart';
import '../../../widgets/show_done_view.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';
import 'add_group_members_controller.dart';

class AddGroupMembers extends StatefulWidget {
  const AddGroupMembers({Key? key}) : super(key: key);

  @override
  State<AddGroupMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers>
    implements HomeNavigator {
  final AddGroupMembersController controller = Get.find();
  List<Map<String, dynamic>> _tempContactsList = <Map<String, dynamic>>[];
  late bool _isEdit;
  int addedUserCount = 3;
  String groupId = "";
  String threadId = "";

  @override
  void initState() {
    controller.navigator = this;
    if (Get.arguments["ContactList"].isNotEmpty) {
      controller.contactsList.value = Get.arguments["ContactList"];
      _tempContactsList = Get.arguments["ContactList"];
      selectedContactsCount.value = 0;
    } else {
      fetchData(context);
    }
    _isEdit = Get.arguments["isEdit"] ?? false;
    controller.selectedcontactsList.clear();
    selectedContactsCount.value = 0;
    super.initState();
  }

  Future<void> fetchData(context) async {
    groupId = Get.arguments["groupId"] ?? "";
    threadId = Get.arguments["threadId"] ?? "";
    if (groupId.isNotEmpty) {
      await controller.getGroupInfo(context, groupId).then((value) {
        if (value.isNotEmpty) {
          controller.getUserContacts(context, value);
        }
      });
      _tempContactsList = controller.contactsList.value;
    }
    else {
      controller.getUserContacts(context, []);
      _tempContactsList = controller.contactsList.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: _showBodyContent(context),
        isShowAppBar: true,
        isBackButtonNeeded: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        customAppBarFunction: () {
          if (MediaQuery.of(context).viewInsets.bottom == 0) {
            if (controller.selectedcontactsList.isNotEmpty) {
              controller.selectedcontactsList.clear();
              for (var element in controller.contactsList) {
                element["isSelected"] = "0";
              }
              selectedContactsCount.value = 0;
              controller.contactsList.refresh();
              Get.back();
            } else {
              Get.back();
            }
          } else {
            controller.hideKeyBoard();
          }
        });
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    if (screen == HomeScreens.newGroup) {
      if (_isEdit) {
        Get.back();
      } else {
        controller.searchContactController.text = "";
        Get.to(() => const NewGroup(),
                arguments: {
                  "allGroupContacts": _tempContactsList,
                  "selectedGroupContacts": controller.selectedcontactsList
                },
                routeName: "/newGroup")!
            .then((list) {
          _onSearch('');
          controller.contactsList.refresh();
        });
      }
    }
  }

  @override
  showDialog() {}

  _showBodyContent(BuildContext context) {
    return InputDoneView(
      controller,
      parentWidget: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          _showSearchContactsView(),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: CustomText(
              text: 'add_members'.tr,
              fontWeight: AppFont.bold,
              size: AppDimen.textSize_24,
            ),
          ),
          _showContactList(context),
          getSubmitButton(context)
        ],
      ),
    );
  }

  _showSearchContactsView() {
    return Obx(
      () => CustomSearchField(
        controller: controller.searchContactController,
        onChanged: controller.contactsList.value.isNotEmpty ? _onSearch : _onSearch,
        searchHintText: 'search_your_contacts'.tr,
        searchInputStyle: const TextStyle(fontSize: AppDimen.textSize_16),
        focusSearchBox: false,
        isRTL: controller.isDirectionRTL(context),
        suffixIcon: Visibility(
          visible: controller.searchContactController.text.isNotEmpty,
          child: InkWell(
            child: Container(
                width: 25,
                height: 25,
                margin: EdgeInsetsDirectional.only(end: 12.0, start: 5.0),
                child: SvgPicture.asset(clearSearchSvg, fit: BoxFit.scaleDown)),
            onTap: () {
              Future.delayed(Duration.zero, () async {
                FocusScope.of(context).unfocus();
                controller.searchContactController.clear();
                controller.contactsList.value = _tempContactsList;
                controller.contactsList.refresh();
              });
            },
          ),
        ),
      ),
    );
  }

  void _onSearch(String value) {
    if (value.isEmpty) {
      controller.contactsList.value = _tempContactsList;
    } else {
      controller.contactsList.value = _tempContactsList
          .where((element) => "${element['firstName']} ${element['lastName']}"
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .map((e) => e)
          .toList();
    }
    controller.contactsList.refresh();
  }

  Widget _showContactList(BuildContext context) {
    return Obx(() => controller.contactsList.value.isEmpty
        ? showEmptyView(
            emptyText: "no_contacts_found".tr,
            emptyImage: emptyContactSvg,
            context: context)
        : Expanded(
            child: ContactListView(
            onItemLongClick: (index) {},
            contactsList: controller.contactsList.value,
            onItemSelected: (index) {
              List<Map<String, dynamic>> contactsList = controller.contactsList.value;
              Map<String, dynamic> contactsItem = contactsList[index];
              if (contactsItem["isSelected"] == null || contactsItem["isSelected"] == "0") {
                selectedContactsCount++;
                contactsItem["isSelected"] = "1";
                controller.selectedcontactsList.add(contactsItem);
              }
              else {
                selectedContactsCount--;
                contactsItem["isSelected"] = "0";
                controller.selectedcontactsList.remove(contactsItem);
              }
              contactsList[index] = contactsItem;
              controller.contactsList.value = contactsList;
              controller.contactsList.refresh();
            },
            selectedPage: 'addGroup',
            trailWidget: Align(
                alignment: AlignmentDirectional.center,
                child: SvgPicture.asset(
                  selectedCountrySvg,
                  height: 24,
                  width: 24,
                )),
          )));
  }

  Widget getSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        FocusScope.of(context).unfocus();
        controller.checkNetwork(context, () {
          if (_isEdit) {
            showAddConfirmPopup(context);
          } else {
            navigateScreen(HomeScreens.newGroup, '');
          }
        });
      },
      child: Obx(() => selectedContactsCount.value > 0 && controller.contactsList.value.isNotEmpty
          ? BottomButton(
              buttonText: _isEdit ? 'add'.tr : 'next'.tr,
            )
          : const SizedBox.shrink()),
    );
  }

  showAddConfirmPopup(context) {
    controller.showCommonBottomSheet(
        title: "add_to_group".tr,
        description: 'are_you_sure_want_to_add_to_this_group'
            .trParams({"users": getUpdatedUsers()}),
        OkButtonLabel: "add".tr,
        OkButtonCallback: () {
          List<String> addedUserNames = [];
          controller.selectedcontactsList.forEach((element) {
            addedUserNames.add("${element['firstName']} ${element['lastName'] ?? ""}");
          });
          controller.addUserInGroup(context, groupId, threadId, addedUserNames);
        });
  }

  String getUpdatedUsers() {
    String _users = "";
    for (int i = 0; i < controller.selectedcontactsList.length; i++) {
      if (i == 0) {
        _users += "${controller.selectedcontactsList[i]['firstName']} ${controller.selectedcontactsList[i]['lastName'] ?? ""}";
      } else if (i < addedUserCount) {
        _users += ", ${controller.selectedcontactsList[i]['firstName']} ${controller.selectedcontactsList[i]['lastName'] ?? ""}";
      } else if (controller.selectedcontactsList.length - addedUserCount == 1) {
        _users += " ${'and'.tr} 1 ${'add_others'.tr.toLowerCase()}";
      } else {
        if (!_users.contains('others_label'.tr.toLowerCase())) {
          _users +=
              " ${'and'.tr} ${controller.selectedcontactsList.length - addedUserCount} ${'others_label'.tr.toLowerCase()}";
        }
      }
    }
    return _users;
  }
}
