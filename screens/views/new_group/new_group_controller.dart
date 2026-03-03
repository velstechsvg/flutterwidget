import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/graphql/create_group/__generated__/create_group.data.gql.dart';
import 'package:yottachat/graphql/create_group/__generated__/create_group.req.gql.dart';
import 'package:yottachat/graphql/delete_group/__generated__/delete_group.req.gql.dart';
import 'package:yottachat/graphql/get_group_info/__generated__/get_group_info.data.gql.dart';
import 'package:yottachat/graphql/get_group_info/__generated__/get_group_info.req.gql.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';

import '../../../config/client.dart';
import '../../../constant.dart';
import '../../../graphql/delete_group/__generated__/delete_group.data.gql.dart';
import '../../../graphql/get_all_threads/__generated__/get_all_threads.data.gql.dart';
import '../../../graphql/get_all_threads/__generated__/get_all_threads.req.gql.dart';
import '../camera_screen/camera_controller.dart';
import '../chat/chat_view.dart';

class NewGroupController extends HomeController {
  HomeNavigator? navigator;

  TextEditingController groupNameController = TextEditingController();
  var cameras;

  RxString groupImage = ''.obs;
  RxString groupName = ''.obs;
  RxString groupId = ''.obs;
  RxString adminId = ''.obs;
  RxList<Map<String, dynamic>> selectedGroupContacts =
      <Map<String, dynamic>>[].obs;
  Map<String, dynamic> contactInfo = <String, dynamic>{}.obs;
  RxBool isGroupNameChanged = false.obs;
  String _initialGroupName = "";

  @override
  void onReady() {
    super.onReady();
    availableCameras().then((value) {
      cameras = value;
    });
    groupNameController.addListener(() {
      groupName.value = groupNameController.text.toString();
      if(_initialGroupName == groupNameController.text.toString()) {
        isGroupNameChanged.value = false;
        groupNameUpdate.value = groupNameController.text.toString();
      } else {
        isGroupNameChanged.value = true;
      }
      groupName.refresh();
    });
  }

  @override
  void onResumed() {}

  Future<void> deleteGroup(context, groupId, threadId, contactId, contactName) async {
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
          Get.back();
          Get.back(result: contactName);
        } else {
          isLoading.value = false;
          Get.back();
          showSnackBar(response.deleteGroup!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> createGroup(context,[groupId]) async {
    isLoading.value = true;
    var sendImageFile = groupImage.value.replaceAll(Constants.groupImagePath, "");
    List<String> listId = [];
    selectedGroupContacts.forEach((element) {
      listId.add("{\"userId\":\"${element["receiverId"]}\",\"phoneNumber\":\"${element["phoneNumber"]}\"}");
    });
    final params = GcreateGroupReq((b) => b
      ..vars.groupId = groupId
      ..vars.contacts = listId.toString()
      ..vars.groupName = groupName.value
      ..vars.image = sendImageFile
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GcreateGroupData;
        var resultStatus = response.createGroup!.status;
        if (resultStatus == 200) {
          groupNameUpdate.value = response.createGroup?.result?.groupName ?? groupName.value;
          await Future.delayed(const Duration(milliseconds: 200));
          getAllChats(context,groupId);
        } else {
          isLoading.value = false;
          showSnackBar(response.createGroup!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  Future<void> getAllChats(context,groupId) async {
    final params = GgetAllThreadsReq((b) => b
      ..vars.currentPage = 1
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetAllThreadsData;
        var resultStatus = response.getAllThreads!.status;
        if (resultStatus == 200) {
          response.getAllThreads?.results?.forEach((list) {
            _createChat(
                list?.id ?? "",
                list?.receiverProfile?.profile?.picture ??
                    "",
                list?.receiverProfile?.userContact?.firstName ??
                    list?.receiverProfile?.profile
                        ?.firstName ??
                    "",
                list?.displayMessage?.msgParams ??
                    "",
                list?.type ?? "",
                list?.groupData?.groupName ?? "",
                list?.groupData?.image ?? "",
                list?.groupData?.groupId ?? "",
                list?.groupData?.groupUsernameList.toString() ?? "",
                list?.groupData?.groupAllUsernameList.toString() ?? "",
                list?.displayMessage?.msgType ?? "",
                list?.receiverId ?? "",
                list?.displayMessage?.createdAt ?? "",
                list?.displayMessage?.unReadCount ?? 0,
                list?.displayMessage?.senderId == appPreference.userID ? "you".tr : list?.displayMessage?.senderProfile?.userContact?.firstName ?? list?.displayMessage?.senderProfile?.profile?.firstName ?? "",
                list?.groupData?.adminId ?? "");
          });
          if(groupId!=null) {
            Future.delayed(const Duration(milliseconds: 300)).then((v){
              Get.to(() => const ChatView(),
                  arguments: {
                    "selectedContact": contactsListItem.firstWhere((element) => element["groupId"].contains(groupId)),
                    "from": "newGroup",
                    "groupName": groupNameUpdate.value,
                  },
                  routeName: "/chatView");
            });
          }
          else {
            Future.delayed(const Duration(milliseconds: 300)).then((v){
              Get.to(() => const ChatView(),
                  arguments: {
                    "selectedContact": contactsListItem.first,
                    "from": "newGroup",
                    "groupName": groupNameUpdate.value,
                  },
                  routeName: "/chatView");
            });
          }
          isLoading.value = false;
        }
        else {
          isLoading.value = false;
          showSnackBar(response.getAllThreads!.errorMessage!, context);
        }
      }
      else {
        isLoading.value = false;
      }
    });
  }

  Future<void> getGroupInfo(context, groupId) async {
    final params = GgetGroupInfoReq((b) => b
      ..vars.groupId = groupId
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetGroupInfoData;
        var resultStatus = response.getGroupInfo!.status;
        if (resultStatus == 200) {
          selectedGroupContacts.clear();
          response.getGroupInfo?.result?.groupUsers?.forEach((contacts) {
            _getContact(
                contacts?.userId ?? "",
                contacts?.profileData?.profile?.picture ?? "",
                contacts?.userId == appPreference.userID
                    ? "you".tr
                    : contacts?.profileData?.userContact?.firstName ??
                        contacts?.profileData?.profile?.firstName ??
                        "",
                contacts?.userId == appPreference.userID
                    ? ""
                    : contacts?.profileData?.userContact?.lastName ??
                        contacts?.profileData?.profile?.lastName ??
                        "",
                contacts?.profileData?.profile?.description ?? "");
          });
          groupNameController.text = response.getGroupInfo?.result?.groupName ?? "";
          _initialGroupName = response.getGroupInfo?.result?.groupName ?? "";
          if(_initialGroupName == groupNameController.text.toString()) {
            isGroupNameChanged.value = false;
            groupNameUpdate.value =  response.getGroupInfo?.result?.groupName ?? groupNameController.text.toString();
          }
          else {
            isGroupNameChanged.value = true;
          }
          adminId.value = response.getGroupInfo?.result?.adminId ?? "";
          if (response.getGroupInfo?.result?.image?.isNotEmpty == true) {
            groupImage.value =
                "$groupImagePath${response.getGroupInfo?.result?.image}";
          }
          isLoading.value = false;
        } else {
          isLoading.value = false;
          showSnackBar(response.getGroupInfo!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void _getContact(String id, String image, String firstName, String lastName,
      String description) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["receiverId"] = id;
    contactItem["picture"] = image;
    contactItem["firstName"] = firstName;
    contactItem["lastName"] = lastName;
    contactItem["description"] = description;
    selectedGroupContacts.add(contactItem);
  }

  void _createChat(
      String id,
      String image,
      String firstName,
      String message,
      String isGroup,
      String groupName,
      String groupImage,
      String groupId,
      String groupUserNameList,
      String groupAllUserNameList,
      String msgType,
      String receiverId,
      String dateTime,
      int chatCount,
      String senderName,
      String adminId) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["id"] = id;
    contactItem["picture"] = image;
    contactItem["firstName"] = firstName;
    contactItem["description"] = message;
    contactItem["isGroup"] = isGroup;
    contactItem["groupName"] = groupName;
    contactItem["groupImage"] = groupImage;
    contactItem["groupId"] = groupId;
    contactItem["groupUserNameList"] = groupUserNameList;
    contactItem["groupAllUserNameList"] = groupAllUserNameList;
    contactItem["msgType"] = msgType;
    contactItem["receiverId"] = receiverId;
    contactItem["dateTime"] = dateTime;
    contactItem["chatCount"] = chatCount;
    contactItem["senderName"] = senderName;
    contactItem["adminId"] = adminId;
    contactsListItem.add(contactItem);
  }
}
