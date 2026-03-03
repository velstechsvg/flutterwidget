import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/pref/app_preference.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/screens/binding/auth_binding.dart';
import 'package:yottachat/screens/views/auth/get_started/get_started_page.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import '../../resources/app_dimen.dart';
import '../../widgets/bottom_button.dart';
import '../../widgets/country_code_picker/country.dart';
import '../../widgets/handy_text.dart';
import '../../widgets/scroll_behaviour.dart';

class BaseController extends FullLifeCycleController with FullLifeCycleMixin {
  var isLoading = false.obs;
  final Connectivity _connectivity = Connectivity();
  final AppPreference appPreference = Get.find();
  RxBool isButtonEnabled = true.obs;
  Country country = const Country("United States", "flags/usa.png", "US", "+1");

  static Socket socketIO = io(
      Constants.socketURL,
      OptionBuilder()
          .setQuery({
            "auth": "---",
            "info": "new connection",
            "timestamp": DateTime.now().toString()
          })
          .setTransports(['websocket'])
          .setExtraHeaders({
            'token': Constants.authToken,
            'Connection': 'upgrade',
            'Upgrade': 'websocket'
          })
          .enableAutoConnect()
          .enableReconnection()
          .build());

  setIsLoading(bool isLoading) {
    this.isLoading.value = isLoading;
  }

  resetFerryClient() {
    link = HttpLink(Constants.URL,
        defaultHeaders: {"auth": appPreference.accessToken ?? ""});
  }

  hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppFont.font)),
        duration: const Duration(milliseconds: 2000),
      ));
  }

  showDeleteSnackBar(String msg, context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppFont.font)),
        duration: const Duration(seconds: 4),
      ));
  }

  showUserLogout(String msg, context) {
    FirebaseMessaging.instance.deleteToken().then((value) {
      socketIO.off("loginCheck-${appPreference.userID}");
      appPreference.removePreference();
      if (msg != null && msg.isNotEmpty && !msg.contains("null"))
        showToast(msg);
      resetFerryClient();
      Get.offAll(() => const GetStartedPage(),
          binding: AuthBinding(),
          arguments: {"isLogin": false},
          routeName: "/getStartedPage");
    });
  }

  showSnackBarWithRetry(String msg, Function calledFunction, context) {
    Get.showSnackbar(GetSnackBar(
      mainButton: InkWell(
          onTap: () {
            isLoading.value = true;
            if (Get.isSnackbarOpen == true) {
              Get.back();
            }
            checkNetwork(context, calledFunction);
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
            child: Text(
              "retry".tr,
              style: const TextStyle(color: AppColors.white),
            ),
          )),
      message: msg,
      isDismissible: false,
      duration: const Duration(days: 1),
      animationDuration: const Duration(milliseconds: 200),
    ));
  }

  showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg.tr,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.white,
      textColor: AppColors.black,
      fontSize: 16.0,
    );
  }

  isValidEmail(String email) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  checkNetwork(context, Function calledFunction) async {
    var connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        isLoading.value = false;
        if (Get.isSnackbarOpen == true) {
          Get.back();
        }
        showSnackBarWithRetry("you_are_offline".tr, calledFunction, context);
      } else {
        hideSnackBar(context);
        if (Get.isSnackbarOpen == true) {
          Get.back();
        }
        isLoading.value = false;
        calledFunction();
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Widget showCenterLoading(context, [loadingFile, Size]) {
    return Visibility(
      visible: isLoading.value,
      child: Container(
        width: Size ?? MediaQuery.of(context).size.width,
        height: Size ?? MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: Size ?? 100,
            height: Size ?? 100,
            child: Lottie.asset(loadingFile ?? "assets/loader.json"),
          ),
        ),
      ),
    );
  }

  String calculateHours(double duration) {
    if (duration >= 60) {
      var totalHour = (duration / 60).toStringAsFixed(2);
      var splitArr = totalHour.split(".");

      if (double.parse(splitArr[1]) >= 60) {
        return getIntegerNumber((double.parse(splitArr[0]) + 1).toString()) +
            "h " +
            getIntegerNumber((double.parse(splitArr[1]) - 60).toString()) +
            "m";
      } else {
        return splitArr[0] + "h " + splitArr[1] + "m";
      }
    } else if (duration >= 1 && duration < 60) {
      var totalMin = duration.toStringAsFixed(2);
      var splitArr = totalMin.split(".");
      if (double.parse(splitArr[1]) >= 60) {
        return getIntegerNumber((double.parse(splitArr[0]) + 1).toString()) +
            "m " +
            getIntegerNumber((double.parse(splitArr[1]) - 60).toString()) +
            "s";
      } else {
        return splitArr[0] + "m " + splitArr[1] + "s";
      }
    } else {
      var totalSec = duration.toStringAsFixed(2);
      var splitArr = totalSec.split(".");

      if (double.parse(splitArr[1]) >= 60) {
        return "1m " +
            getIntegerNumber((double.parse(splitArr[1]) - 60).toString()) +
            "s";
      }

      if (double.parse(splitArr[1]) >= 10) {
        return splitArr[1] + "s";
      } else {
        return splitArr[1][1] + "s";
      }
    }
  }

  String getStatusName(String apiStatus) {
    String status = "";
    if (apiStatus == "created") {
      status = "created".tr;
    } else if (apiStatus == "declined") {
      status = "declined".tr;
    } else if (apiStatus == "approved") {
      status = "approved".tr;
    } else if (apiStatus == "arrived") {
      status = "arrived".tr;
    } else if (apiStatus == "reviewed") {
      status = "reviewed".tr;
    } else if (apiStatus == "started") {
      status = "started".tr;
    } else if (apiStatus == "cancelledByUser") {
      status = "cancelledByUser".tr;
    } else if (apiStatus == "cancelledByPartner") {
      status = "cancelledByPartner".tr;
    } else if (apiStatus == "completed") {
      status = "completed".tr;
    } else if (apiStatus == "expired") {
      status = "expired".tr;
    } else {
      status = "expired".tr;
    }

    return status;
  }

  String getIntegerNumber(String? inputNum) {
    String? outputNum = "";
    if (!inputNum!.contains(".")) {
      outputNum = inputNum;
    } else {
      List<String> splitValue = inputNum.split(".");
      if (splitValue[1] == "0" || int.parse(splitValue[1]) == 0) {
        outputNum = splitValue[0];
      } else if (int.parse(splitValue[1]) >= 0) {
        outputNum = double.parse(inputNum).toStringAsFixed(2);
      }
    }
    return outputNum;
  }

  String getCurrencySymbol() {
    var format =
        NumberFormat.simpleCurrency(name: appPreference.preferredCurrency);
    String currencySymbol = format.currencySymbol;
    if (appPreference.preferredCurrency!.compareTo("HKD") == 0) {
      return "HK$currencySymbol";
    } else if (appPreference.preferredCurrency!.compareTo("MXN") == 0) {
      return "MX$currencySymbol";
    } else if (appPreference.preferredCurrency!.compareTo("NZD") == 0) {
      return "NZ$currencySymbol";
    } else if (appPreference.preferredCurrency!.compareTo("CNY") == 0) {
      return "CN$currencySymbol";
    } else if (appPreference.preferredCurrency!.compareTo("AUD") == 0) {
      return "A$currencySymbol";
    } else if (appPreference.preferredCurrency!.compareTo("CAD") == 0) {
      return "CA$currencySymbol";
    } else {
      return currencySymbol;
    }
  }

  DateTime getDateFromTimeStamp(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return date;
  }

  bool isDirectionRTL(BuildContext context) {
    return Bidi.isRtlLanguage(Get.locale?.languageCode);
  }

  showBottomSheet(List<Widget> contentWidgets, {isDismissible = false}) {
    isLoading.value = false;
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        padding: pad(w: 25.0, top: 30.0, bottom: 20.0),
        child: ScrollConfiguration(
            behavior: ListViewScrollBehavior(),
            child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: contentWidgets!.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return contentWidgets[index];
                })),
      ),
      isDismissible: isDismissible,
      enableDrag: false,
      isScrollControlled: true,
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void onInit() {
    sendUserIsOnlineSocket();
    super.onInit();
  }


  @override
  void onPaused() {
    sendUserIsOfflineSocket();
  }

  @override
  void onResumed() {
    socketIO.connect();
    sendUserIsOnlineSocket();
  }

  sendUserIsOnlineSocket() {
    List<String> arg = [
      '{"auth" : "${appPreference.accessToken}","data" : { "status": "online" }}'
    ];
    BaseController.socketIO.emit('updatePresence', arg.first);
  }

  sendUserIsOfflineSocket() {
    List<String> arg = [
      '{"auth" : "${appPreference.accessToken}","data" : { "status": "offline" }}'
    ];
    BaseController.socketIO.emit('updatePresence', arg.first);
  }

  @override
  void onHidden() {}

  uploadImage(context, var image, from,[groupId]) async {
    isLoading.value = true;
    String filepath = image;
    String filename = filepath.split("/").last;
    filename = filename.split("_").last;
    http.MultipartRequest request;
    if (from == "group") {
      request = http.MultipartRequest(
          'POST', Uri.parse("${Constants.UPLOAD_URL}/uploadGroupPhoto"));
    }
    else {
      request = http.MultipartRequest(
          'POST', Uri.parse("${Constants.UPLOAD_URL}/uploadProfilePhoto"));
    }
    Map<String, String> headers = {};
    if(groupId!=null){
      headers = {"auth": Constants.authToken!,"groupid":groupId};
    }
    else {
      headers = {"auth": Constants.authToken!};
    }
    request.files.add(http.MultipartFile('file',
        File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
        filename: filename,
        contentType: MediaType("image", filename.split(".").last)));
    if (from != "signup") {
      request.headers.addAll(headers);
    }
    var res;
    http.Response? response;
    try {
      res = await request.send();
      response = await http.Response.fromStream(res);
    } catch (e) {
      isLoading.value = false;
      showSnackBar("you_offline".tr, context);
    }

    final result = json.decode(response!.body);
    if (result["status"] == 200) {
      isLoading.value = false;
      if (from == "signup") {
        return "${Constants.profileImagePath}${result["files"][0]["filename"]}";
      } else if (from == "group") {
        return "${Constants.groupImagePath}${result["files"][0]["filename"]}";
      } else {
        return "${Constants.profileImagePath}${appPreference.userID}/${result["files"][0]["filename"]}";
      }
    } else {
      isLoading.value = false;
      showSnackBar("some_thing_error".tr, context);
    }
  }

  showCommonBottomSheet(
      {String? title,
      required String description,
      required Function OkButtonCallback,
      required String OkButtonLabel,
      bool isShowCancelButton = true}) {
    showBottomSheet([
      if (title != null)
        CustomText(
          text: title,
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_18,
          textAlign: TextAlign.center,
        ),
      10.toHeight(),
      CustomText(
        text: description,
        textAlign: TextAlign.center,
      ),
      26.toHeight(),
      Obx(() => AbsorbPointer(
          absorbing: !isButtonEnabled.value,
          child: InkWell(
            onTap: () {
              isButtonEnabled.value = false;
              OkButtonCallback();
              Future.delayed(const Duration(seconds: 2))
                  .then((value) => isButtonEnabled.value = true);
            },
            child: BottomButton(
              disablePadding: true,
              isLoading: isLoading.value,
              buttonText: OkButtonLabel,
              isBottomSheet: true,
            ),
          ))),
      if (isShowCancelButton) 12.toHeight(),
      if (isShowCancelButton) CancelButton(buttonText: 'no_thanks'.tr),
      20.toHeight(),
    ]);
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}
}