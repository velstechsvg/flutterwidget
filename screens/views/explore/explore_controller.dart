import 'dart:async';
import 'dart:convert' as json;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/screens/binding/home_binding.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/screens/views/explore/explore_view.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'package:yottachat/screens/views/home_page/home_page.dart';
import '../../../constant.dart' as Constant;
import '../../../graphql/get_all_threads/__generated__/get_all_threads.data.gql.dart';
import '../../../graphql/get_all_threads/__generated__/get_all_threads.req.gql.dart';

class ExploreController extends HomeController {
  HomeNavigator? navigator;
  var popularCategory = [].obs;
  var recentCategory = [];
  late BuildContext context;
  late int jobId;
  int totalCount = 0;
  int currentPage = 1;
  var completeSocketCalled = false.obs;
  TextEditingController searchChatController = TextEditingController();
  RxList<Map<String, dynamic>> contactsList = <Map<String, String>>[].obs;
  RxInt textCount = 3.obs;
  RxList<Map<String, String>> isUserTyping = <Map<String, String>>[].obs;
  RxString firstName = ''.obs;

  @override
  void onReady() {
    firstName.value = appPreference.firstName ?? "";
    super.onReady();
  }

  @override
  void onPaused() {
    sendUserIsOfflineSocket();
    super.onPaused();
  }

  @override
  void onInit() {
    sendUserIsOnlineSocket();
    super.onInit();
  }

  @override
  void onResumed() {
    sendUserIsOnlineSocket();
  }

  Future<void> getAllChats(context) async {
    isLoading.value = true;
    final params = GgetAllThreadsReq((b) => b
      ..vars.currentPage = currentPage
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetAllThreadsData;
        var resultStatus = response.getAllThreads!.status;
        if (resultStatus == 200) {
          if (currentPage == 1) {
            contactsListItem.clear();
          }
          totalCount = response.getAllThreads?.count ?? 0;
          response.getAllThreads?.results?.forEach((contacts) {
            createChat(
              contacts?.id ?? "",
              contacts?.receiverProfile?.profile?.picture ?? "",
              contacts?.receiverProfile?.userContact?.firstName ??
                  contacts?.receiverProfile?.profile?.firstName ??
                  "",
              contacts?.receiverProfile?.userContact?.lastName ??
                  contacts?.receiverProfile?.profile?.lastName ??
                  "",
              contacts?.displayMessage?.msgParams ?? "",
              contacts?.type ?? "",
              contacts?.groupData?.groupName ?? "",
              contacts?.groupData?.image ?? "",
              contacts?.groupData?.groupId ?? "",
              contacts?.groupData?.adminId ?? "",
              contacts?.groupData?.isUserExits ?? false,
              contacts?.groupData?.groupUsernameList.toString() ?? "",
              contacts?.groupData?.groupAllUsernameList.toString() ?? "",
              contacts?.displayMessage?.msgType ?? "",
              contacts?.receiverId ?? "",
              contacts?.displayMessage?.createdAt ?? "",
              contacts?.receiverProfile?.deletedAt ?? "",
              contacts?.displayMessage?.unReadCount ?? 0,
              contacts?.displayMessage?.senderId == appPreference.userID
                  ? "you".tr
                  : contacts?.displayMessage?.senderProfile?.userContact
                              ?.firstName !=
                          null
                      ? "${contacts?.displayMessage?.senderProfile?.userContact?.firstName} ${contacts?.displayMessage?.senderProfile?.userContact?.lastName ?? ""}"
                      : "${contacts?.displayMessage?.senderProfile?.profile?.firstName} ${contacts?.displayMessage?.senderProfile?.profile?.lastName ?? ""}",
              contacts?.displayMessage?.senderId ?? "",
              contacts?.displayMessage?.statusMessage.toString() ?? "",
              contacts?.displayMessage?.senderProfile?.isActive ?? false,
            );
          });
          isLoading.value = false;
        } else {
          isLoading.value = false;
          showSnackBar(response.getAllThreads!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  @override
  void onHidden() {}

  void createChat(
      String id,
      String image,
      String firstName,
      String lastName,
      String message,
      String isGroup,
      String groupName,
      String groupImage,
      String groupId,
      String adminId,
      bool isUserLeft,
      String groupUserNameList,
      String groupAllUserNameList,
      String msgType,
      String receiverId,
      String dateTime,
      String deletedAt,
      int chatCount,
      String senderName,
      String senderId,
      String statusMessage,
      bool isActive) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["id"] = id;
    contactItem["picture"] = image;
    contactItem["firstName"] = firstName;
    contactItem["lastName"] = lastName;
    contactItem["description"] = message;
    contactItem["isGroup"] = isGroup;
    contactItem["groupName"] = groupName;
    contactItem["groupImage"] = groupImage;
    contactItem["groupId"] = groupId;
    contactItem["adminId"] = adminId;
    contactItem["isUserLeft"] = isUserLeft;
    contactItem["groupUserNameList"] = groupUserNameList;
    contactItem["groupAllUserNameList"] = groupAllUserNameList;
    contactItem["msgType"] = msgType;
    contactItem["receiverId"] = receiverId;
    contactItem["dateTime"] = dateTime;
    contactItem["deletedAt"] = deletedAt;
    contactItem["chatCount"] = chatCount;
    contactItem["senderName"] = senderName;
    contactItem["senderId"] = senderId;
    contactItem["statusMessage"] = statusMessage;
    contactItem["isActive"] = isActive;
    contactsListItem.add(contactItem);
  }

  int counter = 0;

  void increment() {
    counter++;
    update(['aVeryUniqueID']); // and then here
  }

  void listenChatSocket(context) {
    BaseController.socketIO.off("newMessage-${appPreference.userID}");
    BaseController.socketIO.on("newMessage-${appPreference.userID}", (data) {
      var mapData = json.json.decode(data);
      if (mapData["data"]["status"] == 200) {
        isUserTyping.clear();
        if (contactsListItem
            .toString()
            .contains(mapData["data"]["data"]["threadId"])) {
          var list = contactsListItem
              .where((p0) => mapData["data"]["data"]["threadId"]
                  .toString()
                  .contains(p0["id"].toString()))
              .first;
          list["description"] = mapData["data"]["data"]['msgParams'];
          DateTime date = DateTime.parse(mapData["data"]["data"]['createdAt']);
          list["dateTime"] = date.millisecondsSinceEpoch.toString();
          list["senderName"] = mapData["data"]["data"]['senderName'];
          list["senderId"] = mapData["data"]["data"]['senderId'];
          list["statusMessage"] =
              mapData["data"]["data"]['statusMessage'].toString();
          list["msgType"] = mapData["data"]["data"]['msgType'];
          list["chatCount"] = mapData["data"]["data"]['unReadCount'];
          if (list["msgType"] == "status") {
            var decodeString;
            try {
              decodeString = mapData["data"]["data"]['msgParams'];
              Map<String, dynamic> data = jsonDecode(decodeString);
              if(data['groupStatus'] == 6) {
                list['groupImage'] = data['currentImage'];
              }
              else if(data['groupStatus'] == 5) {
                list['groupName'] = data['currentValue'];
                groupNameUpdate.value = list['groupName'];
              }
            } catch (e) {
              e.printError();
            }
          }

          contactsListItem.remove(list);
          contactsListItem.insert(0, list);
          contactsListItem.refresh();
        } else {
          getAllChats(context);
        }
      }
    });
  }


  void listenIsUserTypingSocket(context) {
    Map<String, String> typingUser = <String, String>{};
    BaseController.socketIO.off("updateChatPresenceStatus-${appPreference.userID}");
    BaseController.socketIO.on("updateChatPresenceStatus-${appPreference.userID}", (data) {
      typingUser[data["formattedRequest"]['data']['threadId']] =
          data["formattedRequest"]['senderName'] ?? "";
      isUserTyping.add(typingUser);
      Timer(const Duration(seconds: 3), () {
        typingUser.clear();
        isUserTyping.clear();
      });
    });
  }
}
