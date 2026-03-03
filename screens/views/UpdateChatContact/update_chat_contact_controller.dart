import 'package:built_collection/src/list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/constant.dart';
import 'package:yottachat/graphql/delete_contacts/__generated__/delete_user_contacts.req.gql.dart';
import 'package:yottachat/graphql/get_all_user_contacts/__generated__/get_all_user_contacts.data.gql.dart';
import 'package:yottachat/graphql/get_all_user_contacts/__generated__/get_all_user_contacts.req.gql.dart';
import 'package:yottachat/screens/binding/home_binding.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'dart:convert' as json;

import 'package:yottachat/screens/views/home_page/home_page.dart';

import '../../../graphql/delete_contacts/__generated__/delete_user_contacts.data.gql.dart';

class updateChatContactsController extends HomeController {
  HomeNavigator? navigator;

  TextEditingController searchContactController = TextEditingController();
  RxInt selectedContactsCount = 0.obs;

  @override
  void onReady() {
    super.onReady();
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
            _createContact(
                contacts?.id ?? 0,
                contacts?.threadId ?? "",
                "",
                contacts?.firstName ?? "",
                contacts?.lastName ?? "",
                contacts?.dialCode ?? "",
                contacts?.phoneNumber ?? "",
                contacts?.phoneCountryCode ?? "",
                contacts?.isPlatformUser ?? false,
                contacts?.profile?.description ?? "",
                contacts?.profile?.userId ?? "",
                contacts?.isActive ?? false,
                contacts?.profile?.picture ?? "");
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

  Future<void> deleteUserContacts(context, list) async {
    isLoading.value = true;
    final params = GdeleteUserContactsReq((b) => b
      ..vars.id = list
      ..vars.build());

    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GdeleteUserContactsData;
        var resultStatus = response.deleteUserContacts!.status;
        if (resultStatus == 200) {
          getUserContacts(context);
          Get.back();
        } else {
          isLoading.value = false;
          showSnackBar(response.deleteUserContacts!.errorMessage!, context);
        }
      } else {
        isLoading.value = false;
      }
    });
  }

  void _createContact(
      int contactId,
      String id,
      String image,
      String firstName,
      String lastName,
      String dialCode,
      String phoneNumber,
      String phoneCountryCode,
      bool isPlatformUser,
      String description,
      String userId,
      bool isActive,
      String picture) {
    Map<String, dynamic> contactItem = <String, dynamic>{};
    contactItem["contactId"] = contactId;
    contactItem["id"] = id;
    contactItem["image"] = image;
    contactItem["firstName"] = firstName;
    contactItem["lastName"] = lastName;
    contactItem["dialCode"] = dialCode;
    contactItem["phoneNumber"] = phoneNumber;
    contactItem["phoneCountryCode"] = phoneCountryCode;
    contactItem["isPlatformUser"] = isPlatformUser;
    contactItem["description"] = description;
    contactItem["receiverId"] = userId;
    contactItem["isActive"] = isActive;
    contactItem["picture"] = picture;
    contactsList.add(contactItem);
  }

  @override
  void onResumed() {}
}
