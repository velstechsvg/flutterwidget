import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:ferry/ferry.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'dart:convert';

import 'package:yottachat/pref/app_preference.dart';

final AppPreference appPreference = Get.find();

HttpLink link = HttpLink(Constants.URL,
    defaultHeaders: {"auth": appPreference.accessToken ?? ""});

class FerryLoggerClient extends Client {
  FerryLoggerClient({Key? key}) : super(link: link);
  static Client? client;
  static Stream<OperationResponse<dynamic, dynamic>> makeRequest(
      OperationRequest<dynamic, dynamic> request) {
    FerryLoggerClient.client?.requestController.close();
    Get.printInfo(info: "link: " + link.defaultHeaders.toString());
    client = Client(link: link, defaultFetchPolicies: {
      OperationType.query: FetchPolicy.NetworkOnly,
      OperationType.mutation: FetchPolicy.NetworkOnly,
      OperationType.subscription: FetchPolicy.NetworkOnly
    });
    const JsonEncoder _encoder = JsonEncoder.withIndent('');
    Get.printInfo(info: "AuthToken: " + (appPreference.accessToken ?? ""));
    Get.printInfo(info: _encoder.convert(request));
    var response = client!.request(request);
    response.listen((response) {
      Get.printInfo(info: _encoder.convert(response.data));
    }, onError: (error) {});
    return response;
  }
}
