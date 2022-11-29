import 'package:consumer/models/DriverModel.dart';

class MiniOrderDetails {
  String userID = "";
  String orderID = "";
  String bookingID = "";
  String otp = "";
  String status = "";
  String sLatitude = "";
  String sLongitude = "";
  String productTypeID = "";
  String estimatedFare = "";
  String distance = "";
  String useWallet = "";
  String paymentMethod = "";
  String pickupPhone = "";
  String orderDate = "";

  MiniOrderDetails({
    required this.userID,
    required this.orderID,
    required this.bookingID,
    required this.sLatitude,
    required this.sLongitude,
    required this.productTypeID,
    required this.estimatedFare,
    required this.distance,
    required this.useWallet,
    required this.paymentMethod,
    required this.pickupPhone,
    required this.orderDate,
    required this.otp,
    required this.status,
  });

  factory MiniOrderDetails.fromJson(Map<String, dynamic> json) {
    return MiniOrderDetails(
      userID: json['user_id'],
      orderID: json['id'].toString(),
      bookingID: json['booking_id'].toString(),
      sLatitude: json['s_latitude'],
      sLongitude: json['s_longitude'],
      productTypeID: json['product_type_id'],
      estimatedFare: json['estimated_fare'],
      distance: json['distance'],
      useWallet: json['use_wallet'],
      paymentMethod: json['payment_mode'],
      pickupPhone: json['pickuphone'],
      orderDate: json['schedule_at'] ?? "",
      otp: json['otp'] ?? "111111",
      status: json['status'] ?? "",
    );
  }
}

class OrderDetails {
  String userID = "";
  String orderID = "";
  String bookingID = "";
  String otp = "";
  String status = "";
  String vehicleName = "";
  String vehicleImage = "";
  String productType = "";
  String sLatitude = "";
  String sLongitude = "";
  String sAddress = "";
  // String dLatitude = "";
  // String dLongitude = "";
  // String dAddress = "";
  String productTypeID = "";
  String estimatedFare = "";
  // String serviceType = "";
  // String serviceRequired = "";
  String distance = "";
  String useWallet = "";
  String paymentMethod = "";
  String pickupPhone = "";
  // String dropPhone = "";
  // String receiverName = "";
  String orderDate = "";
  String promoCode = "";
  Driver? driver;

  OrderDetails({
    required this.userID,
    required this.orderID,
    required this.bookingID,
    required this.sLatitude,
    required this.sLongitude,
    required this.sAddress,
    // required this.dLatitude,
    // required this.dLongitude,
    // required this.dAddress,
    required this.productTypeID,
    required this.estimatedFare,
    // required this.serviceType,
    // required this.serviceRequired,
    required this.distance,
    required this.useWallet,
    required this.paymentMethod,
    required this.pickupPhone,
    // required this.dropPhone,
    // required this.receiverName,
    required this.orderDate,
    required this.promoCode,
    required this.driver,
    required this.otp,
    required this.status,
    required this.vehicleName,
    required this.vehicleImage,
    required this.productType,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    Driver? orderDriver;
    print(json['provider']);

    if (json['request']['provider_id'].toString() != "0") {
      orderDriver = Driver(
        id: json['provider']['id'].toString(),
        firstName: json['provider']['first_name'],
        avatar: json['provider']['avatar'] ?? "",
        mobile: json['provider']['mobile'],
        vehicleNumber: json['provider']['vehicle_number'],
        vehicleModel: json['provider']['vehicle_model'],
      );
    }

    return OrderDetails(
      userID: json['request']['user_id'],
      orderID: json['request']['id'].toString(),
      bookingID: json['request']['booking_id'].toString(),
      sLatitude: json['request']['s_latitude'],
      sLongitude: json['request']['s_longitude'],
      sAddress: json['request']['s_address'],
      productTypeID: json['request']['product_type_id'],
      estimatedFare: json['request']['estimated_fare'],
      distance: json['request']['distance'],
      useWallet: json['request']['use_wallet'],
      paymentMethod: json['request']['payment_mode'],
      pickupPhone: json['request']['pickuphone'],
      driver:
          json['request']['provider_id'].toString() != "0" ? orderDriver : null,
      orderDate: json['request']['schedule_at'] ?? "",
      promoCode: json['promocode'] ?? "",
      otp: json['request']['otp'] ?? "111111",
      status: json['request']['status'] ?? "",
      vehicleName: json['vehicle']['name']['en'] ?? "",
      vehicleImage: json['vehicle']['image'] ?? "",
      productType: json['producttype'] != null
          ? json['producttype']['name']['en']
          : "Not Specified",
    );
  }
}
