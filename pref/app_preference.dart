import 'package:get_storage/get_storage.dart';
import 'package:yottachat/pref/pref_helper.dart';

class AppPreference extends PreferenceHelper {
  var pref = GetStorage("handySharedPref");

  removePreference() {
    String lang = preferredLanguage ?? 'en';
    pref.erase();
    preferredLanguage = lang;
  }

  @override
  String? get accessToken => pref.read("accessToken") ?? "";
  @override
  set accessToken(String? _accessToken) {
    pref.write("accessToken", _accessToken);
  }

  @override
  String? get userID => pref.read("userID") ?? "";
  @override
  set userID(String? userID) {
    pref.write("userID", userID);
  }

  @override
  String? get deviceID => pref.read("deviceID") ?? "";
  @override
  set deviceID(String? _deviceID) {
    pref.write("deviceID", _deviceID);
  }

  @override
  String? get profileImage => pref.read("profileImage") ?? "";
  @override
  set profileImage(String? _profileImage) {
    pref.write("profileImage", _profileImage);
  }

  @override
  String? get firstName => pref.read("firstName") ?? "";
  @override
  set firstName(String? firstName) {
    pref.write("firstName", firstName);
  }

  @override
  String? get description => pref.read("description") ?? "";
  @override
  set description(String? description) {
    pref.write("description", description);
  }

  @override
  String? get email => pref.read("email") ?? "";
  @override
  set email(String? email) {
    pref.write("email", email);
  }

  @override
  String? get phoneNumber => pref.read("phoneNumber") ?? "";
  @override
  set phoneNumber(String? phoneNumber) {
    pref.write("phoneNumber", phoneNumber);
  }

  @override
  String? get dialCode => pref.read("dialCode") ?? "";
  @override
  set dialCode(String? dialCode) {
    pref.write("dialCode", dialCode);
  }

  @override
  String? get countryCode => pref.read("countryCode") ?? "";
  @override
  set countryCode(String? countryCode) {
    pref.write("countryCode", countryCode);
  }

  @override
  String? get preferredLanguage => pref.read("preferredLanguage") ?? "en";
  @override
  set preferredLanguage(String? _preferredLanguage) {
    pref.write("preferredLanguage", _preferredLanguage);
  }

  @override
  String? get preferredCurrency => pref.read("preferredCurrency") ?? "";
  @override
  set preferredCurrency(String? _preferredCurrency) {
    pref.write("preferredCurrency", _preferredCurrency);
  }

  @override
  String? get siteName => pref.read("siteName") ?? "";
  @override
  set siteName(String? _siteName) {
    pref.write("siteName", _siteName);
  }

  @override
  String? get homeLogo => pref.read("homeLogo") ?? "";
  @override
  set homeLogo(String? _homeLogo) {
    pref.write("homeLogo", _homeLogo);
  }
}
