import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:yottachat/constant.dart' as Constants;
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/screens/views/chat/chat_view.dart';

import 'config/client.dart';

class FirebaseMessagingService {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Map<String, dynamic> selectedContact = {};

  FirebaseMessagingService() {
    initFireBase();
  }

  Future<void> initFireBase() async {
    setupInteractedMessage();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    listenFirebase();
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  listenFirebase() {
    FirebaseMessaging.onMessage.listen((event) {
      Map<String, dynamic> map = json.decode(event.data['content']);
      if (map['threadId'] != Constants.lastViewedThreadId) {
        if (Platform.isAndroid) {
          if (map["groupName"] != null) {
            if (map['message'].contains(':')) {
              showNotification(map['groupName'], map['message'], map);
            } else {
              showNotification(map['groupName'],
                  "${map['senderName']}: ${map['message']}", map);
            }
          } else {
            showNotification(map['senderName'], map['message'], map);
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      Map<String, dynamic> map = json.decode(event.data['content']);
      getAPIData(map);
      await appPreference.pref.initStorage.then((value) {
        if (appPreference.userID != "") {
          Get.back();
          Get.to(
            () => const ChatView(),
            transition: Transition.noTransition,
            arguments: {"selectedContact": selectedContact, "from": "fcm"},
            routeName: "/chatView",
          );
        }
      });
    });
  }

  showNotification(
      String title, String body, Map<String, dynamic> message) async {
    getAPIData(message);
    var android = const AndroidNotificationDetails('user id', "user channel",
        channelDescription: "user description",
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notify',
        styleInformation: BigTextStyleInformation(''),
        color: AppColors.primaryColor);
    var iOS = const NotificationDetails().iOS;
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: "chatPage");
    var androidInitialize = const AndroidInitializationSettings('ic_notify');
    var iOSInitialize = const InitializationSettings().iOS;
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload == "chatPage") {
          await appPreference.pref.initStorage.then((value) {
            if (appPreference.userID != "") {
              Get.back();
              Get.to(
                () => const ChatView(),
                transition: Transition.noTransition,
                arguments: {"selectedContact": selectedContact, "from": "fcm"},
                routeName: "/chatView",
              );
            }
          });
        }
      },
    );
  }

  void _createChat(
      {required String id,
      required String image,
      required String firstName,
      required String lastName,
      required String message,
      required String isGroup,
      required String groupName,
      required String groupImage,
      required String groupId,
      required String adminId,
      required bool isUserLeft,
      required String groupUserNameList,
      required String groupAllUserNameList,
      required String msgType,
      required String receiverId,
      required String dateTime,
      required int chatCount,
      required String senderName,
      required String senderId,
      required String statusMessage,
      required bool isActive}) {
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
    contactItem["chatCount"] = chatCount;
    contactItem["senderName"] = senderName;
    contactItem["senderId"] = senderId;
    contactItem["statusMessage"] = statusMessage;
    contactItem["isActive"] = isActive;
    selectedContact = contactItem;
  }

  void getAPIData(message) {
    _createChat(
        id: message['threadId'] ?? "",
        image: message['profile.picture'] ?? "",
        firstName: message['senderName'] ?? "",
        lastName: "",
        message: message['msgParams'] ?? "",
        groupName: message['groupName'] ?? "",
        isGroup: message['isGroup'] != null ? "group" : "",
        groupImage: message['image'] ?? "",
        groupId: message['groupId'] ?? "",
        adminId: message['adminId'] ?? "",
        isUserLeft: true,
        groupUserNameList: message['groupUsernameList'].toString(),
        groupAllUserNameList: message['groupAllUsernameList'].toString(),
        msgType: message['msgType'] ?? "",
        receiverId: message['senderId'] ?? "",
        dateTime: message['createdAt'] ?? "",
        chatCount: 0,
        senderName: message['senderName'] ?? "",
        senderId: message['senderId'] ?? "",
        statusMessage: message['statusMessage'] ?? "",
        isActive: true);
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Map<String, dynamic> map = json.decode(initialMessage.data['content']);
      getAPIData(map);
      Constants.chatDetailsFromFCM = selectedContact;
    }
  }
}
