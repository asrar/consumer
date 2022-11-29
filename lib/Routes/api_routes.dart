class APIRoutes {
  static const String baseURL = "http://shipperdelivery.com/api/";
  static const String registerAccount = baseURL + "user/register";
  static const String loginAccount = baseURL + "user/login?mobile=";
  static const String getDetails = baseURL + "user/getuserdetails?mobile=";
  static const String getUnratedOrders = baseURL + "user/ratedorder?user_id=";
  static const String rateOrder = baseURL + "user/rateupdateorder?booking_id=";
  static const String generateOTP = baseURL + "user/otp";
  static const String packageSettings = baseURL + "user/settings";
  static const String calculateFare = baseURL + "user/fare";
  static const String placeOrder = baseURL + "user/place_order";
  static const String getVehicles = baseURL + "user/get_vehicle";
  static const String getOrderDetails =
      baseURL + "user/get_request?request_id=";
  static const String getOrderDrops = baseURL + "user/get_drops?booking_id=";
  static const String applyPromo = baseURL + "user/apply_promocode";
  static const String addMoney = baseURL + "user/add_money?amount=";
  static const String saveAddress = baseURL + "user/save_addresses?user_id=";
  static const String savedAddresses =
      baseURL + "user/all_saved_address?user_id=";
  static const String activeOrders = baseURL + "user/request/check?user_id=";
  static const String sendNotifications =
      baseURL + "user/sendnotification?user_id=";
  static const String cancelOrder =
      baseURL + "provider/usercancel?cancel_reason=";
  static const String getCancelReasons =
      baseURL + "provider/user_cancel_reasons/";

  static const String googleSearchAPI =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?sessionroken=123456&components=country:in&key=$googleAPIKey&input=";

  static const String googleGeometryAPI =
      "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&address=";

  static const String googleReverseGeometryAPI =
      "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&latlng=";

  // static const String googleAPIKey = "AIzaSyAjCz6Q4eB-pQGK7toCsfps8PrqAmgSQK8";
  static const String googleAPIKey = "AIzaSyAjCz6Q4eB-pQGK7toCsfps8PrqAmgSQK8";
}
