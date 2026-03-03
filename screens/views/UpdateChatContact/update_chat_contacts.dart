import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/screens/views/UpdateChatContact/update_chat_contact_controller.dart';
import 'package:yottachat/screens/views/add_group/add_group_members.dart';
import 'package:yottachat/screens/views/chat/chat_controller.dart';
import 'package:yottachat/screens/views/chat/chat_view.dart';
import 'package:yottachat/screens/views/new_contact/new_contact.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../config/client.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/contact_item.dart';
import '../../../widgets/custom_floating_action_button.dart';
import '../../../widgets/custom_search_field.dart';
import '../../../widgets/custom_widgets_profile.dart';
import '../../../widgets/show_done_view.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';

class updateChatContacts extends StatefulWidget {
  const updateChatContacts({Key? key}) : super(key: key);

  @override
  State<updateChatContacts> createState() => _updateChatContactsState();
}

class _updateChatContactsState extends State<updateChatContacts> implements HomeNavigator {
  final updateChatContactsController controller = Get.find();
  List<Map<String, dynamic>> _tempContactsList = <Map<String, dynamic>>[];
  late Map<String, dynamic> _contactItem;
  final List<Map<String, dynamic>> _selectedcontactsList =
      <Map<String, dynamic>>[].obs;
  var isLongClickEnabled = false;

  @override
  void initState() {
    controller.navigator = this;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getUserContacts(context);
      _tempContactsList = controller.contactsList.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: Obx(
          () => Stack(
            children: [
              _showBodyContent(context),
              controller.showCenterLoading(context),
            ],
          ),
        ),
        isShowAppBar: true,
        action: [
          InkWell(
              onTap: () {
                controller.checkNetwork(Get.context, () {
                  navigateScreen(HomeScreens.newContact, "editContact");
                });
              },
              child: Obx(() => _selectedcontactsList.length == 1
                  ? SvgPicture.asset(
                      editSvg,
                      matchTextDirection: true,
                    ).toPad(end: 25)
                  : const SizedBox.shrink())),
          InkWell(
              onTap: () {
                controller.checkNetwork(Get.context, () {
                  controller.isLoading.value = false;
                  showDeleteConfirmPopup(context, _selectedcontactsList);
                });
              },
              child: Obx(() => _selectedcontactsList.isNotEmpty
                  ? SvgPicture.asset(
                      deleteChatSvg,
                      matchTextDirection: true,
                    ).toPad(end: 25)
                  : const SizedBox.shrink()))
        ].toRow(),
        isBackButtonNeeded: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        customAppBarFunction: () {
          if (MediaQuery.of(context).viewInsets.bottom == 0) {
            if (_selectedcontactsList.isNotEmpty) {
              _selectedcontactsList.clear();
              for (var element in controller.contactsList) {
                element["isSelected"] = "0";
              }
              isLongClickEnabled = false;
              controller.contactsList.refresh();
              Get.back();
            } else {
              Get.back();
            }
          } else {
            controller.hideKeyBoard();
          }
        },
        floatingActionButton: Obx(() => !controller.isLoading.value
            ? controller.contactsList.value.isEmpty
                ? CustomFloatingActionButton(onPressed: () {
                    navigateScreen(HomeScreens.newContact, "");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink()),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    if (screen == HomeScreens.newContact) {
      Get.to(() => const NewContact(),
              arguments: {
                "isEdit": true,
                "editContact":
                    param == "editContact" ? _selectedcontactsList : null
              },
              routeName: "/newContact")!
          .then((list) {
        controller.getUserContacts(context).then((value) {
          controller.searchContactController.text = "";
          _tempContactsList = controller.contactsList.value;
          for (var element in controller.contactsList) {
            element["isSelected"] = "0";
          }
          _selectedcontactsList.clear();
          controller.selectedContactsCount.value = 0;
          isLongClickEnabled = false;
          controller.contactsList.refresh();
        });
      });
    }
    else if (screen == HomeScreens.chatView) {
      Get.to(() => const ChatView(),
             transition: Transition.rightToLeft,
              arguments: {"selectedContact": _contactItem, "from": "updateContacts"},
              routeName: "/chatView")
          ?.then((value) {
        controller.searchContactController.text = "";
        controller.getUserContacts(context);
      });
    }
    else if (screen == HomeScreens.addGroup) {
      List<Map<String, dynamic>> platformUsers = <Map<String, dynamic>>[];
      _tempContactsList.forEach((element) {
        if (element["isPlatformUser"] &&
            element["receiverId"] != appPreference.userID) {
          platformUsers.add(element);
        }
      });
      Get.to(() => const AddGroupMembers(),
              arguments: {"ContactList": platformUsers},
              routeName: "/addGroupMembers")
          ?.then((value) {
        _onSearch("");
        controller.searchContactController.text = "";
        for (var element in controller.contactsList) {
          element["isSelected"] = "0";
        }
        isLongClickEnabled = false;
        _selectedcontactsList.clear();
        controller.selectedContactsCount.value = 0;
        controller.contactsList.refresh();
      });
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
          12.toHeight(),
          _showSearchContactsView(),
          _showNewChatUserSection(context),
          24.toHeight(),
          CustomText(
            text: 'contacts'.tr,
            fontWeight: AppFont.bold,
            size: AppDimen.textSize_24,
          ).toPad(horizontal: 24),
         _showContactList(context),
        ],
      ),
    );
  }

  Widget _showCreateChatUser(
      String newGroupSvg, String tr, String rightArrowSvg, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: getNavigationItems(newGroupSvg, tr),
    ).toPad(horizontal: 24);
  }

  showDeleteConfirmPopup(context, selectedContact) {
    controller.showCommonBottomSheet(
        title: selectedContact.length == 1
            ? "delete_contact".tr
            : "delete_contacts".tr,
        description: selectedContact.length == 1
            ? "are_you_sure_want_to_delete_contact".tr
            : "are_you_sure_want_to_delete_contacts".tr,
        OkButtonLabel: "delete".tr,
        OkButtonCallback: () {
          controller.checkNetwork(Get.context, () {
            List<int> listId = [];
            selectedContact.forEach((element) {
              listId.add(element["contactId"]);
            });
            ListBuilder<int?> builderList = ListBuilder<int?>(listId);
            controller.deleteUserContacts(context, builderList);
            _selectedcontactsList.clear();
          });
        });
  }

  _showSearchContactsView() {
    return CustomSearchField(
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
              margin: pad(end: 12.0, start: 5.0),
              child: SvgPicture.asset(clearSearchSvg, fit: BoxFit.scaleDown)),
          onTap: () {
              FocusScope.of(context).unfocus();
              controller.searchContactController.clear();
              controller.contactsList.value = _tempContactsList;
          },
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
    return Obx(() {
      return controller.contactsList.value.isEmpty
          ? showEmptyView(
              emptyText: "no_contacts_found".tr,
              emptyImage: emptyContactSvg,
              context: context)
          : Expanded(
              child: ContactListView(
                  onItemLongClick: (index) {
                    controller.checkNetwork(Get.context, () {
                      controller.isLoading.value = false;
                      isLongClickEnabled = true;
                      List<Map<String, dynamic>> contactsList =
                          controller.contactsList.value;
                      Map<String, dynamic> contactsItem = contactsList[index];
                      if (contactsItem["isSelected"] == null ||
                          contactsItem["isSelected"] == "0") {
                        controller.selectedContactsCount++;
                        contactsItem["isSelected"] = "1";
                        _selectedcontactsList.add(contactsItem);
                      } else {
                        controller.selectedContactsCount--;
                        contactsItem["isSelected"] = "0";
                        _selectedcontactsList.remove(contactsItem);
                      }

                      contactsList[index] = contactsItem;
                      controller.contactsList.value = contactsList;
                      controller.contactsList.refresh();
                    });
                  },
                  contactsList: controller.contactsList.value,
                  trailWidget: Align(
                      alignment: AlignmentDirectional.center,
                      child: SvgPicture.asset(
                        selectedCountrySvg,
                        height: 24,
                        width: 24,
                      )),
                  selectedPage: 'addGroup',
                  onItemSelected: (index) {
                    controller.checkNetwork(Get.context, () {
                      controller.isLoading.value = false;
                      if (isLongClickEnabled) {
                        List<Map<String, dynamic>> contactsList = controller.contactsList.value;
                        Map<String, dynamic> contactsItem = contactsList[index];
                        if (contactsItem["isSelected"] == null || contactsItem["isSelected"] == "0") {
                          controller.selectedContactsCount++;
                          contactsItem["isSelected"] = "1";
                          _selectedcontactsList.add(contactsItem);
                        } else {
                          controller.selectedContactsCount--;
                          contactsItem["isSelected"] = "0";
                          _selectedcontactsList.remove(contactsItem);
                        }
                        contactsList[index] = contactsItem;
                        controller.contactsList.value = contactsList;
                        controller.contactsList.refresh();
                        if (_selectedcontactsList.isEmpty) {
                          isLongClickEnabled = false;
                        }
                      } else {
                        _contactItem = controller.contactsList.value[index];
                        if (_contactItem["isPlatformUser"]) {
                          navigateScreen(HomeScreens.chatView, '');
                        } else {
                          controller.showSnackBar("un_register_user".tr, context);
                        }
                      }
                    });
                  },
                  isLongPressEnabled: true));
    });
  }

  _showNewChatUserSection(BuildContext context) {
    return Obx(() => controller.contactsList.value.isNotEmpty
        ? Column(
          children: [
            22.toHeight(),
            _showCreateChatUser(newGroupSvg, "new_group".tr, rightArrowSvg,
                () {
              navigateScreen(HomeScreens.addGroup, "");
            }),
            _showCreateChatUser(
                newContactSvg, "new_contact".tr, rightArrowSvg, () {
              FocusScope.of(context).unfocus();
              navigateScreen(HomeScreens.newContact, "");
            }),
          ],
        )
        : 0.toHeight());
  }
}
