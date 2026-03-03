import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:yottachat/graphql/add_contacts/__generated__/add_user_contacts.data.gql.dart';
import 'package:yottachat/graphql/add_contacts/__generated__/add_user_contacts.req.gql.dart';
import 'package:yottachat/screens/views/home_page/home_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'dart:convert' as json;

import 'package:yottachat/screens/views/home_page/home_page.dart';

import '../../../config/client.dart';
import '../../../graphql/delete_contacts/__generated__/delete_user_contacts.data.gql.dart';
import '../../../graphql/delete_contacts/__generated__/delete_user_contacts.req.gql.dart';
import '../UpdateChatContact/update_chat_contacts.dart';

class NewContactController extends HomeController {
  HomeNavigator? navigator;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onResumed() {}

  Future<void> addUserContacts(context) async {
    isLoading.value = true;
    final params = GaddUserContactsReq((b) {
      if (contactsList.isNotEmpty) {
        b.vars.id = contactsList.first['contactId'];
      }
      b.vars.phoneNumber = phoneNumberController.text.toString();
      b.vars.firstName = firstNameController.text.trim().toString();
      b.vars.lastName = lastNameController.text.trim().toString();
      b.vars.dialCode = dialCode.value;
      b.vars.phoneCountryCode = country.countryCode;
      b.vars.build();
    });
    FerryLoggerClient.makeRequest(params).listen((res) async {
      if (res.data != null) {
        var response = res.data as GaddUserContactsData;
        var resultStatus = response.addUserContacts!.status;
        if (resultStatus == 200) {
          isLoading.value = false;
          Get.back(result: true);
        } else {
          isLoading.value = false;
          showSnackBar(response.addUserContacts!.errorMessage!, context);
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
          Get.back();
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
}
