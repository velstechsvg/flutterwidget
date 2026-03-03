import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/resources/app_dimen.dart';
import 'package:yottachat/resources/app_images.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';
import 'package:yottachat/widgets/handy_text.dart';

import '../../app.dart';
import '../../resources/app_font.dart';
import 'base_controller.dart';

class CustomScaffold extends StatefulWidget {
  final Widget? body;
  final Widget? appBar;
  final Widget? action;
  final String? title;
  final Function? customAppBarFunction;
  final bool isShowAppBar;
  final bool isTitleBold;
  final bool isBackButtonNeeded;
  final String appBarContent;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBarBottomWidget;
  final Color? appBarBGColor;

  const CustomScaffold(
      {Key? key,
      this.appBar,
        this.title,
        this.action,
        this.isTitleBold = true,
      this.body,
      this.customAppBarFunction,
      this.isShowAppBar = false,
      this.appBarContent = "",
      this.onChanged,
      this.resizeToAvoidBottomInset = false,
      this.backgroundColor,
        this.isBackButtonNeeded = true,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.bottomNavigationBar,
      this.appBarBottomWidget,
      this.appBarBGColor = AppColors.white})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomScaffoldState();
  }
}

class CustomScaffoldState extends State<CustomScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? scaffoldContext;
  Map<String, dynamic> returnMap = {};
  late StreamSubscription<ConnectivityResult> networkSubscription;
  RxBool isNetWorkAvailable = true.obs;
  RxString netWorkContent = ''.obs;
  Rx<Color> netWorkColor =const Color(0xFF000000).obs;



  @override
  void initState() {
    netWorkListener();
    super.initState();
  }

 void netWorkListener(){
    networkSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      final Connectivity connectivity = Connectivity();
      try {
        var result = await connectivity.checkConnectivity();
        if(result != ConnectivityResult.none){
          BaseController.socketIO.connect();
          netWorkContent.value = "back_to_online".tr;
          await Future.delayed(const Duration(seconds: 1));
        } else {
          BaseController.socketIO.close();
          netWorkContent.value = "you_are_offline".tr;
        }
        isNetWorkAvailable.value = netWorkContent.value != "you_are_offline".tr;
      } on SocketException catch (_) {
        BaseController.socketIO.disconnect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: PopScope(
          canPop: widget.customAppBarFunction == null,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (widget.customAppBarFunction != null) {
              widget.customAppBarFunction!();
            }
          },
          child: Obx(
            ()=> Visibility(
              visible: netWorkContent.value != null,
              child: Scaffold(
                key: _scaffoldKey,
                bottomNavigationBar: widget.bottomNavigationBar,
                appBar:
                widget.isShowAppBar
                    ? App().showAppbar(context, widget.appBar, widget.appBarBGColor,
                    widget.customAppBarFunction, widget.title, widget.action, widget.isBackButtonNeeded,widget.appBarBottomWidget, widget.isTitleBold,networkWidget(),isNetWorkAvailable.value)
                    :
                 PreferredSize(
                  preferredSize: Size(200, 200),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: networkWidget(),
                  ),
                ),
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                backgroundColor: widget.backgroundColor ?? AppColors.white,

                body: Builder(
                  builder: (BuildContext ctx) {
                    scaffoldContext = ctx;
                    _publishSelection("scaffoldcontext", scaffoldContext,
                        "scaffoldkey", _scaffoldKey);
                    return SafeArea(
                      child: Stack(
                        children: <Widget>[
                          widget.body!,
                        ],
                      ),
                    );
                  },
                ),
                floatingActionButton: widget.floatingActionButton ?? const SizedBox.shrink(),
                  floatingActionButtonLocation: widget.floatingActionButtonLocation ?? FloatingActionButtonLocation.centerDocked,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _publishSelection(
      String key, dynamic value, String key1, dynamic value1) {
    returnMap[key] = value;
    returnMap[key1] = value1;

    if (widget.onChanged != null) {
      widget.onChanged!(returnMap);
    }
  }

  networkWidget(){
    return  Obx(()=>
        Visibility(
          visible: !isNetWorkAvailable.value,
          child: Container(
            alignment: AlignmentDirectional.centerStart,
            width: double.infinity,
            color: netWorkContent.value == "you_are_offline".tr ?  AppColors.black : AppColors.primaryColor,
            height: 30,
            child: Center(
              child: CustomText(
                text: netWorkContent.value == "you_are_offline".tr ? "you_are_offline".tr : "back_to_online".tr,
                color: AppColors.white,
                size: AppDimen.textSize_12,
              ),
            ),),
        ),
    );
  }
}

class update extends StatelessWidget {
  const update({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



