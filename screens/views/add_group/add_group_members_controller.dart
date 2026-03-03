import 'package:built_collection/src/list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:yottachat/graphql/add_user_in_group/__generated__/add_user_in_group.req.gql.dart';
import 'package:yottachat/screens/views/chat/chat_view.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';

import '../../../config/client.dart';
import '../../../graphql/add_user_in_group/__generated__/add_user_in_group.data.gql.dart';
import '../../../graphql/get_all_user_contacts/__generated__/get_all_user_contacts.data.gql.dart';
import '../../../graphql/get_all_user_contacts/__generated__/get_all_user_contacts.req.gql.dart';
import '../../../graphql/get_group_info/__generated__/get_group_info.ast.gql.dart';
import '../../../graphql/get_group_info/__generated__/get_group_info.ast.gql.dart';
import '../../../graphql/get_group_info/__generated__/get_group_info.data.gql.dart';
import '../../../graphql/get_group_info/__generated__/get_group_info.req.gql.dart';

class AddGroupMembersController extends HomeController {
  HomeNavigator? navigator;

  TextEditingController searchContactController = TextEditingController();
  List<Map<String, dynamic>> selectedcontactsList = <Map<String, dynamic>>[];
  List<String> existsUsersIdList = [];

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getUserContacts(context, [List? existsUsersIdList]) async {
    final params = GgetAllUserContactsReq();
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GgetAllUserContactsData;
        var resultStatus = response.getAllUserContacts!.status;
        if (resultStatus == 200) {
          contactsList.clear();
          response.getAllUserContacts?.results?.forEach((contacts) {
            _createContact(
                existsUsersIdList,
                contacts?.threadId ?? "",
                "",
                contacts?.firstName ?? "",
                contacts?.lastName ?? "",
                contacts?.dialCode ?? "",
                contacts?.phoneNumber ?? "",
                contacts?.isPlatformUser ?? false,
                contacts?.profile?.description ?? "",
                contacts?.profile?.userId ?? "",
                contacts?.profile?.picture ?? "");
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

  Future<List<String>> getGroupInfo(context, groupId) async {
    isLoading.value = true;
    final params = GgetGroupInfoReq((b) => b
      ..vars.groupId = groupId
      ..vars.build());
    try {
      var response = await FerryLoggerClient.makeRequest(params).first;

      if (response.data != null) {
        var responseData = response.data as GgetGroupInfoData;
        var resultStatus = responseData.getGroupInfo!.status;
        if (resultStatus == 200) {
          List<String> existsUsersIdList = [];
          responseData.getGroupInfo?.result?.groupUsers?.forEach((contacts) {
            existsUsersIdList.add(contacts?.userId ?? "");
          });

          return existsUsersIdList;
        }
      }
      return existsUsersIdList;
    } catch (error) {
      throw 'Error fetching data: $error';
    }
  }

  Future<void> addUserInGroup(
      context, groupId, threadId, addedUserNames) async {
    isLoading.value = true;
    List<String> listId = [];
    selectedcontactsList.forEach((element) {
      listId.add(
          "{\"userId\":\"${element["receiverId"]}\",\"phoneNumber\":\"${element["phoneNumber"]}\"}");
    });
    final params = GaddUserInGroupReq((b) => b
      ..vars.contacts = listId.toString()
      ..vars.groupId = groupId
      ..vars.threadId = threadId
      ..vars.build());
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GaddUserInGroupData;
        var resultStatus = response.addUserInGroup!.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          Get.back();
          Get.back(result: addedUserNames.toString());
        } else {
          Get.back();
          isLoading.value = false;
          showSnackBar(response.addUserInGroup!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void _createContact(
      existsUsersIdList,
      String id,
      String image,
      String firstName,
      String lastName,
      String dialCode,
      String phoneNumber,
      bool isPlatformUser,
      String description,
      String userId,
      String picture) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["id"] = id;
    contactItem["image"] = image;
    contactItem["firstName"] = firstName;
    contactItem["lastName"] = lastName;
    contactItem["dialCode"] = dialCode;
    contactItem["phoneNumber"] = phoneNumber;
    contactItem["isPlatformUser"] = isPlatformUser;
    contactItem["description"] = description;
    contactItem["receiverId"] = userId;
    contactItem["picture"] = picture;
    if (existsUsersIdList.isNotEmpty) {
      if (contactItem["isPlatformUser"] &&
          contactItem["receiverId"] != appPreference.userID &&
          (!(existsUsersIdList.contains(contactItem['receiverId'])))) {
        contactsList.add(contactItem);
      }
    } else {
      if (contactItem["isPlatformUser"] &&
          contactItem["receiverId"] != appPreference.userID) {
        contactsList.add(contactItem);
      }
    }
  }

  @override
  void onResumed() {}
}
