import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/graphql/clear_chat/__generated__/clear_chat.req.gql.dart';
import 'package:yottachat/graphql/create_thread/__generated__/create_thread.data.gql.dart';
import 'package:yottachat/graphql/create_thread/__generated__/create_thread.req.gql.dart';
import 'package:yottachat/graphql/get_all_thread_items/__generated__/get_all_thread_items.data.gql.dart';
import 'package:yottachat/graphql/get_all_thread_items/__generated__/get_all_thread_items.req.gql.dart';
import 'package:yottachat/graphql/get_all_user_contacts/__generated__/get_all_user_contacts.data.gql.dart';
import 'package:yottachat/graphql/get_all_user_contacts/__generated__/get_all_user_contacts.req.gql.dart';
import 'package:yottachat/graphql/get_contact_info/__generated__/get_contact_info.req.gql.dart';
import 'package:yottachat/graphql/read_thread/__generated__/read_chats.req.gql.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';

import '../../../config/client.dart';
import '../../../graphql/clear_chat/__generated__/clear_chat.data.gql.dart';
import '../../../graphql/delete_group/__generated__/delete_group.data.gql.dart';
import '../../../graphql/delete_group/__generated__/delete_group.req.gql.dart';
import '../../../graphql/get_contact_info/__generated__/get_contact_info.data.gql.dart';
import '../../../graphql/read_thread/__generated__/read_chats.data.gql.dart';
import '../../../utils/group_status.dart';
import '../base_controller.dart';

class ChatController extends HomeController {
  HomeNavigator? navigator;
  late Map<String, dynamic> selectedContactItem;
  int currentPage = 1;

  bool isNewChat = false;
  bool isGroupChat = false;
  RxBool isExitGroup = false.obs;
  RxList<Map<String, dynamic>> chatMessagesList = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> contactInfo = <String, dynamic>{}.obs;
  RxBool isGroupUpdate = false.obs;
  var isReceiverOnline = false.obs;
  RxBool isReceiverTyping = false.obs;
  RxBool isUserDeleted = false.obs;
  var receiverId = "";
  Map<String, String> isUserTyping = <String, String>{}.obs;
  final ScrollController chatScrollController = ScrollController();
  var isFrom = "";

  int totalCount = 0;

  @override
  void onReady() {
    super.onReady();
  }


  @override
  void onHidden() {}

  void createMap(
      String? userid,
      String message,
      String? members,
      String? datetime,
      String? userName,
      String? lastName,
      String? type,
      bool isActive) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["userId"] = userid ?? "";
    contactItem["msgParams"] = message;
    contactItem["statusMessage"] = members ?? "";
    contactItem["datetime"] = datetime ?? "";
    contactItem["firstName"] = userName ?? "";
    contactItem["lastName"] = lastName ?? "";
    contactItem["msgType"] = type ?? 'message';
    contactItem["isActive"] = isActive;
    chatMessagesList.value.insert(0, contactItem);
    chatMessagesList.refresh();
  }

  void _getContact(
      String id,
      String image,
      String firstName,
      String lastName,
      String dialCode,
      String phoneNumber,
      String phoneCountryCode,
      String description,
      bool isActive) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["id"] = id;
    contactItem["image"] = image;
    contactItem["firstName"] = firstName;
    contactItem["lastName"] = lastName;
    contactItem["dialCode"] = dialCode;
    contactItem["phoneNumber"] = phoneNumber;
    contactItem["phoneCountryCode"] = phoneCountryCode;
    contactItem["description"] = description;
    contactItem["isActive"] = isActive;
    contactInfo.addAll(contactItem);
  }

  String getStatus(
      {required String messageEventType,
      String? userName,
      String? users,
      senderId}) {
    var decode = messageEventType;
    var decodeString;
    var status = GroupStatus.none;
    try {
      decodeString = json.decode(decode);
      status = GroupStatus.values[int.parse(decodeString['groupStatus'].toString())];
    } catch (e) {
      e.printError();
    }
    switch (status) {
      case GroupStatus.created:
        return "$userName ${"you_created_this_group".tr}";
      case GroupStatus.added:
        var receiverId = decodeString['userList'];
        var id = receiverId.indexWhere((c) => c == appPreference.userID);
        if (receiverId.contains(appPreference.userID)) {
          return "$userName ${"added".tr} ${"you".tr}";
        } else {
          return users != null
              ? "$userName ${"added".tr} ${getUserNames(users, id)}"
              : "";
        }
      case GroupStatus.removed:
        var receiverId;
        if (decodeString['userList'].toString().contains('userId')) {
          receiverId = decodeString['userList'][0]['userId'];
        } else {
          receiverId = decodeString['userList'];
        }
        if (senderId == selectedContactItem['adminId']) {
          if (receiverId.contains(appPreference.userID)) {
            return "$userName ${"removed".tr} ${"you".tr}";
          } else {
            return "$userName ${"removed".tr} ${getUserNames(users)}";
          }
        } else {
          return "$userName ${"you_left".tr}";
        }
      case GroupStatus.exit:
        return "deleted_this_group".tr;
      case GroupStatus.groupNameUpdate:
        return "$userName ${"group_name_change_status".tr}";
      case GroupStatus.groupImageUpdate:
        return "$userName ${"group_image_change_status".tr}";
      case GroupStatus.none:
        return "";
    }
  }

  Future<void> sendMessage(context, message) async {
    isLoading.value = true;
    final params = GcreateThreadReq((b) => b
      ..vars.msgParams = message
      ..vars.msgType = "text"
      ..vars.receiverId = selectedContactItem["receiverId"]
      ..vars.threadId = selectedContactItem["id"] == ""
          ? receiverId
          : selectedContactItem["id"].toString()
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GcreateThreadData;
        var resultStatus = response.createThread!.status;
        if (resultStatus == 200) {
          receiverId = response.createThread?.threadId ?? "";
          readMessage(context);
        } else {
          isLoading.value = false;
          showSnackBar(response.createThread?.errorMessage ?? "", context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> getAllChats(context) async {
    isLoading.value = true;
    var threadID = selectedContactItem['id'].toString().isEmpty ? "" : selectedContactItem['id'].toString();
    final params = GgetAllThreadItemsReq((b){
      b.vars.currentPage = currentPage;
      b.vars.threadId = threadID;
      if(isFrom == "updateContacts"){
        b.vars.receiverId =  receiverID;
      }
    });
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetAllThreadItemsData;
        var resultStatus = response.getAllThreadItems!.status;
        if (resultStatus == 200) {
          totalCount = response.getAllThreadItems?.count ?? 0;
          if (response.getAllThreadItems?.results?.isNotEmpty == true) {
               chatMessagesList.value.clear();
              response.getAllThreadItems?.results?.forEach((contacts) {
                createMap(
                    contacts?.senderId ?? "",
                    contacts?.msgParams ?? "",
                    contacts?.statusMessage.toString(),
                    contacts?.createdAt,
                    contacts?.senderId == appPreference.userID ? "you".tr : contacts?.senderProfile?.userContact?.firstName ?? contacts?.senderProfile?.profile?.firstName,
                    contacts?.senderId == appPreference.userID ? "" : contacts?.senderProfile?.userContact?.lastName ?? contacts?.senderProfile?.profile?.lastName,
                    contacts?.msgType ?? "",
                    response.getAllThreadItems?.result?.isActive ?? false
                );
                contacts?.senderProfile?.profile?.picture ?? "";
              });
              isReceiverOnline.value = response.getAllThreadItems?.result?.isActive ?? false;
              isLoading.value = false;
            }
          else {
              isLoading.value = false;
              isReceiverOnline.value = response.getAllThreadItems?.result?.isActive ?? false;
            }
          isLoading.value = false;
        }
        else {
          isLoading.value = false;
          showSnackBar(response.getAllThreadItems?.errorMessage ?? "", context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> getContactInfo(context) async {
    isLoading.value = true;
    final params = GgetUserInfoReq((b) => b
      ..vars.id = selectedContactItem["receiverId"]
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetUserInfoData;
        var resultStatus = response.getUserInfo!.status;
        if (resultStatus == 200) {
          _getContact(
            response.getUserInfo?.result?.id ?? "",
            response.getUserInfo?.result?.profile?.picture ?? "",
            response.getUserInfo?.result?.userContact?.firstName ??
                response.getUserInfo?.result?.profile?.firstName ??
                "",
            response.getUserInfo?.result?.userContact?.lastName ??
                response.getUserInfo?.result?.profile?.lastName ??
                "",
            response.getUserInfo?.result?.phoneDialCode ?? "",
            response.getUserInfo?.result?.phoneNumber ?? "",
            response.getUserInfo?.result?.phoneCountryCode ?? "",
            response.getUserInfo?.result?.profile?.description ?? "",
            response.getUserInfo?.result?.isActive ?? false,
          );
          isReceiverOnline.value = contactInfo['isActive'];
          isLoading.value = false;
        }
        else {
          isLoading.value = false;
          showSnackBar(response.getUserInfo!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> readMessage(context) async {
    isLoading.value = true;
    final params = GreadThreadsReq((b) => b
      ..vars.threadId = selectedContactItem["id"]
      ..vars.chatType = isGroupChat ? "group" : "chat"
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GreadThreadsData;
        var resultStatus = response.readThreads!.status;
        if (resultStatus == 200) {
        } else {
          isLoading.value = false;
          showSnackBar(response.readThreads!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> clearMessage(context) async {
    isLoading.value = true;
    final params = GclearChatReq((b) => b
      ..vars.threadId = selectedContactItem["id"]
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GclearChatData;
        var resultStatus = response.clearChat!.status;
        if (resultStatus == 200) {
        } else {
          isLoading.value = false;
          showSnackBar(response.clearChat!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  listenChatSocket(context) {
    BaseController.socketIO.off("newMessage-${appPreference.userID}");
    BaseController.socketIO.on("newMessage-${appPreference.userID}", (data) {
      var mapData = json.decode(data);
      if (mapData["data"]["status"] == 200) {
        isUserTyping.clear();
        Map<String, String> contactItem = <String, String>{};
        if (mapData["data"]["data"]['senderId'] != appPreference.userID && (selectedContactItem["id"].contains(mapData["data"]["data"]["threadId"]) || receiverId.contains(mapData["data"]["data"]["threadId"]))) {
          contactItem["userId"] = mapData["data"]["data"]['senderId'];
          contactItem["msgParams"] = mapData["data"]["data"]['msgParams'];
          DateTime date = DateTime.parse(mapData["data"]["data"]['createdAt']);
          contactItem["datetime"] = date.millisecondsSinceEpoch.toString();
          contactItem["firstName"] = mapData["data"]["data"]['senderName'] ?? "";
          contactItem["statusMessage"] = mapData["data"]["data"]['statusMessage'].toString();
          contactItem["msgType"] = mapData["data"]["data"]['msgType'];
          contactItem["chatCount"] = mapData["data"]["data"]['unReadCount'].toString();
          if (contactItem["msgType"] == "status") {
            var status = getStatus(
                messageEventType: contactItem["msgParams"] ?? "",
                userName: contactItem["firstName"] ?? "",
                users: contactItem["statusMessage"] ?? "",
                senderId: contactItem["userId"] ?? "");
            if (status.contains("added".tr)) {
              var split = status.split("${"added".tr} ");
              addedUserNames(split[1]);
            } else if (status.contains("removed".tr)) {
              var split = status.split("${"removed".tr} ");
              removedUserNames(split[1]);
            } else if (status.contains("you_left".tr)) {
              var split = status.replaceFirst("you_left".tr, '');
              removedUserNames(split);
            }
            var decodeString;
            try {
              decodeString = mapData["data"]["data"]['msgParams'];
              Map<String, dynamic> data = jsonDecode(decodeString);
              if(data['groupStatus'] == 6) {
                selectedContactItem['groupImage'] = data['currentImage'];
                isReceiverOnline.value = false;
              }
              else if(data['groupStatus'] == 5) {
                selectedContactItem['groupName'] = data['currentValue'];
                groupNameUpdate.value = selectedContactItem['groupName'] ?? "";
                isReceiverOnline.value = false;
              }
            } catch (e) {
              e.printError();
            }
            if (status.contains("${"added".tr} ${"you".tr}")) {
              isExitGroup.value = false;
            }
            else if (status.contains("${"removed".tr} ${"you".tr}")) {
              isExitGroup.value = true;
            }
            if (status.contains("deleted_this_group".tr)) {
              selectedContactItem['groupUserNameList'] = "";
              isReceiverOnline.value = false;
              isExitGroup.value = true;
            }
          }
          chatMessagesList.insert(chatMessagesList.length, contactItem);
          chatMessagesList.refresh();
          chatScrollController.animateTo(
            chatScrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
          readMessage(context);
        }
      }
    });
  }

  listenIsUserOnlineSocket(context) {
    BaseController.socketIO.off("updatePresenceStatus");
    BaseController.socketIO.on("updatePresenceStatus", (data) {
      if (data["data"]["status"] == "online" && selectedContactItem["receiverId"].contains(data["data"]["userId"])) {
        isReceiverOnline.value = true;
      }
      else {
        getAllChats(context);
      }
      if(data["data"]?["data"]?["status"] != null) {
        if (data["data"]["data"]["status"] == "userDeleted") {
          isUserDeleted.value = true;
        }
      }
    });
  }

  Future<void> getUserContacts(context) async {
    isLoading.value = true;
    final params = GgetAllUserContactsReq();
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetAllUserContactsData;
        var resultStatus = response.getAllUserContacts!.status;
        if (resultStatus == 200) {
          contactsList.clear();
          FocusScope.of(context).unfocus();
          response.getAllUserContacts?.results?.forEach((contacts) {
            isReceiverOnline.value = contacts?.isActive ?? false;
            receiverID = contacts?.profile?.userId ?? "";
          });
          isLoading.value = false;
        } else {
          isLoading.value = false;
          showSnackBar(response.getAllUserContacts!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void sendUserTypingSocket(context) {
    List<String> arg = [
      '{"auth" : "${appPreference.accessToken}","data" : { "threadId": "${selectedContactItem["id"] == "" ? receiverId : selectedContactItem["id"].toString()}",'
          ' "userId": "${isGroupChat ? appPreference.userID : ""}" , "receiverId": "${selectedContactItem["receiverId"]}", "type": ${1} }}'
    ];
    BaseController.socketIO.emit('updateChatPresence', arg.first);
  }

  void listenIsUserTypingSocket(context) {
    BaseController.socketIO
        .off("updateChatPresenceStatus-${appPreference.userID}");
    BaseController.socketIO
        .on("updateChatPresenceStatus-${appPreference.userID}", (data) {
      if (data["formattedRequest"]['data']['userId'] != appPreference.userID) {
        isUserTyping[data["formattedRequest"]['data']['threadId']] =
            data["formattedRequest"]['senderName'] ?? "";
      }
      Timer(const Duration(seconds: 4), () {
        isUserTyping.clear();
      });
    });
  }

  Future<void> deleteGroup(context, groupId, threadId, contactId) async {
    isLoading.value = true;
    final params = GdeleteGroupReq((b) => b
      ..vars.threadId = threadId
      ..vars.groupId = groupId
      ..vars.contactId = contactId
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GdeleteGroupData;
        var resultStatus = response.deleteGroup!.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          isExitGroup.value = true;
          Map<String, String> contactItem = <String, String>{};
          if (contactId.contains(selectedContactItem['adminId'])) {
            contactItem["msgParams"] = "deleted_this_group".tr;
            contactItem["datetime"] =
                DateTime.now().millisecondsSinceEpoch.toString();
            contactItem["msgType"] = "";
            chatMessagesList.insert(chatMessagesList.length, contactItem);
            chatMessagesList.refresh();
            selectedContactItem['groupUserNameList'] = "";
            isReceiverOnline.value = false;
          } else {
            contactItem["msgParams"] = "${"you".tr} ${"you_left".tr}";
            contactItem["datetime"] = DateTime.now().millisecondsSinceEpoch.toString();
            contactItem["msgType"] = "";
            chatMessagesList.insert(chatMessagesList.length, contactItem);
            chatMessagesList.refresh();
          }
          Get.back();
        } else {
          Get.back();
          isLoading.value = false;
          showSnackBar(response.deleteGroup!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  String getUserNames(String? userList, [int? id]) {
    var users = userList;
    users = users?.replaceAll("[", "");
    users = users?.replaceAll("]", "");
    var user = users?.split(",");
    String _addedUsers = "";
    if (id?.isNaN == true) {
      for (int i = 0; i < user!.length; i++) {
        if (_addedUsers.isEmpty) {
          _addedUsers += user[i];
        } else if (i == user!.length - 1) {
          _addedUsers += " ${'and'.tr} ${user[i]}";
        } else {
          _addedUsers += ", ${user[i]}";
        }
      }
    } else {
      for (int i = 0; i < user!.length; i++) {
        if (_addedUsers.isEmpty) {
          if (id == i) {
            _addedUsers += "you".tr;
          } else {
            _addedUsers += user[i];
          }
        } else if (i == user!.length - 1) {
          if (id == i) {
            _addedUsers += " ${'and'.tr} ${"you".tr}";
          } else {
            _addedUsers += " ${'and'.tr} ${user[i]}";
          }
        } else {
          if (id == i) {
            _addedUsers += ", ${"you".tr}";
          } else {
            _addedUsers += ", ${user[i]}";
          }
        }
      }
    }
    return _addedUsers;
  }

  void removedUserNames(value) async {
    var users = selectedContactItem['groupUserNameList'];
    users = users?.replaceAll("[", "");
    users = users?.replaceAll("]", "");
    var user = users?.split(",");
    user = user.map((element) => element.trim()).toList();
    if (user.contains(value.trim())) {
      user.remove(value.trim());
    } else {
      user.remove('You');
    }
    selectedContactItem['groupUserNameList'] = user.toString();
    isReceiverOnline.value = false;
  }

  void addedUserNames(value) async {
    var users = selectedContactItem['groupUserNameList'];
    users = users?.replaceAll("[", "");
    users = users?.replaceAll("]", "");
    var user = users?.split(",");
    var newUsers = value;
    var newUser = newUsers?.split(",");
    user.addAll(newUser);
    selectedContactItem['groupUserNameList'] = user.toString();
    isReceiverOnline.value = false;
  }
}
