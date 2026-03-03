import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/constant.dart';
import 'package:yottachat/screens/views/explore/explore_view.dart';
import 'package:yottachat/screens/views/new_group/new_group.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../config/client.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/bubble/bubble.dart';
import '../../../widgets/contact_item.dart';
import '../../../widgets/country_code_picker/function.dart';
import '../../../widgets/custom_popup_menu.dart';
import '../../../widgets/scroll_behaviour.dart';
import '../../binding/home_binding.dart';
import '../add_group/add_group_members.dart';
import '../custom_scaffold.dart';
import '../home_page/home_navigator.dart';
import 'chat_controller.dart';
import 'contact_info.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> implements HomeNavigator {
  final ChatController controller = ChatController();
  TextEditingController chatMessageController = TextEditingController();
  List<Map<String, dynamic>> _selectedGroupContacts = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _allContacts = <Map<String, dynamic>>[];
  final CustomPopupMenuController _popupMenuController = CustomPopupMenuController();
  List<int> dateIndex = [];
  Map<String, Color> userTextColors = <String, Color>{};
  bool _isWriting = false;
  int difference = 0;
  Map _dateStatusMap = {};
  int _dateStatusIndex = -1;

  @override
  void initState() {
    controller.navigator = this;
    controller.selectedContactItem = Get.arguments["selectedContact"] ?? <String, dynamic>{};
    Constants.lastViewedThreadId = controller.selectedContactItem['id'];
    if(Get.arguments["from"] == "newGroup"){
      groupNameUpdate.value = Get.arguments["groupName"] ?? "";
    }
    else{
      groupNameUpdate.value = controller.selectedContactItem["groupName"] ?? "";
    }
    _selectedGroupContacts = Get.arguments["selectedGroupContacts"] ?? [];
    _allContacts = Get.arguments["allContacts"] ?? [];
    controller.isGroupChat = controller.selectedContactItem["isGroup"] == "group" ? true : false;
    controller.isUserDeleted.value = (controller.selectedContactItem["deletedAt"] != "" && controller.selectedContactItem["deletedAt"] != null) ? true : false;
    controller.isFrom = Get.arguments["from"] ?? "";
    var isLeft = controller.selectedContactItem['isUserLeft'] ?? true;
    controller.chatMessagesList.value = [];
    if (!isLeft && controller.isGroupChat) {
      controller.isExitGroup.value = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200)).then((val) async {
        controller.getUserContacts(Get.context);
        fetchData(Get.context);
        controller.listenIsUserTypingSocket(Get.context);
        controller.listenIsUserOnlineSocket(context);
        controller.listenChatSocket(context);
      });
    });
    controller.chatScrollController.addListener(() {
      if (controller.chatScrollController.position.pixels == controller.chatScrollController.position.maxScrollExtent) {
        if (controller.totalCount != controller.chatMessagesList.length &&
            controller.totalCount != 0) {
          controller.currentPage++;
          controller.getAllChats(context);
        }
      }
    });
    if(controller.isFrom == "fcm"){
    if (!controller.socketIO.connected) {
      controller.socketIO.connect();
    }
    controller.getAllChats(context);
    controller.sendUserIsOnlineSocket();
  }
    SystemChannels.lifecycle.setMessageHandler((lifecycleState) async => await onLifecycleStateChanged(lifecycleState));
    if(controller.isGroupChat) {
      var users = controller.selectedContactItem['groupAllUserNameList'];
      users = users?.replaceAll("[", "");
      users = users?.replaceAll("]", "");
      var user = users?.split(",");

      List<dynamic> _userlist = user;
      for (int index = 0; index < _userlist.length; index++) {
        int colorindex = index < AppColors.contactTextColors.length - 1
            ? index
            : (index % AppColors.contactTextColors.length);
        userTextColors[_userlist[index].toString().trim()] =
            AppColors.contactTextColors[colorindex];
      }
    }
    super.initState();
  }


  onLifecycleStateChanged(dynamic lifecycleState) {
    if (lifecycleState == "AppLifecycleState.paused") {
      controller.sendUserIsOfflineSocket();
    }
    else if (lifecycleState == "AppLifecycleState.resumed") {
      controller.getUserContacts(Get.context);
      fetchData(Get.context);
      controller.listenIsUserTypingSocket(Get.context);
      controller.listenIsUserOnlineSocket(context);
      controller.listenChatSocket(context);
      controller.sendUserIsOnlineSocket();
    }
  }

  Future<void> fetchData(context) async {
    await controller.getAllChats(context);
    await controller.readMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    controller.hideSnackBar(context);
    return CustomScaffold(
      body: _showBodyContent(context),
      isShowAppBar: false,
      customAppBarFunction: () {
        FocusScope.of(context).unfocus();
        if (controller.isFrom == "newGroup" || controller.isFrom == "fcm") {
          Get.offAll(ExploreView(),
              binding: HomeBinding(), routeName: "/home_page");
        } else {
          Get.back();
        }
        return Future.value(false);
      },
      isBackButtonNeeded: false,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    FocusScope.of(context).unfocus();
    if (screen == HomeScreens.contactInfo) {
      Get.to(() => const ContactInfo(),
          arguments: {"selectedContact": controller.selectedContactItem},
          routeName: "/ContactInfo");
    }
    else if (screen == HomeScreens.addGroup) {
      Get.to(() => const AddGroupMembers(),
              arguments: {
                "ContactList": _allContacts,
                "groupId": controller.selectedContactItem['groupId'],
                "threadId": controller.selectedContactItem['id'],
                "isEdit": true,
              },
              routeName: "/addGroupMembers")
          ?.then((value) {
        if (value != null) {
          Map<String, String> contactItem = <String, String>{};
          controller.addedUserNames(value);
          contactItem["userId"] = appPreference.userID ?? "";
          contactItem["msgParams"] = "${"you".tr} ${"added".tr} ${controller.getUserNames(value.toString())}";
          contactItem["datetime"] = DateTime.now().millisecondsSinceEpoch.toString() ?? "";
          contactItem["firstName"] = "";
          contactItem["msgType"] = "";
          controller.chatMessagesList.insert(controller.chatMessagesList.length, contactItem);
          controller.chatMessagesList.refresh();
          controller.getAllChats(context);
        }
      });
    }
    else if (screen == HomeScreens.newGroup) {
      Get.to(() => const NewGroup(),
              arguments: {
                "selectedGroupContacts": _selectedGroupContacts,
                "isEdit": true,
                "isLeft": controller.isExitGroup.value,
                "selectedContact": controller.selectedContactItem
              },
              routeName: "/NewGroup")
          ?.then((value) {
        if (value != null) {
          if(value.toString().contains("groupImage")) {
            controller.selectedContactItem["groupImage"] = value['groupImage'];
            controller.isReceiverOnline.value = false;
          }
          controller.removedUserNames(value);
          Map<String, String> contactItem = <String, String>{};
          if (value.contains("you".tr)) {
            contactItem["userId"] = appPreference.userID ?? "";
            contactItem["msgParams"] = "deleted_this_group".tr;
            contactItem["datetime"] =
                DateTime.now().millisecondsSinceEpoch.toString() ?? "";
            contactItem["firstName"] = "";
            contactItem["msgType"] = "";
            controller.isExitGroup.value = true;
            controller.selectedContactItem['groupUserNameList'] = "";
            controller.isReceiverOnline.value = false;
            controller.chatMessagesList
                .insert(controller.chatMessagesList.length, contactItem);
            controller.chatMessagesList.refresh();
          } else {
            contactItem["userId"] = appPreference.userID ?? "";
            contactItem["msgParams"] = "${"you".tr} ${"removed".tr} $value";
            contactItem["datetime"] =
                DateTime.now().millisecondsSinceEpoch.toString() ?? "";
            contactItem["firstName"] = "";
            contactItem["msgType"] = "";
            controller.chatMessagesList
                .insert(controller.chatMessagesList.length, contactItem);
            controller.chatMessagesList.refresh();
          }
        }
      });
    }
  }

  _showBodyContent(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: context.width,
          height: context.height,
          child: Image.asset(
            chatBGSvg,
            fit: BoxFit.fill,
          ),
        ),
        [
          _showCustomAppBar(context),
          InkWell(
              onTap: () {
            FocusScope.of(context).unfocus();
          },
              child: Obx(
             () {
              final _chatItemchildren = _getChildren(context);
              return ListView.builder(
                controller: controller.chatScrollController,
                padding: pad(w: 14.0, bottom: 20, top: 10),
                physics: const AlwaysScrollableScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                itemCount: controller.chatMessagesList.isNotEmpty
                    ? _chatItemchildren.length
                    : 1,
                itemBuilder: (context, index) {
                  return controller.chatMessagesList.isNotEmpty
                      ? _chatItemchildren[index]
                      : Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Bubble(
                            alignment: Alignment.center,
                            radius: const Radius.circular(20),
                            elevation: 0,
                            child: CustomText(
                              text: "today".tr,
                              textAlign: TextAlign.center,
                              color: AppColors.chatStatusColor,
                              size: AppDimen.textSize_12,
                            ).toPad(horizontal: 8),
                          ),
                        );
                },
              );
            },
          )).toStretch(),
          Align(
              alignment: Alignment.bottomCenter,
              child: _showMessageInputField(context)),
        ].toColumn(),
      ],
    );
  }

  Widget _showCustomAppBar(BuildContext context) {
    return Container(
      padding: pad(start: 24.0, end: 25.0),
      color: AppColors.white,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (controller.isFrom == "newGroup" || controller.isFrom == "fcm") {
                Get.offAll(ExploreView(), binding: HomeBinding(), routeName: "/home_page");
              } else {
                Get.back(result: "success");
              }
            },
            child: Container(
              width: 36,
              height: 40,
              alignment: AlignmentDirectional.centerStart,
              child: RotatedBox(
                  quarterTurns: 2,
                  child: SvgPicture.asset(
                    leftArrowSvg,
                    color: AppColors.black,
                    width: 24,
                    matchTextDirection: true,
                    height: 15,
                  )),
            ),
          ),
          Expanded(
            child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  navigateScreen(
                      controller.isGroupChat
                          ? HomeScreens.newGroup
                          : HomeScreens.contactInfo,
                      '');
                },
                child: Obx(() {
                  return ContactItem(
                      userImage: !controller.isGroupChat
                          ? "${Constants.profileImagePath}${controller.selectedContactItem["receiverId"]}/${controller.selectedContactItem['picture']}"
                          : "${Constants.groupImagePath}${controller.selectedContactItem['groupImage'] ?? ""}",
                      placeHolderImage: !controller.isGroupChat
                          ? defaultProfileImageSvg
                          : defaultGroupImageSvg,
                      index: 0,
                      isLastIndex: true,
                      receiverId:
                      controller.selectedContactItem['receiverId'] ?? "",
                      userName: controller.isGroupChat
                          ? groupNameUpdate.value
                          : "${controller.selectedContactItem['firstName'] ?? ""} ${controller.selectedContactItem['lastName'] ?? ""}",
                      LastIndexGap: 0,
                      userStatus: controller.isGroupChat
                          ? _getUserNames()
                          : controller.isUserDeleted.value
                          ? ""
                          : controller.isReceiverOnline.value
                          ? "online".tr
                          : "offline".tr,
                      imageSize: 40,
                      isUserTyping: controller
                          .isUserTyping[controller.selectedContactItem["id"] == ""
                          ? receiverID
                          : controller.selectedContactItem["id"].toString()]
                          .toString(),
                      imageTextPadding: 20,
                      trailWidget: showPopupMenu(
                          popupcontroller: _popupMenuController,
                          onSelected: (selected, popupcontroller) {
                            if (selected == 'clear_chat'.tr) {
                              controller.checkNetwork(context, () {
                                controller.chatMessagesList.clear();
                                controller.chatMessagesList.refresh();
                                controller.clearMessage(context);
                              });
                            } else if (selected == 'exit_group'.tr) {
                              controller.removedUserNames('you');
                              _popupMenuController.hideMenu();
                              showExitConfirmPopup(
                                  context,
                                  controller.selectedContactItem['groupId'],
                                  controller.selectedContactItem['id'],
                                  appPreference.userID);
                            } else if (selected == 'add_members'.tr) {
                              navigateScreen(HomeScreens.addGroup, '');
                            }
                            _popupMenuController.hideMenu();
                          },
                          menuItems: controller.isGroupChat &&
                              !controller.isExitGroup.value
                              ? [
                            'clear_chat'.tr,
                            if (controller.selectedContactItem['adminId'] ==
                                appPreference.userID)
                              'add_members'.tr,
                            'exit_group'.tr
                          ]
                              : ['clear_chat'.tr],
                          isShowArrow: false));
                }
                )
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getChildren(BuildContext context) {
    final _chatItemChildren = <Widget>[];
    _dateStatusMap = {};
    _dateStatusIndex = -1;
    _dateStatusIndex = controller.chatMessagesList.length;
    for (var item in controller.chatMessagesList.reversed) {
      DateTime datetime =
          controller.getDateFromTimeStamp(int.parse(item["datetime"]));
      DateTime now = DateTime.now();
      difference = DateTime(datetime.year, datetime.month, datetime.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      String currentmsgDate = getPadLeftString(datetime);

      _dateStatusIndex--;
      _dateStatusMap[_dateStatusIndex] = difference != -1 && difference != 0
          ? currentmsgDate
          : difference == -1
              ? "yesterday".tr
              : "today".tr;
      if (_dateStatusMap[_dateStatusIndex + 1] != null &&
          _dateStatusMap[_dateStatusIndex] !=
              _dateStatusMap[_dateStatusIndex + 1]) {
        _addMessageDateField(
            "${_dateStatusMap[_dateStatusIndex + 1]}", _chatItemChildren);
      }

      _chatItemChildren.add(16.toHeight());
      if (item["msgType"] == "text") {
        _chatItemChildren.add(Padding(
          padding: EdgeInsetsDirectional.only(
              start: item['firstName'] != "you".tr ? 10 : 80,
              end: item['firstName'] == "you".tr ? 10 : 80),
          child: Bubble(
            elevation: 0.5,
            alignment: item["userId"] == appPreference.userID
                ? AlignmentDirectional.topEnd
                : AlignmentDirectional.topStart,
            nip: item["userId"] == appPreference.userID
                ? !controller.isDirectionRTL(context)
                    ? BubbleNip.rightTop
                    : BubbleNip.leftTop
                : !controller.isDirectionRTL(context)
                    ? BubbleNip.leftTop
                    : BubbleNip.rightTop,
            nipWidth: 10,
            nipHeight: 10,
            color: item["userId"] == appPreference.userID
                ? AppColors.senderChatColor
                : AppColors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      item['firstName'] != "you".tr && controller.isGroupChat
                          ? Text(
                              "${item['firstName']} ${item['lastName'] ?? ""}"
                                          .toString()
                                          .length <
                                      35
                                  ? "${item['firstName']} ${item['lastName'] ?? ""}"
                                  : "${item['firstName']} ${item['lastName'] ?? ""}"
                                      .toString()
                                      .replaceRange(
                                          35,
                                          "${item['firstName']} ${item['lastName'] ?? ""}"
                                              .toString()
                                              .length,
                                          "..."),
                              style: TextStyle(
                                  fontFamily: AppFont.font,
                                  color: userTextColors[
                                      "${item['firstName']} ${item['lastName'] ?? ""}"
                                          .trim()],
                                  fontSize: AppDimen.textSize_16,
                                  fontWeight: AppFont.medium))
                          : const SizedBox.shrink(),
                      Text(item['msgParams'],
                          style: const TextStyle(
                              fontFamily: AppFont.font,
                              color: AppColors.black,
                              fontSize: AppDimen.textSize_16,
                              fontWeight: AppFont.medium)),
                      5.toWidth(),
                    ],
                  ),
                ),
                5.toWidth(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CustomText(
                    text: DateFormat('hh:mm a', appPreference.preferredLanguage)
                        .format(datetime),
                    color: AppColors.chatStatusColor,
                    size: AppDimen.textSize_12,
                  ).toPad(top: 5),
                ),
              ],
            ),
          ),
        ));
      } else if (item["msgType"] == "status") {
        _chatItemChildren.add(Bubble(
          alignment: Alignment.center,
          radius: const Radius.circular(20),
          elevation: 0,
          child: CustomText(
            text: controller.getStatus(
                messageEventType: item["msgParams"],
                userName: item['lastName'] == null
                    ? item['firstName']
                    : "${item['firstName']} ${item['lastName']}",
                users: item["statusMessage"],
                senderId: item["userId"]),
            textAlign: TextAlign.center,
            color: AppColors.chatStatusColor,
            size: AppDimen.textSize_12,
          ).toPad(horizontal: 8),
        ));
      } else {
        _chatItemChildren.add(Bubble(
          alignment: Alignment.center,
          radius: const Radius.circular(20),
          elevation: 0,
          child: CustomText(
            text: item["msgParams"],
            textAlign: TextAlign.center,
            color: AppColors.chatStatusColor,
            size: AppDimen.textSize_12,
          ).toPad(horizontal: 8),
        ));
      }
    }

    _addMessageDateField("${_dateStatusMap[_dateStatusIndex]}", _chatItemChildren);
    return _chatItemChildren.toList();
  }

  Widget _showMessageInputField(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.chatScrollController.jumpTo(
          controller.chatScrollController.position.minScrollExtent,
        );
      });
    }

    return Container(
      padding: pad(w: 24, top: 20.0, bottom: 30.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Obx(() => controller.isExitGroup.value
          ? CustomText(
              text: 'exit_group_message'.tr,
              textAlign: TextAlign.center,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        color: AppColors.textfieldColor,
                        border: Border.all(
                          color: AppColors.textfieldBorderColor,
                        ),
                      ),
                      padding: pad(w: 15.0),
                      child: Scrollbar(
                        child: TextField(
                          controller: chatMessageController,
                          onChanged: (value) {
                            if (!_isWriting) {
                              _isWriting = true;
                              controller.sendUserTypingSocket(context);
                              Future.delayed(const Duration(seconds: 3))
                                  .whenComplete(() {
                                _isWriting = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            hintText: Platform.isIOS &&
                                    controller.isDirectionRTL(context)
                                ? ' ${'type_here'.tr}'
                                : 'type_here'.tr,
                            contentPadding: pad(top: 10, bottom: 10.0),
                          ),
                          minLines: 1,
                          maxLines: 5,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(height: 1),
                        ),
                      )),
                ),
                10.toWidth(),
                InkWell(
                    onTap: () {
                      if (chatMessageController.text.trim().isNotEmpty) {
                        controller.checkNetwork(context, () {
                          controller.sendMessage(context,
                              chatMessageController.text.toString().trim());
                          Map<String, String> contactItem = <String, String>{};
                          contactItem["userId"] = appPreference.userID ?? "";
                          contactItem["msgParams"] =
                              chatMessageController.text.toString().trim();
                          contactItem["datetime"] = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString() ??
                              "";
                          contactItem["firstName"] = "you".tr;
                          contactItem["msgType"] = "text" ?? 'message';
                          controller.chatMessagesList.add(contactItem);
                          controller.chatMessagesList.refresh();
                          chatMessageController.clear();
                        });
                      }
                    },
                    child: SvgPicture.asset(
                      sendMsgSvg,
                      matchTextDirection: true,
                    )),
              ],
            )),
    );
  }

  void _addMessageDateField(dynamic datetim, List<Widget> children) {
    children.add(15.toHeight());
    children.add(Bubble(
      key: Key(datetim),
      stick: true,
      alignment: Alignment.center,
      radius: const Radius.circular(20),
      elevation: 0,
      child: CustomText(
        text: datetim,
        textAlign: TextAlign.center,
        color: AppColors.chatStatusColor,
        size: AppDimen.textSize_12,
      ).toPad(horizontal: 8),
    ));
  }

  String getPadLeftString(DateTime datetime) {
    return DateFormat('dd/MM/yy', appPreference.preferredLanguage)
        .format(datetime);
  }

  showExitConfirmPopup(context, groupId, threadId, contactId) {
    controller.showCommonBottomSheet(
        title: "exit_group".tr,
        description: 'are_you_sure_want_to_exit_from_this_group'.tr,
        OkButtonLabel: "exit".tr,
        OkButtonCallback: () {
          if (!controller.isLoading.value) {
            controller.chatMessagesList.refresh();
            controller.deleteGroup(context, groupId, threadId, contactId);
          }
        });
  }

  void updateListItem(List<Map<String, String>> list, String type) {
    if (list.isNotEmpty) {
      setState(() {});
    }
  }

  String _getUserNames() {
    var users = controller.selectedContactItem['groupUserNameList'];
    users = users?.replaceAll("[", "");
    users = users?.replaceAll("]", "");
    var user = users?.split(",");
    String _addedUsers = "";
    var length = 0;
    if (user.length > 5) {
      length = 5;
    }
    else {
      length = user.length;
    }
    for (int i = 0; i < length; i++) {
      if (_addedUsers.isEmpty) {
        _addedUsers += (user[i].contains("You")) ? "you".tr : user[i];
      } else if (i == user.length - 1) {
        _addedUsers += (user[i].contains('You'))
            ? " ${'and'.tr} ${"you".tr}"
            : " ${'and'.tr} ${user[i]}";
      } else {
        _addedUsers +=
            (user[i].contains('You')) ? ", ${"you".tr}" : ", ${user[i]}";
      }
    }
    return _addedUsers;
  }

  @override
  void dispose() {
    super.dispose();
    Constants.lastViewedThreadId = "";
  }
}
