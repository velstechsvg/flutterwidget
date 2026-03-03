import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/app.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_font.dart';
import 'package:yottachat/screens/views/UpdateChatContact/update_chat_contacts.dart';
import 'package:yottachat/screens/views/explore/explore_controller.dart';
import 'package:yottachat/screens/views/home_page/home_navigator.dart';
import 'package:yottachat/screens/views/profile/profile_page.dart';
import 'package:yottachat/widgets/custom_popup_menu.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../../config/client.dart';
import '../../../constant.dart';
import '../../../resources/app_images.dart';
import '../../../widgets/contact_item.dart';
import '../../../widgets/country_code_picker/country.dart';
import '../../../widgets/country_code_picker/function.dart';
import '../../../widgets/custom_floating_action_button.dart';
import '../../../widgets/custom_search_field.dart';
import '../../../widgets/scroll_behaviour.dart';
import '../../../widgets/show_done_view.dart';
import '../add_group/add_group_members.dart';
import '../auth/phone_number/phone_number_page.dart';
import '../chat/chat_view.dart';
import '../custom_scaffold.dart';

class ExploreView extends StatefulWidget {
  String? from;
  Country? country;
  String? countryCode;
  String? dialCode;

  ExploreView(
      {Key? key,
      this.from = "withAuth",
      this.country,
      this.countryCode,
      this.dialCode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExploreViewState();
  }
}

class ExploreViewState extends State<ExploreView> implements HomeNavigator {
  final ExploreController controller = Get.find();
  late Map<String, dynamic> _contactItem;
  late StreamSubscription<ConnectivityResult> networkSubscription;
  final ScrollController _chatScrollController = ScrollController();
  final CustomPopupMenuController _popupMenuController =
      CustomPopupMenuController();

  List<Map<String, dynamic>> _tempContactsList = <Map<String, dynamic>>[];

  @override
  void initState() {
    controller.navigator = this;
    controller.listenChatSocket(context);
    controller.getAllChats(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.addUserLoginSocketListener(context);
      controller.listenIsUserTypingSocket(context);
      controller.getAllChats(context);
      _onItemTapped(0);
      _tempContactsList = controller.contactsListItem;
      controller.contactsListItem.refresh();
    });
    networkSubscription=Connectivity().onConnectivityChanged.listen((ConnectivityResult result){
    if(result!=ConnectivityResult.none){
      controller.addUserLoginSocketListener(context);
      controller.listenIsUserTypingSocket(context);
      controller.getAllChats(context);
      _onItemTapped(0);
      _tempContactsList = controller.contactsListItem.value;
      controller.contactsListItem.refresh();
      if (Get.isSnackbarOpen == true) {
        Get.back();
      }
    }
    });
    SystemChannels.lifecycle.setMessageHandler((lifecycleState) async => await onLifecycleStateChanged(lifecycleState));
    _chatScrollController.addListener(() {
      if (_chatScrollController.position.pixels ==
          _chatScrollController.position.maxScrollExtent) {
        if (controller.totalCount != controller.contactsListItem.length &&
            controller.totalCount != 0) {
          controller.currentPage++;
          controller.getAllChats(context);
        }
      }
    });
    super.initState();
  }

  onLifecycleStateChanged(dynamic lifecycleState) {
    if (lifecycleState == "AppLifecycleState.paused") {
      controller.sendUserIsOfflineSocket();
    }
    else if (lifecycleState == "AppLifecycleState.resumed") {
      if (!controller.socketIO.connected) {
        controller.socketIO.connect();
      }
      controller.sendUserIsOnlineSocket();
    }
  }


  _onItemTapped(int index) {
    if (widget.from == "withAuth") {
      currentIndex.value = index;
    } else {
      if (index != 0 && index != 1) {
        controller.navigator?.navigateScreen(HomeScreens.phoneNumber, "");
      } else {
        currentIndex.value = index;
      }
    }
  }
@override
  void dispose() {
  networkSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        customAppBarFunction: () {
          App().closeApp();
        },
        body: Obx(() =>
        Stack(children: [_showBodyContent(context),controller.showCenterLoading(context),],),
       ),
        isShowAppBar: false,
        isBackButtonNeeded: false,
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        floatingActionButton: Obx(() => !controller.isLoading.value
            ? CustomFloatingActionButton(onPressed: () {
                controller.checkNetwork(context, () {
                  navigateScreen(HomeScreens.updateChatContacts, "");
                });
              })
            : const SizedBox.shrink()),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  getAllCategories(context) async {}

  _showBodyContent(BuildContext context) {
    return [
      _showUserWelcomeView(),
      _showSearchChatView(),
      Obx(
        () => controller.contactsListItem.value.isEmpty
            ? showEmptyView(
                emptyText: "start_chat".tr,
                emptyImage: emptyChatSvg,
                context: context)
            : Expanded(
                child: Obx(() => controller.isUserTyping.isEmpty
                    ? ContactListView(
                        onItemLongClick: (index) {},
                        contactsList: controller.contactsListItem,
                        selectedPage: 'chatContacts',
                        chatController: _chatScrollController,
                        isUserTyping: controller.isUserTyping,
                        onItemSelected: (index) {
                          controller.checkNetwork(context, () {
                            _contactItem = controller.contactsListItem.value[index];
                            navigateScreen(HomeScreens.chatView, '');
                          });
                        },
                        trailWidget: const SizedBox.shrink())
                    : ContactListView(
                        onItemLongClick: (index) {},
                        contactsList: controller.contactsListItem,
                        selectedPage: 'chatContacts',
                        chatController: _chatScrollController,
                        isUserTyping: controller.isUserTyping,
                        onItemSelected: (index) {
                          controller.checkNetwork(context, () {
                            _contactItem =
                                controller.contactsListItem.value[index];
                            navigateScreen(HomeScreens.chatView, '');
                          });
                        },
                        trailWidget: const SizedBox.shrink()))),
      )
    ].toColumn(
      mainAxisSize: MainAxisSize.max,
    );
  }

  @override
  navigateScreen(HomeScreens screen, String param) {
    FocusScope.of(context).unfocus();
    controller.searchChatController.clear();
    switch (screen) {
      case HomeScreens.updateChatContacts:
        Get.to(const updateChatContacts(), routeName: "/updateChatContacts")!
            .then((list) {
          controller.listenChatSocket(context);
          controller.listenIsUserTypingSocket(context);
          controller.currentPage = 1;
          controller.getAllChats(context);
          controller.contactsListItem.refresh();
          if (list != null) {
            controller.contactsListItem.value =
                list as List<Map<String, String>>;
            _tempContactsList = controller.contactsListItem.value;
          }
        });
        break;
      case HomeScreens.phoneNumber:
        Get.to(() => PhoneNumberPage(from: "home"),
            arguments: {
              "countryCode": widget.countryCode,
              "dialCode": widget.dialCode,
              "country": widget.country
            },
            routeName: "/phoneNumberPage");
        break;
      case HomeScreens.chatView:
        Get.to(() => const ChatView(),
                transition: Transition.rightToLeft,
                arguments: {"selectedContact": _contactItem},
                routeName: "/chatView")
            ?.then((value) {
           if(value != null) {
                controller.listenChatSocket(context);
                controller.listenIsUserTypingSocket(context);
                controller.currentPage = 1;
                controller.getAllChats(context);
                controller.contactsListItem.refresh();
              }
        });
        break;
      case HomeScreens.newGroup:
        Get.to(() => const AddGroupMembers(),
                arguments: {"ContactList": <Map<String, dynamic>>[]},
                routeName: "/addGroupMembers")
            ?.then((value) {
          controller.listenChatSocket(context);
          controller.listenIsUserTypingSocket(context);
          controller.currentPage = 1;
          controller.getAllChats(context);
          controller.contactsListItem.refresh();
        });
        break;

      default:
        break;
    }
  }

  @override
  showDialog() {}

  Widget _showUserWelcomeView() {
    return [
      [
        Container(
          width: 26.0,
          height: 26.0,
          child: Image.asset(welcomePng),
        ).toPad(end: 10.0),
        CustomText(
            text: "hi".tr,
            fontWeight: FontWeight.w600,
            size: AppDimen.textSize_18),
      ].toRow(mainAxisSize: MainAxisSize.min),
      Obx(
        () => Expanded(
          child: CustomText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: controller.firstName.value.toUpperLowerCase(),
              fontWeight: FontWeight.w600,
              size: AppDimen.textSize_18),
        ),
      ),
      [
        InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              Get.to(const ProfilePage())?.then((value) {
                controller.searchChatController.clear();
                controller.listenChatSocket(context);
                controller.listenIsUserTypingSocket(context);
                controller.currentPage = 1;
                controller.getAllChats(context);
                controller.contactsListItem.refresh();
                controller.firstName.value = appPreference.firstName ?? "";
                controller.firstName.refresh();
              });
            },
            child: Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: SvgPicture.asset(settingSvg))),
        GestureDetector(
            child: showPopupMenu(
                popupcontroller: _popupMenuController,
                onSelected: (selected, popupcontroller) {
                  if (selected == 'new_group'.tr) {
                    _popupMenuController.hideMenu();
                    controller.checkNetwork(context, () {
                      navigateScreen(HomeScreens.newGroup, '');
                    });
                  } else {
                    _popupMenuController.hideMenu();
                    controller.checkNetwork(context, () {
                      navigateScreen(HomeScreens.updateChatContacts, '');
                    });
                  }
                },
                menuItems: [
                  'new_group'.tr,
                  'contacts'.tr,
                ],
                isShowArrow: true)),
      ].toRow(),
    ].toRow().toPad(start: 25, end: 25, top: 25);
  }

  Widget _showSearchChatView() {
    return [
      CustomText(
              text: 'chats'.tr,
              size: AppDimen.textSize_24,
              fontWeight: AppFont.bold)
          .toPad(
        top: 25.0,
        start: 24,
      ),
      10.toHeight(),
      CustomSearchField(
        controller: controller.searchChatController,
        onChanged: controller.contactsListItem.value.isNotEmpty
            ? _onSearch
            : _onSearch,
        searchHintText: 'search_your_chats'.tr,
        searchInputStyle: const TextStyle(fontSize: AppDimen.textSize_16),
        focusSearchBox: false,
        isRTL: controller.isDirectionRTL(context),
        suffixIcon: Visibility(
          visible: controller.searchChatController.text.isNotEmpty,
          child: InkWell(
            child: Container(
                width: 25,
                height: 25,
                margin: pad(end: 12.0, start: 5.0),
                child: SvgPicture.asset(clearSearchSvg, fit: BoxFit.scaleDown)),
            onTap: () {
              Future.delayed(Duration.zero, () async {
                FocusScope.of(context).unfocus();
                controller.searchChatController.clear();
                controller.contactsListItem.value = _tempContactsList;
              });
            },
          ),
        ),
      ),
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  void _onSearch(String value) {
    if (value == null || value.isEmpty) {
      controller.contactsListItem.value = _tempContactsList;
    } else {
      controller.contactsListItem.value = _tempContactsList
          .where((element) =>
              element['groupName']
                  .toString()
                  .toLowerCase()
                  .contains(value.toString().toLowerCase()) ||
              "${element['firstName']} ${element['lastName']}"
                  .toLowerCase()
                  .contains(value.toString().toLowerCase()))
          .map((e) => e)
          .toList();
    }
    controller.contactsListItem.refresh();
  }
}
