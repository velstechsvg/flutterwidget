import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'widgets/country_code_picker/country.dart';

const String socketURL = "https://yottachat.rentallscript.com";
const String UPLOAD_URL = "https://yottachat.rentallscript.com/api";
const String URL="https://yottachat.rentallscript.com/api/graphql"; //LIVE_SITE

// const String socketURL = "http://162.254.37.106:9002";
// const String UPLOAD_URL = "http://162.254.37.106:9001";
// const String URL = "http://162.254.37.106:9001/graphql"; //dev
const APP_NAME = "YottaChat";

// const String socketURL = "http://192.168.5.33:4001";
// const String UPLOAD_URL = "http://192.168.5.33:4000";
// const String URL = "http://192.168.5.33:4000/graphql";

const String profileImagePath = "$UPLOAD_URL/images/avatar/";
const String groupImagePath = "$UPLOAD_URL/images/group-images/";
const String appLogoURL = "$UPLOAD_URL/images/logo/";

var versionName = "";
var versionNumber = "";
String? authToken = "";
String preferredLanguage = "en";
var currentIndex = 0.obs;
var isShowPopup = true;
var cameraFilePath;
var isShowPrivacy = true.obs;
var cameras;
var securityKey = "";
String receiverID = "";
Country country = const Country("United States", "flags/usa.png", "US", "+1");
Map<String, dynamic> chatDetailsFromFCM = {};
String lastViewedThreadId = "";
RxString groupNameUpdate = "".obs;
RxInt selectedContactsCount = 0.obs;