import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/screens/views/camera_screen/camera_controller.dart';
import 'package:yottachat/screens/views/camera_screen/camera_preview.dart';
import 'package:yottachat/screens/views/new_group/new_group_controller.dart';
import 'package:yottachat/screens/views/splash/splash_controller.dart';

import '../../../resources/app_dimen.dart';
import '../../../resources/app_images.dart';
import '../edit_profile/edit_profile_controller.dart';

class CameraScreen extends StatefulWidget {
  String? isFrom;
  String groupId;

  CameraScreen({Key? key, this.isFrom, this.groupId = ""}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  var isOpenCamera = false.obs;
  var isFlash = false.obs;

  @override
  void initState() {
    Permission.camera.request().then((permissionStatus) {
      cameraPermission(permissionStatus.name);
    });
    super.initState();
  }

  cameraPermission(String permissionStatus) {
    if (permissionStatus == "granted") {
      cameraFilePath = null;
      if (widget.isFrom == "editProfilePage") {
        initializeCameraProfilePage(selectedCamera);
        isOpenCamera.value = true;
      } else if (widget.isFrom == "newGroupPage") {
        initializeCameraNewGroupPage(selectedCamera);
        isOpenCamera.value = true;
      } else {
        initializeCamera(selectedCamera);
        isOpenCamera.value = true;
      }
    } else {
      isOpenCamera.value = false;
    }
  }

  late SplashController controller = Get.find();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;

  initializeCamera(int cameraIndex) async {

    if (cameraIndex == 1) {
      isFlash.value = false;
    }
    _controller = CameraController(
        controller.cameras[cameraIndex], ResolutionPreset.medium,
        enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
    isOpenCamera.value = true;
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  initializeCameraProfilePage(int cameraIndex) async {
    if (cameraIndex == 1) {
      isFlash.value = false;
    }
    final EditProfileController editProfileController = Get.find();
    _controller = CameraController(
        editProfileController.cameras[cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  initializeCameraNewGroupPage(int cameraIndex) async {
    if (cameraIndex == 1) {
      isFlash.value = false;
    }
    final NewGroupController newGroupController = Get.find();
    _controller = CameraController(
        newGroupController.cameras[cameraIndex], ResolutionPreset.medium,
        enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(children: [
              Obx(
                () => isOpenCamera.value
                    ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Transform.scale(
                                scale: ((1 /
                                        (_controller.value.aspectRatio *
                                            mediaSize.aspectRatio)) -
                                    0.1),
                                alignment: Alignment.center,
                                child: CameraPreview(_controller));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ));
                          }
                        },
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 15, right: 15.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${'please_enable_the_permission_from_the'.tr} ",
                                style: TextStyle(color: AppColors.white),
                              ),
                              TextSpan(
                                  text: 'settings'.tr,
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      cameraPermissionDialog(context);
                                    }),
                            ],
                          ),
                        ),
                      ),
              ),
              showCustomAppBar(context),
              Container(
                width: mediaSize.width,
                height: mediaSize.height,
                alignment: AlignmentDirectional.bottomEnd,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => isOpenCamera.value
                            ? IconButton(
                                onPressed: () {
                                  if (controller.cameras.length > 1) {
                                    setState(() {
                                      selectedCamera =
                                          selectedCamera == 0 ? 1 : 0;
                                      initializeCamera(selectedCamera);
                                    });
                                  } else if (widget.isFrom ==
                                      "editProfilePage") {
                                    setState(() {
                                      selectedCamera =
                                          selectedCamera == 0 ? 1 : 0;
                                      initializeCameraProfilePage(
                                          selectedCamera);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      backgroundColor: AppColors.black,
                                      content: Text(
                                        'No secondary camera found',
                                        style:
                                            TextStyle(color: AppColors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                },
                                icon: const Icon(Icons.switch_camera_rounded,
                                    color: AppColors.white),
                              )
                            : const SizedBox(
                                width: 60,
                              ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _initializeControllerFuture;
                          var xFile = await _controller.takePicture();
                          _controller.setFlashMode(FlashMode.off);
                          cameraFilePath = xFile.path;
                          if (widget.isFrom == "editProfilePage") {
                            final EditProfileController editProfileController =
                                Get.find();
                            if (xFile.path.isNotEmpty) {
                              editProfileController.uploadImage(
                                  context, File(xFile.path), "");
                            }
                          }
                          else if(widget.isFrom == "newGroupPage"){
                            if(widget.groupId != "") {
                              controller.checkNetwork(context, () {
                                controller.uploadImage(context, "group", xFile.path,widget.groupId);
                              });
                            }
                          }
                          else {
                            controller.checkNetwork(context, () {
                              controller.uploadImage(context, xFile.path, "");
                            });
                          }
                          Navigator.pop(context, File(xFile.path));
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      selectedCamera == 0
                          ? Obx(() => TextButton(
                                onPressed: () {
                                  isFlash.value = !isFlash.value;
                                  if (isFlash.value) {
                                    _controller.setFlashMode(FlashMode.torch);
                                  } else {
                                    _controller.setFlashMode(FlashMode.off);
                                  }
                                },
                                child: !isFlash.value
                                    ? Icon(Icons.flash_off,
                                        color: AppColors.white)
                                    : Icon(
                                        Icons.flash_on,
                                        color: AppColors.white,
                                      ),
                              ))
                          : const SizedBox(
                              height: 70,
                              width: 60,
                            )
                    ]),
              )
            ])));
  }

  Future<void> cameraPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content:
              Text("need_to_enable_the_permission".trArgs([("camera".tr)])),
          actions: <Widget>[
            TextButton(
              child: Text(
                'cancel'.tr,
                style: TextStyle(color: AppColors.black),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: Text(
                'settings'.tr,
                style: TextStyle(color: AppColors.black),
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

PreferredSize showCustomAppBar(context) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 80),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsetsDirectional.only(
                  start: AppDimen.textSize_20, top: AppDimen.textSize_10),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                scaffoldArrowExploreSvg,
                matchTextDirection: true,
              )),
        ),
      ],
    ),
  );
}
