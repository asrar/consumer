import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/load_delivery_drops.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/my_deliveries.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:consumer/models/OrderDetails.dart';
import 'package:consumer/models/directions_model.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

class TrackDelivery extends StatefulWidget {
  OrderDetails orderDetails;
  List<DropModel> dropLocations;
  bool isReload;
  var rawData;
  TrackDelivery({
    required this.orderDetails,
    required this.dropLocations,
    required this.rawData,
    required this.isReload,
  });
  @override
  _TrackDeliveryState createState() => _TrackDeliveryState();
}

class _TrackDeliveryState extends State<TrackDelivery>
    with WidgetsBindingObserver {
  String name = "";
  String userID = "";
  String mobile = "";

  CountdownTimerController? controller;

  bool isGeneratingRoute = true;

  List<LatLng> points = [];
  Set<Polyline> polyLines = {};

  Set<Marker> markers = {};

  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  LatLng? pickupPoint;
  LatLng? dropPoint;

  Directions? directions;

  List<String> cancelReasons = [];

  BitmapDescriptor? driverPinLoc;

  int endTime = 0;

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("BGMESSAGE");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainTabNavigation(
            initialPageIndex: 1,
          ),
        ),
        (route) => false);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => LoadDeliveryInfo(
          orderID: widget.orderDetails.orderID,
          bookingID: widget.orderDetails.bookingID,
          isReload: true,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("LIFECYCLE STATE CHGANGES");
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isReload && widget.orderDetails.status == "COMPLETED") {
      Fluttertoast.showToast(
          msg:
              "Your order was successfully delivered. Thankyou for choosing Shipper.");
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainTabNavigation(
                initialPageIndex: 0,
              ),
            ),
            (route) => false);
      });
    }

    if (widget.isReload && widget.orderDetails.status == "CANCELLED") {
      Fluttertoast.showToast(msg: "Your order was cancelled by the driver.");
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainTabNavigation(
                initialPageIndex: 0,
              ),
            ),
            (route) => false);
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String notification = message.notification!.title!;
      Map<String, dynamic> data = message.data;

      print(notification);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 1,
            ),
          ),
          (route) => false);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => LoadDeliveryInfo(
            orderID: widget.orderDetails.orderID,
            bookingID: widget.orderDetails.bookingID,
            isReload: true,
          ),
        ),
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("A NOTIFICATION WAS RECEIVED");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 1,
            ),
          ),
          (route) => false);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => LoadDeliveryInfo(
            orderID: widget.orderDetails.orderID,
            bookingID: widget.orderDetails.bookingID,
            isReload: true,
          ),
        ),
      );
    });
    FirebaseMessaging.onBackgroundMessage((message) async {
      print("A NOTIFICATION WAS RECEIVED");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 1,
            ),
          ),
          (route) => false);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => LoadDeliveryInfo(
            orderID: widget.orderDetails.orderID,
            bookingID: widget.orderDetails.bookingID,
            isReload: true,
          ),
        ),
      );
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (widget.orderDetails.status == "SCHEDULED") {
      var createdAt =
          DateTime.parse(widget.rawData['request']['created_at']).add(
        Duration(
          minutes: 10,
        ),
      );
      setState(() {
        endTime = createdAt.millisecondsSinceEpoch;
      });
    }

    print(widget.rawData['request']['is_scheduled']);
    getUserDetails();
    getCancelReasons();
    createRoutes();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    setState(() async {
      driverPinLoc = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'images/driver-pin.png',
      );
    });
  }

  createRoutes() async {
    setState(
      () {
        markers.add(
          Marker(
            markerId: MarkerId("pickupLocation"),
            position: LatLng(
              double.parse(widget.orderDetails.sLatitude),
              double.parse(
                widget.orderDetails.sLongitude,
              ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        int count = 0;
        widget.dropLocations.forEach((element) {
          count++;
          markers.add(
            Marker(
              markerId: MarkerId("drop" + count.toString()),
              position: LatLng(double.parse(element.latitude),
                  double.parse(element.longitude)),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          );
        });
      },
    );
    var response = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.orderDetails.sLatitude},${widget.orderDetails.sLongitude}&destination=${widget.dropLocations[0].latitude},${widget.dropLocations[0].longitude}&key=${APIRoutes.googleAPIKey}",
      ),
    );
    if (response.statusCode == 200) {
      final _directions = Directions.fromMap(json.decode(response.body));
      print(_directions.totalDuration);
      setState(() {
        polyLines.add(
          Polyline(
            polylineId: PolylineId(
              "overview_polyline",
            ),
            color: kMainColor,
            width: 6,
            points: _directions.polylinePoints
                .map(
                  (e) => LatLng(
                    e.latitude,
                    e.longitude,
                  ),
                )
                .toList(),
          ),
        );
      });
    }
    if (widget.dropLocations.length > 1) {
      int count = 1;
      widget.dropLocations.forEach((element) async {
        // GENERATE AND ADD ROUTE
        await Future.delayed(
            Duration(
              seconds: 1,
            ), () async {
          print("GENERATING FROM " +
              element.formattedAddress +
              " TO " +
              widget.dropLocations[count].formattedAddress);
          response = await http.get(
            Uri.parse(
              "https://maps.googleapis.com/maps/api/directions/json?origin=${element.latitude},${element.longitude}&destination=${widget.dropLocations[count].latitude},${widget.dropLocations[count].longitude}&key=${APIRoutes.googleAPIKey}",
            ),
          );
          if (response.statusCode == 200) {
            final _directions = Directions.fromMap(json.decode(response.body));
            setState(() {
              polyLines.add(
                Polyline(
                  polylineId: PolylineId(
                    "overview_polyline" + count.toString(),
                  ),
                  color: kMainColor,
                  width: 6,
                  points: _directions.polylinePoints
                      .map(
                        (e) => LatLng(
                          e.latitude,
                          e.longitude,
                        ),
                      )
                      .toList(),
                ),
              );
            });
          }
          count++;
        });
        // if (count != widget.dropLocations.length - 1) count++;
      });

      setState(() {
        isGeneratingRoute = false;
      });
    }

    setState(() {
      isGeneratingRoute = false;
    });
  }

  getCancelReasons() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getCancelReasons,
      ),
    );
    var jsonResponse = json.decode(response.body);
    jsonResponse['data'].forEach((v) {
      setState(() {
        cancelReasons.add(
          v['reason'],
        );
      });
    });
  }

  showCancelReasons(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cancelReasons.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showCancelWarning(cancelReasons[index]);
                },
                child: ListTile(
                  title: Text(
                    cancelReasons[index],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  showCancelWarning(String cancelReason) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Cancellation"),
          content: Text(
            "Are you sure you want to cancel your order for the following reason? \n\n\"$cancelReason\".\n\nYou may be charged some amount as compensation after reviewing the case.",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Stay",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                cancelOrder(cancelReason);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Cancel Order",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  cancelOrder(String cancelReason) async {
    String cancelURL = APIRoutes.cancelOrder +
        "$cancelReason&id=" +
        widget.orderDetails.orderID;

    var response = await http.post(
      Uri.parse(
        cancelURL,
      ),
    );
    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'].toString() == "true") {
      Fluttertoast.showToast(
        msg: "Order successfully cancelled",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      if (widget.orderDetails.driver != null) {
        String title = "Order Cancelled";
        String message =
            "Your order (${widget.orderDetails.bookingID}) has been cancelled. (Reason: $cancelReason)";
        String driverID = widget.orderDetails.driver!.id;
        await http.post(
          Uri.parse(
            "http://shipperdelivery.com/api/provider/sendnotification?provider_id=$driverID&title=$title&message=$message",
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MainTabNavigation(
                  initialPageIndex: 0,
                )),
      );
    }
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("full_name")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      userID = prefs.getString("id")!;
    });
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            snapshot.data!.docs.singleWhere((element) =>
                element.id == widget.orderDetails.orderID)['latitude'],
            snapshot.data!.docs.singleWhere((element) =>
                element.id == widget.orderDetails.orderID)['longitude'],
          ),
          zoom: 11.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    return FGBGNotifier(
      onEvent: (event) {
        if (event == FGBGType.foreground) {
          print("YAYYYYYYy");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainTabNavigation(
                  initialPageIndex: 1,
                ),
              ),
              (route) => false);
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => LoadDeliveryInfo(
                orderID: widget.orderDetails.orderID,
                bookingID: widget.orderDetails.bookingID,
                isReload: true,
              ),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: kWhiteColor,
          appBar: AppBar(
            title: Text(
              "Track Delivery (${widget.orderDetails.bookingID.toString()})",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                color: kMainColor,
                size: 24.0,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (_added) {
                      mymap(snapshot);
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: kMainColor,
                        ),
                      );
                    }
                    // if (widget.orderDetails.driver != null &&
                    //     widget.orderDetails.status != "COMPLETED") {
                    //   setState(() {
                    //     markers.add(
                    //       Marker(
                    //         position: LatLng(
                    //           snapshot.data!.docs.singleWhere((element) =>
                    //               element.id ==
                    //               widget.orderDetails.orderID)['latitude'],
                    //           snapshot.data!.docs.singleWhere((element) =>
                    //               element.id ==
                    //               widget.orderDetails.orderID)['longitude'],
                    //         ),
                    //         markerId: MarkerId('id'),
                    //         icon: BitmapDescriptor.defaultMarkerWithHue(
                    //           BitmapDescriptor.hueMagenta,
                    //         ),
                    //       ),
                    //     );
                    //   });
                    // }

                    return isGeneratingRoute
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                  color: kMainColor,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Generating Best Routes",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                child: GoogleMap(
                                  polylines: polyLines,
                                  markers: {
                                    if (widget.orderDetails.driver != null &&
                                        widget.orderDetails.status !=
                                            "COMPLETED")
                                      Marker(
                                        position: LatLng(
                                          snapshot.data!.docs.singleWhere(
                                              (element) =>
                                                  element.id ==
                                                  widget.orderDetails
                                                      .orderID)['latitude'],
                                          snapshot.data!.docs.singleWhere(
                                              (element) =>
                                                  element.id ==
                                                  widget.orderDetails
                                                      .orderID)['longitude'],
                                        ),
                                        markerId: MarkerId('id'),
                                        icon: driverPinLoc == null
                                            ? BitmapDescriptor
                                                .defaultMarkerWithHue(
                                                BitmapDescriptor.hueMagenta,
                                              )
                                            : driverPinLoc!,
                                      ),
                                    ...markers,
                                  },
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      28.7041,
                                      77.1025,
                                    ),
                                    zoom: 10,
                                  ),
                                  onMapCreated:
                                      (GoogleMapController controller) async {
                                    setState(() {
                                      _controller = controller;
                                      _added = true;
                                    });
                                  },
                                ),
                              ),
                              if (directions != null)
                                Positioned(
                                  top: 10,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: kMainColor.withOpacity(
                                          0.9,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                            20,
                                          ),
                                          bottomRight: Radius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          left: 12.0,
                                          bottom: 8.0,
                                          right: 20.0,
                                        ),
                                        child: Text(
                                          directions!.totalDistance,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  height: 40,
                                ),
                            ],
                          );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    if (widget.orderDetails.status == "SCHEDULED")
                      LinearProgressIndicator(
                        color: kMainColor,
                      ),
                    Container(
                      height: 25,
                    ),
                    if (endTime != 0 &&
                        widget.orderDetails.status == "SCHEDULED" &&
                        widget.rawData['request']['is_scheduled'] == "NO")
                      Center(
                        child: Text(
                          "This order will expire if no driver is found",
                        ),
                      ),
                    if (endTime != 0 &&
                        widget.orderDetails.status == "SCHEDULED" &&
                        widget.rawData['request']['is_scheduled'] == "NO")
                      Container(
                        height: 10,
                      ),
                    if (endTime != 0 &&
                        widget.orderDetails.status == "SCHEDULED" &&
                        widget.rawData['request']['is_scheduled'] == "NO")
                      Center(
                        child: CountdownTimer(
                            controller: controller,
                            endTime: endTime,
                            onEnd: () {
                              // cancelOrder(
                              //   "Driver was not found",
                              // );
                              setState(() {
                                widget.orderDetails.status = "CANCELLED";
                              });
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainTabNavigation(
                                    initialPageIndex: 0,
                                  ),
                                ),
                                (route) => false,
                              );
                            }),
                      ),
                    ListTile(
                      leading: FadedScaleAnimation(
                        Image.asset('images/home1.png'),
                        durationInMilliseconds: 400,
                      ),
                      title: Text(
                        locale.courier!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.orderDetails.status == "SCHEDULED"
                                ? "Searching Driver..."
                                : widget.orderDetails.status,
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: kMainColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            '₹ ' + widget.orderDetails.estimatedFare,
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: Colors.black,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Column(
                      children: <Widget>[
                        if (widget.orderDetails.driver != null)
                          if (widget.orderDetails.status != "CANCELLED" &&
                              widget.orderDetails.status != "COMPLETED")
                            Container(
                              decoration: BoxDecoration(
                                color: theme.backgroundColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(35.0)),
                              ),
                              child: ListTile(
                                leading: FadedScaleAnimation(
                                  CircleAvatar(
                                    radius: 25.0,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      widget.orderDetails.driver!.avatar != ""
                                          ? "http://shipperdelivery.com/providers/avatars/" +
                                              widget.orderDetails.driver!.avatar
                                          : "http://shipperdelivery.com/img/avatar.png",
                                    ),
                                  ),
                                  durationInMilliseconds: 400,
                                ),
                                title: Text(
                                  widget.orderDetails.driver!.firstName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(color: theme.primaryColorDark),
                                ),
                                subtitle: Text(
                                  widget.orderDetails.driver != null
                                      ? "One Time Password: " +
                                          widget.orderDetails.otp
                                      : "",
                                  style: theme.textTheme.subtitle2!.copyWith(
                                    color: kMainColor,
                                  ),
                                ),
                                trailing: FadedScaleAnimation(
                                  GestureDetector(
                                    onTap: () {
                                      launch(
                                        "tel: +91" +
                                            widget.orderDetails.driver!.mobile,
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: kMainColor,
                                      child: Icon(
                                        Icons.phone,
                                        size: 16.3,
                                        color: kWhiteColor,
                                      ),
                                    ),
                                  ),
                                  durationInMilliseconds: 400,
                                ),
                              ),
                            ),
                        SizedBox(height: 10.0),
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                top: 20.0,
                                bottom: 16.0,
                              ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: kMainColor,
                                    ),
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "+91 " + mobile + '\n',
                                            style: theme.textTheme.subtitle2!
                                                .copyWith(
                                                    color: theme.hintColor
                                                        .withOpacity(0.7)),
                                          ),
                                          TextSpan(
                                              text: name,
                                              style: theme.textTheme.headline6!
                                                  .copyWith(
                                                      color: theme
                                                          .primaryColorDark,
                                                      height: 1.5))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                ],
                              ),
                            ),
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              top: 12.0,
                              end: 16.0,
                              child: FadedScaleAnimation(
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MainTabNavigation(
                                                initialPageIndex: 1,
                                              ),
                                            ),
                                            (route) => false);
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => LoadDeliveryInfo(
                                              orderID:
                                                  widget.orderDetails.orderID,
                                              bookingID:
                                                  widget.orderDetails.bookingID,
                                              isReload: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 25.0,
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.refresh,
                                          color: kWhiteColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Refresh Details",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                                durationInMilliseconds: 400,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                              if(widget.orderDetails.status == "COMPLETED")
                              GestureDetector(
                                onTap: () {
                                  launch(
                                      "https://shipperdelivery.com/invoice/" +
                                          widget.orderDetails.orderID);
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Invoice  ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: kMainColor,
                                          ),
                                    ),
                                    Icon(
                                      Icons.download,
                                      color: kMainColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  "Booked Vehicle",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                Image.network(
                                  "http://shipperdelivery.com/service/image/" +
                                      widget.orderDetails.vehicleImage,
                                  height: 30,
                                ),
                              ],
                            ),
                            trailing: Text(
                              widget.orderDetails.vehicleName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: theme.primaryColorDark,
                                  ),
                            ),
                          ),
                        ),
                        if (widget.orderDetails.driver != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    "Vehicle Number",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                widget.orderDetails.driver!.vehicleNumber,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      color: theme.primaryColorDark,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  "Package Type",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                            trailing: Text(
                              widget.orderDetails.productType,
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: theme.primaryColorDark,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  "Payment Method",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                            trailing: Text(
                              widget.orderDetails.paymentMethod,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: theme.primaryColorDark,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  "Starting Time: ",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                            trailing: Text(
                              Jiffy(widget.orderDetails.orderDate).yMMMMEEEEdjm,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: theme.primaryColorDark,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListTile(
                            title: Text(
                              "Estimated Fare:",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            subtitle: Text(
                                "Payment Via " +
                                    widget.orderDetails.paymentMethod,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Color(0xffc2c2c2),
                                        fontSize: 11.7)),
                            trailing: Column(
                              children: [
                                Text(
                                  '₹ ' + widget.orderDetails.estimatedFare,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(color: theme.primaryColorDark),
                                ),
                                if (widget.orderDetails.promoCode != "")
                                  Text(
                                      "Promo: " + widget.orderDetails.promoCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              color: Color(0xffc2c2c2),
                                              fontSize: 11.7)),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "Pick & Drop Details",
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: kMainColor,
                          ),
                          title: Text(
                            widget.orderDetails.sAddress,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          subtitle: Text(
                            "Pickup",
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: Color(0xffc2c2c2),
                                      fontSize: 14,
                                    ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.dropLocations.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: kMainColor,
                              ),
                              title: Text(
                                widget.dropLocations[index].formattedAddress,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              subtitle: Text(
                                "Drop # " + (index + 1).toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                      color: Color(0xffc2c2c2),
                                      fontSize: 14,
                                    ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (widget.orderDetails.status == "SCHEDULED" ||
                            widget.orderDetails.status == "ACCEPTED")
                          GestureDetector(
                            onTap: () {
                              showCancelReasons(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(
                                    50,
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      "Cancel Delivery",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0)),
                                ),
                                builder: (context) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(
                                          Icons.email,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          'Send email',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          launch(
                                              "mailto:info@shipperdelivery.com");
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.phone,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          'Call phone',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          launch("tel:+917404964290");
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    50,
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      "Raise Dispute",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
