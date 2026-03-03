import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/utils/group_status.dart';
import 'package:yottachat/widgets/handy_text.dart';
import 'package:yottachat/widgets/svg_shadow.dart';
import 'package:intl/intl.dart';
import '../resources/app_colors.dart';
import '../resources/app_dimen.dart';
import '../utils/click_utils.dart';
import 'country_code_picker/function.dart';
import 'custom_search_field.dart';
import 'scroll_behaviour.dart';
import 'package:yottachat/constant.dart' as Constants;

class ContactItem extends GetView {
  final Widget? trailWidget;
  String userImage = "";

  String receiverId = "";
  final String? userName;

  final String? userStatus;

  int index = 0;

  int chatCount = 0;

  bool isLastIndex = false;
  double LastIndexGap;
  bool isLongPressEnabled = false;
  double? imageSize = 52;
  double? imageTextPadding = 15;
  String placeHolderImage;
  bool removePadding;
  int selected = 0;
  String time = "";
  String isUserTyping = "";
  Widget? exploreTime;
  Widget? exploreCount;

  ContactItem(
      {key,
      this.trailWidget,
      required this.userImage,
      required this.placeHolderImage,
      this.userName,
      this.userStatus,
      this.imageSize,
      this.imageTextPadding,
      required this.index,
      required this.isLastIndex,
      required this.LastIndexGap,
      this.chatCount = 0,
      this.removePadding = false,
      this.isUserTyping = "",
      this.selected = 0,
      this.isLongPressEnabled = false,
      this.receiverId = "",
      this.time = "",
      this.exploreCount,
      this.exploreTime});

  @override
  Widget build(BuildContext context) {
    if (imageSize == null) {
      imageSize = 50;
      imageTextPadding = 15;
    }

    return Container(
      color:
          isLongPressEnabled && selected == 1 ? AppColors.textfieldColor : null,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getUserProfileImage(
                userImage,
                imageSize!,
                receiverId,
                placeHolderImage,
              ),
              imageTextPadding!.toWidth(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exploreTime != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                                text: userName ?? "",
                                fontWeight: AppFont.medium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (exploreTime != null)
                            GestureDetector(child: exploreTime!)
                        ],
                      ),
                    ] else ...[
                      CustomText(
                          text: userName ?? "",
                          fontWeight: AppFont.medium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: isUserTyping != "null"
                                ? Text(
                                    isUserTyping != ""
                                        ? "$isUserTyping ${"is_typing".tr}"
                                        : "typing".tr,
                                    style: const TextStyle(
                                        color: AppColors.secondaryTextColor,
                                        fontWeight: AppFont.regular,
                                        fontSize: AppDimen.textSize_14,
                                        fontStyle: FontStyle.italic),
                                  )
                                : Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(end: 30),
                                    child: CustomText(
                                      text: userStatus ?? "",
                                      color: chatCount != 0
                                          ? AppColors.secondaryTextColor
                                          : AppColors.chatStatusColor,
                                      size: AppDimen.textSize_14,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: chatCount != 0
                                          ? AppFont.medium
                                          : AppFont.regular,
                                    ),
                                  )),
                        if (exploreCount != null)
                          GestureDetector(child: exploreCount!)
                      ],
                    ),
                  ],
                ),
              ),
              if (trailWidget != null) GestureDetector(child: trailWidget!)
            ],
          ).toPad(
              start: !removePadding ? 10.0 : 25.0,
              end: !removePadding ? 0.0 : 25.0,
              top: 10,
              bottom: 10),
          if (!isLastIndex) showDivider().toPad(start: 90.0, end: 25),
        ],
      ),
    );
  }
}

Widget getUserProfileImage(
    String userImage, double imageSize, String receiveId, placeHolderImage) {

  return ClipRRect(
    borderRadius: BorderRadius.circular(imageSize / 2),
    child: CachedNetworkImage(
      imageUrl: userImage,
      height: imageSize,
      width: imageSize,
      fit: BoxFit.cover,
      placeholder: (context, url) => getPlaceholderWidget(placeHolderImage),
      errorWidget: (context, url, err) =>
          getPlaceholderWidget(placeHolderImage),
    ),
  );
}

Widget getPlaceholderWidget(String placeHolderImage) {
  return SvgPicture.asset(placeHolderImage);
}

Widget ContactListView({
  required List<Map<String, dynamic>> contactsList,
  required Function onItemSelected,
  required Function onItemLongClick,
  Widget? trailWidget,
  ScrollController? chatController,
  String? selectedPage,
  List<Map<String, String>>? isUserTyping,
  bool isLongPressEnabled = false,
  Function? onItemDeleteSelected,
}) {
  return ScrollConfiguration(
    behavior: ListViewScrollBehavior(),
    child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: pad(top: 10.0, bottom: 15.0),
        itemCount: contactsList.length,
        controller: chatController,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> _mapitem = contactsList[index];
          var message = "";
          if (_mapitem["isGroup"] != "group") {
            message = _mapitem["description"];
          } else {
            if (_mapitem["msgType"] == "status") {
              var decode = _mapitem['description'];
              var decodeString;
              var status = GroupStatus.none;
              try {
                decodeString = json.decode(decode);
                status = GroupStatus
                    .values[int.parse(decodeString['groupStatus'].toString())];
              } catch (e) {
                e.printError();
              }
              switch (status) {
                case GroupStatus.created:
                  message =
                      "${_mapitem['senderName']} ${"you_created_this_group".tr}";
                  break;
                case GroupStatus.added:
                  var receiverId = decodeString['userList'];
                  var id =
                      receiverId.indexWhere((c) => c == appPreference.userID);
                  if (receiverId.contains(appPreference.userID)) {
                    message =
                        "${_mapitem['senderName']} ${"added".tr} ${"you".tr}";
                  } else {
                    message =
                        "${_mapitem['senderName']} ${"added".tr} ${_getUserNames(_mapitem['statusMessage'], id)}";
                  }
                  break;
                case GroupStatus.removed:
                  var receiverId;
                  if (decodeString['userList'].toString().contains('userId')) {
                    receiverId = decodeString['userList'][0]['userId'];
                  } else {
                    receiverId = decodeString['userList'];
                  }
                  if (_mapitem['senderId'] == _mapitem['adminId']) {
                    if (receiverId.contains(appPreference.userID)) {
                      message =
                          "${_mapitem['senderName']} ${"removed".tr} ${"you".tr}";
                    } else {
                      message =
                          "${_mapitem['senderName']} ${"removed".tr} ${_getUserNames(_mapitem['statusMessage'])}";
                    }
                    break;
                  } else {
                    message = "${_mapitem['senderName']} ${"you_left".tr}";
                    break;
                  }
                case GroupStatus.exit:
                  message = "deleted_this_group".tr;
                  break;
                case GroupStatus.groupNameUpdate:
                  message = "${_mapitem['senderName']} ${"group_name_change_status".tr}";
                  break;
                case GroupStatus.groupImageUpdate:
                  message = "${_mapitem['senderName']} ${"group_image_change_status".tr}";
                  break;
                case GroupStatus.none:
                  break;
              }
            } else {
              if (_mapitem["description"].toString().isNotEmpty) {
                message =
                    "${_mapitem['senderName']}: ${_mapitem["description"]}";
              }
            }
          }

          var result = "null";
          for (var element in isUserTyping ?? []) {
            element.forEach((key, value) {
              if (_mapitem["id"] == key) {
                result = value;
              }
            });
          }

          return InkWell(
            onTap: () {
              onItemSelected.call(index);
            },
            onLongPress: () {
              onItemLongClick.call(index);
            },
            child: ContactItem(
              index: index,
              userImage: _mapitem["isGroup"] != "group"
                  ? "${Constants.profileImagePath}${_mapitem["receiverId"]}/${_mapitem["picture"]}"
                  : "${Constants.groupImagePath}/${_mapitem["groupImage"]}",
              placeHolderImage: _mapitem["isGroup"] != "group"
                  ? defaultProfileImageSvg
                  : defaultGroupImageSvg,
              userName: _mapitem["isGroup"] != "group"
                  ? _mapitem["firstName"] +
                      " " +
                      _mapitem["lastName"].toString()
                  : _mapitem["groupName"],
              userStatus: message,
              receiverId: _mapitem["receiverId"] ?? "",
              selected: int.parse(_mapitem["isSelected"] ?? "0"),
              removePadding: true,
              isUserTyping: result,
              chatCount: _mapitem["chatCount"] ?? 0,
              time: _mapitem["dateTime"] ?? "",
              isLastIndex: index == (contactsList.length - 1),
              LastIndexGap: selectedPage == 'chatContacts' ? 0 : 50,
              isLongPressEnabled: isLongPressEnabled,
              exploreCount: chatCount(_mapitem, selectedPage),
              exploreTime: selectedPage == "addGroup"
                  ? const SizedBox.shrink()
                  : _getTrailWidget(trailWidget, selectedPage, _mapitem,
                      onItemDeleteSelected, index),
              trailWidget: selectedPage != "addGroup"
                  ? const SizedBox.shrink()
                  : _getTrailWidget(trailWidget, selectedPage, _mapitem,
                      onItemDeleteSelected, index),
            ),
          );
        }),
  );
}

_getTrailWidget(Widget? trailWidget, String? selectedPage,
    Map<String, dynamic>? _mapitem, Function? onItemDeleteSelected, index) {
  if (trailWidget != null) {
    if (selectedPage == 'addGroup' && _mapitem!["isSelected"] == "1") {
      return trailWidget;
    } else if (selectedPage == 'newGroup') {
      return InkWell(
          onTap: () {
            onItemDeleteSelected!.call(index);
          },
          child: trailWidget);
    } else if (selectedPage == 'chatContacts') {
      return Container(
        padding: const EdgeInsetsDirectional.only(start: 3),
        alignment: AlignmentDirectional.topEnd,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_mapitem?["dateTime"].isNotEmpty)
                CustomText(
                  text: getTimeFormat(_mapitem?["dateTime"]),
                  size: AppDimen.textSize_14,
                  color: _mapitem!["chatCount"] != 0
                      ? AppColors.primaryColor
                      : AppColors.chatStatusColor,
                ),
            ]),
      );
    }
  }
  return const SizedBox.shrink();
}

Widget chatCount(Map<String, dynamic>? _mapitem, String? selectedPage) {
  return _mapitem!["chatCount"].toString() != '0' &&
          selectedPage == 'chatContacts'
      ? Container(
          margin: const EdgeInsetsDirectional.only(start: 5),
          width: _mapitem?["chatCount"] <= 100 ? 22 : 30,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primaryColor,
          ),
          child: Center(
              child: CustomText(
            text: _mapitem!["chatCount"].toString(),
            size: AppDimen.textSize_10,
            color: AppColors.white,
            isSoftWrap: false,
            textAlign: TextAlign.center,
          )))
      : const SizedBox.shrink();
}

String _getUserNames(String? userList, [int? id]) {
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
          _addedUsers += ", ${'You'.tr}";
        } else {
          _addedUsers += ", ${user[i]}";
        }
      }
    }
  }
  return _addedUsers;
}
