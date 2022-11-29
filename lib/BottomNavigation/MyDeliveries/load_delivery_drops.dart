import 'dart:convert';

import 'package:consumer/Pages/track_delivery.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:consumer/models/OrderDetails.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoadDeliveryInfo extends StatefulWidget {
  String bookingID;
  String orderID;
  bool isReload;

  LoadDeliveryInfo({
    required this.bookingID,
    required this.orderID,
    required this.isReload,
  });
  @override
  _LoadDeliveryInfoState createState() => _LoadDeliveryInfoState();
}

class _LoadDeliveryInfoState extends State<LoadDeliveryInfo> {
  List<DropModel> dropLocations = [];
  OrderDetails? orderDetails;
  var rawData;

  @override
  void initState() {
    super.initState();
    getOrderDetails();
    getAllDrops();
  }

  getOrderDetails() async {
    print("SENDING REQ TO:" + APIRoutes.getOrderDetails + widget.orderID);
    var response = await http.post(
      Uri.parse(
        APIRoutes.getOrderDetails + widget.orderID,
      ),
    );
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    setState(() {
      rawData = jsonResponse;
      orderDetails = OrderDetails.fromJson(jsonResponse);
    });
  }

  getAllDrops() async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.getOrderDrops + widget.bookingID,
      ),
    );
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    await jsonResponse['data'].forEach((element) {
      String _formattedAddress = element['address'];
      String _latitude = element['d_latitude'];
      String _longitude = element['d_longitude'];
      String _name = element['receiver_name'];
      String _number = element['receiver_phone'];
      setState(() {
        dropLocations.add(
          DropModel(
            formattedAddress: _formattedAddress,
            latitude: _latitude,
            longitude: _longitude,
            name: _name,
            number: _number,
          ),
        );
      });
    });
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 0,
            ),
          ),
          (route) => false);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => TrackDelivery(
            orderDetails: orderDetails!,
            dropLocations: dropLocations,
            rawData: rawData,
            isReload: widget.isReload,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(
              color: kMainColor,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              "Fetching Order Details...",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
