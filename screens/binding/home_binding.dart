import 'package:get/get.dart';
import 'package:yottachat/screens/views/add_group/add_group_members_controller.dart';
import 'package:yottachat/screens/views/edit_profile/edit_profile_controller.dart';
import 'package:yottachat/screens/views/explore/explore_controller.dart';
import 'package:yottachat/screens/views/profile/profile_controller.dart';

import '../views/UpdateChatContact/update_chat_contact_controller.dart';
import '../views/chat/chat_controller.dart';
import '../views/home_page/home_controller.dart';
import '../views/language/language_controller.dart';
import '../views/new_contact/new_contact_controller.dart';
import '../views/new_group/new_group_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ExploreController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => EditProfileController(), fenix: true);
    Get.lazyPut(() => LanguageController(), fenix: true);
    Get.lazyPut(() => updateChatContactsController(), fenix: true);
    Get.lazyPut(() => NewContactController(), fenix: true);
    Get.lazyPut(() => AddGroupMembersController(), fenix: true);
    Get.lazyPut(() => NewGroupController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
  }
}
