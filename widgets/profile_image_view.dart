import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/screens/views/base_controller.dart';
import 'package:yottachat/utils/click_utils.dart';
import 'package:yottachat/widgets/svg_shadow.dart';

import '../resources/app_dimen.dart';
import '../resources/app_font.dart';
import '../resources/app_images.dart';
import '../screens/views/camera_screen/camera_screen.dart';
import 'handy_text.dart';

class ProfileImageView extends GetView {
  final BaseController? controller;
  final String? profileImage;
  String? placeHolderImage;
  double? imageSize;
  bool? isEditable;
  bool isLoading;
  Widget? editingWidget;
  AlignmentGeometry? alignment;
  String isFrom;
  String groupId;

  ProfileImageView(
      {Key? key,
      required this.controller,
      required this.profileImage,
      this.onSelected,
      this.imageSize,
      this.isEditable,
      this.editingWidget,
      this.alignment,
      this.placeHolderImage,
      this.isLoading = false,
      this.isFrom = "",
      this.groupId = ""
      })
      : super(key: key);
  final ValueChanged<File>? onSelected;
  @override
  Widget build(BuildContext context) {
    imageSize ??= 150.0;
    isEditable ??= true;

    // urlSize = imageSize!;
    editingWidget ??= Container(
          height: 35.0,
          width: 35.0,
          margin: const EdgeInsetsDirectional.only(end: 0, bottom: 0),
          child: SvgPicture.asset(editProfileImageSvg));
    alignment ??= Alignment.center;
    return Align(
      alignment: alignment!,
      child: InkWell(
        onTap: () {
          if (FocusManager.instance.primaryFocus != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          if (isEditable!) showImagePickerOption(context, controller!, isFrom);
        },
        child: SizedBox(
          height: imageSize!,
          width: imageSize!,
          child: Stack(
            children: [
              !isLoading
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(imageSize! / 2),
                      child: profileImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileImage!,
                              height: imageSize,
                              width: imageSize,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) {
                                 return Container(
                                  height: imageSize!,
                                  width: imageSize!,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(imageSize! / 2),
                                    ),
                                    border: Border.all(
                                      width: 2,
                                      color: profileImage!.isNotEmpty
                                          ? AppColors.textfieldBorderColor
                                          : Colors.transparent,
                                      style: BorderStyle.solid,
                                    ),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                );
                              })
                          : SvgPicture.asset(
                              placeHolderImage ?? defaultProfileImageSvg,
                              height: imageSize!,
                              width: imageSize!,
                              fit: BoxFit.scaleDown,
                            ))
                  : const SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: SimpleShadow(
                    color: AppColors.primaryColor,
                    opacity: 0.2,
                    child: editingWidget!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showImagePickerOption(context, BaseController controller, isFrom) {
    FocusScope.of(context).unfocus();
    controller.showBottomSheet(
      [
        CustomText(
            text: 'upload_profile'.tr,
            size: AppDimen.textSize_18,
            fontWeight: AppFont.bold),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                ClickUtils.debounce(() {
                  getImage(context, true, isFrom);
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(top: 24.0, bottom: 10.0),
                    child: SimpleShadow(
                        child: SvgPicture.asset(
                      editProfileImageSvg,
                    )),
                  ),
                  CustomText(
                      text: 'camera'.tr,
                      size: AppDimen.textSize_16,
                      fontWeight: AppFont.medium),
                ],
              ),
            ),
            const SizedBox(
              width: 35,
            ),
            InkWell(
              onTap: () {
                ClickUtils.debounce(() {
                  getImage(context, false, isFrom);
                });
              },
              child: Column(
                children: [
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 24.0, bottom: 10.0),
                      child: SimpleShadow(child: SvgPicture.asset(gallerySvg))),
                  CustomText(
                      text: 'gallery'.tr,
                      size: AppDimen.textSize_16,
                      fontWeight: AppFont.medium),
                ],
              ),
            ),
          ],
        ),
      ],
      isDismissible: true,
    );
  }

  void getImage(context, bool from, String isFrom) async {
    print("isFrom------>> ${isFrom}---${groupId}");
    File? pickedFile;
    try {
      if (from) {
        if (isFrom == "editProfilePage") {
          pickedFile = await Get.to(CameraScreen(
            isFrom: "editProfilePage",
          ));
        }
        else if (isFrom == "newGroupPage") {
          pickedFile = await Get.to(CameraScreen(
            isFrom: "newGroupPage",
            groupId: groupId,
          ));
        }
        else {
          pickedFile = await Get.to(CameraScreen(
            isFrom: "signup",
          ));
        }
      }
      else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        PlatformFile? file = result?.files.first;
        if (file != null) pickedFile = File(file.path!);
      }
      if (pickedFile != null && pickedFile.path != null) {
        onSelected?.call(pickedFile);
        Get.back();
        controller!.isLoading.value = true;
      }
      else {
        controller!.isLoading.value = false;
      }
    } catch (e) {
      Get.printInfo(info: "Image picker error $e");
    }
  }
}
