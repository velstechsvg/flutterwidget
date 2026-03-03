abstract class PreferenceHelper{
  String? accessToken, userID;
  String? deviceID;
  String? profileImage;
  String? firstName, description, email, phoneNumber, dialCode, countryCode;
  String? adminEmail, adminPhoneNumber, adminSkype;
  String? preferredCurrency,preferredLanguage="en",preferredLocation,preferredType;

  bool? isCardAdded;
  int? preferredPaymentMethod, orderId, orderCatId;
  double? walletAmount;
  int? cardLastFour;
  String? stripeKey;
  String? cartItems;
  double? preferredLat,preferredLng;
}