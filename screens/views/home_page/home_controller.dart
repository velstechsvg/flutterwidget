import 'dart:convert' as json;

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart' as constants;
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/widgets/country_code_picker/country.dart';

import 'home_navigator.dart';

class HomeController extends BaseController {
  HomeNavigator? navigator;

  var popularCategory = [].obs;
  var recentCategory = [];
  Country? countryName;
  String? countryCode = "";
  var dialCode = "".obs;
  var phoneCountryCode = "".obs;
  RxList<Map<String, dynamic>> contactsList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> contactsListItem = <Map<String, dynamic>>[].obs;

  Socket socketIO = io(
      constants.socketURL,
      OptionBuilder()
          .setQuery({
        "auth": "---",
        "info": "new connection",
        "timestamp": DateTime.now().toString()
      })
          .setTransports(['websocket'])
          .setExtraHeaders({
        'token': constants.authToken,
        'Connection': 'upgrade',
        'Upgrade': 'websocket'
      })
          .enableAutoConnect()
          .enableReconnection()
          .build());

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onHidden() {}


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


  void addUserLoginSocketListener(context) {
    String id = appPreference.userID!;
    BaseController.socketIO.off("loginCheck-${id}");
    BaseController.socketIO.on("loginCheck-${id}", (data) {
      var mapData = json.json.decode(data);
      if (mapData["data"]["status"] == 200) {
        showUserLogout(mapData["data"]["errorMessage"] ?? "your_session_expr".tr, context);
        BaseController.socketIO.off("loginCheck-${id}");
        BaseController.socketIO.off("updatePresenceStatus-${id}");
      }
      else if (mapData["data"]["status"] == 400) {
        String errorMSG = mapData["data"]["errorMessage"];
        showUserLogout(errorMSG, context);
        BaseController.socketIO.off("loginCheck-${id}");
      }
    });
  }
}
