enum AuthScreen {
  getStarted,
  signup,
  phoneNumber,
  otpPage,
  locationSelection,
  moveToHome,
  moveToChat
}

class AuthNavigator {
  navigateScreen(AuthScreen screen, String param) {}
  showDialog() {}
}
