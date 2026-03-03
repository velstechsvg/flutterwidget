import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yottachat/config/client.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';
import 'package:yottachat/screens/views/auth/phone_number/phone_number_page.dart';
import 'package:yottachat/screens/views/explore/explore_view.dart';
import 'package:yottachat/screens/views/profile/profile_page.dart';
import 'package:yottachat/widgets/country_code_picker/country.dart';
import 'package:yottachat/widgets/country_code_picker/function.dart';

import '../../../resources/app_images.dart';
import '../custom_scaffold.dart';
import 'home_controller.dart';
import 'home_navigator.dart';

class HomePage extends StatefulWidget {
  double? lat = 0.0;
  double? lng = 0.0;
  String? locationName = "";
  String? from;
  Country? country;
  String? countryCode;
  String? dialCode;

  HomePage(
      {Key? key,
      this.from = "withAuth",
      this.lat,
      this.lng,
      this.locationName,
      this.country,
      this.countryCode,
      this.dialCode})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements HomeNavigator {
  final HomeController controller = Get.find();

  static final List<Widget> _widgetOptions = <Widget>[
    ExploreView(),
    const SizedBox.shrink(),
    const SizedBox.shrink(),
    const ProfilePage()
  ];

  @override
  void initState() {
    controller.navigator = this;
    if (widget.from != "withAuth") {
      controller.countryName = widget.country;
      controller.countryCode = widget.countryCode;
      controller.dialCode.value = widget.dialCode ?? '';
      appPreference.preferredLocation = widget.locationName;
      appPreference.preferredLat = widget.lat;
      appPreference.preferredLng = widget.lng;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.addUserLoginSocketListener(context);
      _onItemTapped(0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.lightPrimary,
      body: Obx(
        () => Container(
          color: AppColors.white,
          child: _widgetOptions.elementAt(currentIndex.value),
        ),
      ),

      isShowAppBar: false,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget customAppbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 20, top: 15),
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.dropShadow,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 10.0,
                        spreadRadius: 1),
                  ],
                ),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      rightArrowSvg,
                      matchTextDirection: true,
                    ))),
          ),
        ),
      ],
    );
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
  navigateScreen(HomeScreens screen, String param) {
    if (screen == HomeScreens.phoneNumber) {
      Get.to(() => PhoneNumberPage(from: "home"),
          arguments: {
            "countryCode": widget.countryCode,
            "dialCode": widget.dialCode,
            "country": widget.country
          },
          routeName: "/phoneNumberPage");
    }
  }

  @override
  showDialog() {}

  @override
  void dispose() {
    super.dispose();
  }
}
