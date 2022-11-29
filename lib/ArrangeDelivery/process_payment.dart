import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:consumer/ArrangeDelivery/pickup_page.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/load_delivery_drops.dart';
import 'package:consumer/Pages/track_delivery.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:consumer/models/package_type.dart';
import 'package:consumer/models/pickup_model.dart';
import 'package:consumer/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class ProcessPaymentPage extends StatefulWidget {
  List<DropModel> dropLocations;
  PickupLocation pickupLoc;
  Vehicle selectedVehicle;
  PackageType selectedPackageType;
  double totalDistance;

  ProcessPaymentPage({
    required this.dropLocations,
    required this.pickupLoc,
    required this.selectedVehicle,
    required this.selectedPackageType,
    required this.totalDistance,
  });

  @override
  _ProcessPaymentPageState createState() => _ProcessPaymentPageState();
}

enum PaymentMethod { CashOnDelivery, CashOnPickup, Online, CashOnReturn }

class _ProcessPaymentPageState extends State<ProcessPaymentPage> {
  var _razorpay = Razorpay();

  bool isEnteringCode = false;
  String appliedPromo = "";
  String appliedPromoID = "";

  double totalCost = 0;
  String discount = "0";

  bool isProceeding = false;

  PaymentMethod? _character = PaymentMethod.CashOnDelivery;

  String name = "";
  String mobile = "";
  String id = "";

  DateTime selectedDateTime = DateTime.now();

  TextEditingController promoController = TextEditingController();

  String walletBalance = "...";

  bool isScheduled = false;

  bool isCalculating = true;

  var jsonDrops = [];

  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getOrderPrice();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initiateTransaction(String amount) async {
    Map<String, dynamic> body = {
      'amount': amount,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "gyconix.com", // my ip address , localhost
        "payshipper/generate_token.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    print(res.statusCode);
    if (res.statusCode == 200) {
      var bodyJson = jsonDecode(res.body);
      //  on success of txtoken generation api
      //  start transaction

      var response = AllInOneSdk.startTransaction(
        bodyJson['mid'], // merchant id  from api
        bodyJson['orderId'], // order id from api
        amount, // amount
        bodyJson['txnToken'], // transaction token from api
        "", // callback url
        true, // isStaging
        false, // restrictAppInvoke
      ).then((value) {
        //  on payment completion we will verify transaction with transaction verify api
        //  after payment completion we will verify this transaction
        //  and this will be final verification for payment
        print("ISKE NEECHE VALU HAI");
        print(value);
        Fluttertoast.showToast(
            msg: "Payment was successfully processed, placing your order...");
        sendOrderDetails();
      }).catchError((error, stackTrace) {
        setState(() {
          isProceeding = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
          ),
        );
      });
    } else {
      setState(() {
        isProceeding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }

  getOrderPrice() async {
    var _jsonDrops = [];
    widget.dropLocations.forEach((instance) {
      var json = {
        "lat": instance.latitude,
        "long": instance.longitude,
      };
      print(jsonEncode(json));
      _jsonDrops.add(
        jsonEncode(
          json,
        ),
      );
    });
    String urlGet =
        "http://shipperdelivery.com/api/user/calculate_fare?s_latitude=${widget.pickupLoc.latitude.toString()}&s_longitude=${widget.pickupLoc.longitude.toString()}&drops=$_jsonDrops&total_distance=${widget.totalDistance.toString()}&service_type=" +
            widget.selectedVehicle.id;

    print(urlGet);
    var response = await http.post(
      Uri.parse(
        urlGet,
      ),
    );
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'].toString() != "false") {
      setState(() {
        double returnedPrice = double.parse(jsonResponse['price'].toString());
        double twentyPercentHike =
            double.parse(jsonResponse['price'].toString()) * 0.2;
        double toReturnPrice = returnedPrice;

        totalCost = toReturnPrice;
        isCalculating = false;
      });
    } else {
      setState(() {
        totalCost = 515.00;
        isCalculating = false;
      });
    }
  }

  Map<String, dynamic> convertToJSON(DropModel instance) {
    return <String, dynamic>{
      "address": instance.formattedAddress,
      "lat": instance.latitude,
      "long": instance.longitude,
      "name": instance.name,
      "phone": instance.number,
    };
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("full_name")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      id = prefs.getString("id")!;
    });
    getWalletAmount();
  }

  getWalletAmount() async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.getDetails + mobile,
      ),
    );
    var jsonResponse = json.decode(response.body);

    if (jsonResponse['data'] != null) {
      // print(jsonResponse);
      // print(jsonResponse['data']['wallet_balance']);
      setState(() {
        walletBalance = jsonResponse['data']['wallet_balance'];
      });
    }
  }

  sendOrderDetails() async {
    widget.dropLocations.forEach((instance) {
      var json = {
        "address": instance.formattedAddress,
        "lat": instance.latitude,
        "long": instance.longitude,
        "name": instance.name,
        "phone": instance.number,
      };
      print(jsonEncode(json));
      jsonDrops.add(
        jsonEncode(
          json,
        ),
      );
    });

    print(jsonDrops);

    String _paymentMethod = "Cash on Delivery";
    if (_character == PaymentMethod.Online) {
      _paymentMethod = "Credit/Debit Card";
    } else if (_character == PaymentMethod.CashOnPickup) {
      _paymentMethod = "Cash On Pickup";
    } else if (_character == PaymentMethod.CashOnReturn) {
      _paymentMethod = "Cash On Return/Receiving";
    }

    final DateFormat sendDateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat sendTimeFormatter = DateFormat('HH:mm:ss');
    String userID = id;
    String sLatitude = widget.pickupLoc.latitude.toString();
    String sLongitude = widget.pickupLoc.longitude.toString();
    String sAddress = widget.pickupLoc.formattedAddress.toString();
    String productTypeID = widget.selectedPackageType.id;
    String estimatedFare = totalCost.toString();
    String distance = "0.00";
    String useWallet = "0";
    String paymentMode = _paymentMethod;
    String pickupPhone = mobile;
    String packageValue = "500";
    String scheduledDate = sendDateFormatter.format(selectedDateTime);
    String scheduledTime = sendTimeFormatter.format(selectedDateTime);
    var drops = jsonDrops;
    String vehicleID = widget.selectedVehicle.id;
    String promoID = "0";
    String _schedule = isScheduled ? "YES" : "NO";
    print(drops);
    print("SENT REQ TO: " +
        'http://shipperdelivery.com/api/user/place_order?user_id=$userID&packagevalue=$packageValue&product_type_id=$productTypeID&estimated_fare=$estimatedFare&distance=$distance&use_wallet=$useWallet&payment_mode=$paymentMode&pickuphone=$pickupPhone&schedule_date=$scheduledDate&schedule_time=$scheduledTime&drops=$drops&vehicle_id=$vehicleID&promocode_id=$promoID&is_scheduled=$_schedule&s_latitude=$sLatitude&s_longitude=$sLongitude&s_address=$sAddress&pickupperson=$name');
    var response = await http.post(
      Uri.parse(
        'http://shipperdelivery.com/api/user/place_order?user_id=$userID&packagevalue=$packageValue&product_type_id=$productTypeID&estimated_fare=$estimatedFare&distance=$distance&use_wallet=$useWallet&payment_mode=$paymentMode&pickuphone=$pickupPhone&schedule_date=$scheduledDate&schedule_time=$scheduledTime&drops=$drops&vehicle_id=$vehicleID&promocode_id=$promoID&is_scheduled=$_schedule&s_latitude=$sLatitude&s_longitude=$sLongitude&s_address=$sAddress&pickupperson=$name',
      ),
    );

    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['status'] == "success") {
      String title = "Order Placed";
      String message = "Your order was successfully placed (Booking ID: " +
          jsonResponse['userrequest']['booking_id'].toString() +
          ").";
      Fluttertoast.showToast(
        msg: "Your order was successfully placed, redirecting...",
      );
      await http.post(
        Uri.parse(
          APIRoutes.sendNotifications +
              userID +
              "&title=$title&message=$message",
        ),
      );
      String driverMessage = "";
      widget.dropLocations.forEach((element) {
        driverMessage += "DROP LOCATION: ${element.formattedAddress} | ";
      });
      driverMessage +=
          "Order ID (${jsonResponse['userrequest']['booking_id'].toString()}): PICKUP LOCATION:  $sAddress";
      driverMessage += " | FARE: ₹$estimatedFare";

      await http.post(
        Uri.parse(
          "http://shipperdelivery.com/api/user/notifyalldriver?message=$driverMessage&booking_id=" +
              jsonResponse['userrequest']['booking_id'].toString(),
        ),
      );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => MainTabNavigation(
                    initialPageIndex: 0,
                  )),
          (route) => false);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => LoadDeliveryInfo(
            orderID: jsonResponse['userrequest']['id'].toString(),
            bookingID: jsonResponse['userrequest']['booking_id'].toString(),
            isReload: false,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "There was an error processing your request: " +
            jsonResponse['message'],
      );
    }
    print(jsonResponse['userrequest']['booking_id']);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("PAYMENT SUCCESS: $response");
    Fluttertoast.showToast(
        msg: "Payment was successfully processed, placing your order...");
    sendOrderDetails();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("PAYMENT FAILED: $response");
    Fluttertoast.showToast(
        msg: "Payment failed, please try again! ${response.message}");
    setState(() {
      isProceeding = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print("PAYMENT FAILED: $response");
    Fluttertoast.showToast(msg: "Payment failed, please try again!");
    setState(() {
      isProceeding = false;
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  addPromoCode(String code) async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.applyPromo + "?promocode=$code&amount=$totalCost&user_id=$id",
      ),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'].toString() == "false") {
      Fluttertoast.showToast(
        msg: "This code is invalid.",
      );
    } else {
      print(jsonResponse);
      Fluttertoast.showToast(
        msg: "Code successfully applied",
      );
      setState(() {
        discount = jsonResponse['percentage'].toString();
        totalCost = double.parse(jsonResponse['amount'].toString());
        appliedPromo = code;
        appliedPromoID = jsonResponse['promocode_id'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Payment Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(
              context,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios, color: kMainColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "Total Fare:",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            if (isCalculating)
              Center(
                child: CircularProgressIndicator(color: kMainColor),
              ),
            if (!isCalculating)
              Text(
                "₹" + totalCost.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 24,
                ),
              ),
            if (!isEnteringCode)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEnteringCode = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "+ Add Promo Code",
                    style: TextStyle(
                      color: kMainColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            if (isEnteringCode)
              appliedPromo != ""
                  ? Text(
                      appliedPromo,
                      style: TextStyle(
                        color: kMainColor,
                        fontSize: 18,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: TextFormField(
                              controller: promoController,
                              onFieldSubmitted: addPromoCode,
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                height: 1,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kMainColor,
                                  ),
                                ),
                                hintText: "EG: FIRST20",
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            addPromoCode(promoController.text);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(
                                100,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            SizedBox(height: 10),
            if (discount != "0")
              Text(
                discount.toString() + "% discount applied",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Text(
                "Payment Method",
                style: TextStyle(
                  color: Colors.black,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _character = PaymentMethod.CashOnDelivery;
                });
              },
              child: ListTile(
                title: const Text(
                  'Cash on Delivery',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                leading: Radio<PaymentMethod>(
                  activeColor: kMainColor,
                  value: PaymentMethod.CashOnDelivery,
                  groupValue: _character,
                  onChanged: (PaymentMethod? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _character = PaymentMethod.CashOnReturn;
                });
              },
              child: ListTile(
                title: const Text(
                  'Cash on Return Receiving',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                leading: Radio<PaymentMethod>(
                  activeColor: kMainColor,
                  value: PaymentMethod.CashOnReturn,
                  groupValue: _character,
                  onChanged: (PaymentMethod? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _character = PaymentMethod.CashOnPickup;
                });
              },
              child: ListTile(
                title: const Text(
                  'Cash on Pickup',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                leading: Radio<PaymentMethod>(
                  activeColor: kMainColor,
                  value: PaymentMethod.CashOnPickup,
                  groupValue: _character,
                  onChanged: (PaymentMethod? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _character = PaymentMethod.Online;
                });
              },
              child: ListTile(
                title: const Text(
                  'Online Payment',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                leading: Radio<PaymentMethod>(
                  activeColor: kMainColor,
                  value: PaymentMethod.Online,
                  groupValue: _character,
                  onChanged: (PaymentMethod? value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
            ),
            if (_character == PaymentMethod.Online &&
                double.parse(walletBalance) > 0)
              SizedBox(height: 20),
            if (_character == PaymentMethod.Online &&
                double.parse(walletBalance) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Text(
                  'Your wallet balance (₹$walletBalance) will be used first.\nNew Fare: ' +
                      (totalCost - double.parse(walletBalance)).toStringAsFixed(
                        2,
                      ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            Row(
              children: [
                Checkbox(
                  value: isScheduled,
                  checkColor: Colors.white,
                  activeColor: kMainColor,
                  onChanged: (value) {
                    setState(
                      () {
                        selectedDateTime = DateTime.now();
                        isScheduled = value!;
                        if (value) {
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            currentTime: DateTime.now().add(
                              Duration(
                                minutes: 60,
                              ),
                            ),
                            minTime: DateTime.now(),
                            // maxTime: DateTime.now().add(
                            //   Duration(
                            //     hours: 2,
                            //   ),
                            // ),
                            onConfirm: (date) {
                              setState(() {
                                selectedDateTime = date;
                              });
                            },
                          );
                        }
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Do you want to schedule this\norder for future?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            if (isScheduled)
              Text(
                "Scheduled Date and Time: " +
                    Jiffy(selectedDateTime).yMMMMEEEEdjm,
                // style: TextStyle(
                //   fontSize: 12,
                // ),
              ),
            if (isScheduled)
              TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    currentTime: DateTime.now().add(
                      Duration(
                        minutes: 60,
                      ),
                    ),
                    minTime: DateTime.now(),
                    onConfirm: (date) {
                      setState(() {
                        selectedDateTime = date;
                      });
                    },
                  );
                },
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: kMainColor,
                  ),
                ),
              ),
            if (isProceeding)
              Center(
                child: CircularProgressIndicator(color: kMainColor),
              ),
            if (!isProceeding)
              GestureDetector(
                onTap: () {
                  if (totalCost != 0) {
                    setState(() {
                      isProceeding = true;
                    });
                    if (_character == PaymentMethod.Online) {
                      if (double.parse(walletBalance) < totalCost.ceil()) {
                        if (double.parse(walletBalance) > 0) {
                          initiateTransaction(
                            (totalCost - double.parse(walletBalance))
                                .toStringAsFixed(
                              2,
                            ),
                          );
                        } else if (double.parse(walletBalance) == 0) {
                          initiateTransaction(
                            totalCost.toStringAsFixed(
                              2,
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  "Your account balance is in negative, please clear your dues before placing an order.");
                        }
                      } else {
                        sendOrderDetails();
                      }
                    } else {
                      sendOrderDetails();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: totalCost == 0 ? Colors.grey : Color(0xFFF7423A),
                    borderRadius: BorderRadius.circular(
                      100,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        _character == PaymentMethod.Online
                            ? "Pay Now"
                            : "Place Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
