import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/load_delivery_drops.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Pages/track_delivery.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/style.dart';
import 'package:consumer/models/OrderDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:consumer/Routes/routes.dart';

class OrderCard {
  final String image;
  final String? title;
  final String time;
  final String? status;
  final String price;
  final String sender;
  final String receiver;

  OrderCard(this.image, this.title, this.time, this.status, this.price,
      this.sender, this.receiver);
}

class MyDeliveriesPage extends StatefulWidget {
  @override
  _MyDeliveriesPageState createState() => _MyDeliveriesPageState();
}

class _MyDeliveriesPageState extends State<MyDeliveriesPage> {
  bool isLoading = false;

  List<MiniOrderDetails> orders = [];

  String name = "";
  String mobile = "";

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("full_name")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
    loadAllDeliveries();
  }

  cancelOrder(String cancelReason, String orderID) async {
    String cancelURL = APIRoutes.cancelOrder + "$cancelReason&id=" + orderID;

    var response = await http.post(
      Uri.parse(
        cancelURL,
      ),
    );
  }

  loadAllDeliveries() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Sending REQ TO" + APIRoutes.activeOrders + prefs.getString("id")!);
    var response = await http.get(
      Uri.parse(APIRoutes.activeOrders + prefs.getString("id")!),
    );
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    jsonResponse['data'].forEach((v) {
      setState(() {
        if (v['is_scheduled'] == "NO" && v['status'] == "SCHEDULED") {
          var createdAt = DateTime.parse(v['created_at']);
          if (DateTime.now().isAfter(
            createdAt.add(
              Duration(
                minutes: 10,
              ),
            ),
          )) {
            print("Don't add");
          } else {
            orders.add(
              MiniOrderDetails.fromJson(
                v,
              ),
            );
          }
        } else {
          orders.add(
            MiniOrderDetails.fromJson(
              v,
            ),
          );
        }
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Padding(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 25,
            ),
            child: ListTile(
              title: Text(
                locale.myDeliv!,
                style: TextStyle(color: theme.backgroundColor, fontSize: 28),
              ),
            ),
          ),
        ),
        body: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0)),
              color: theme.cardColor,
            ),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                orders.length == 0
                    ? isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF7423A),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Icon(
                                Icons.no_luggage,
                                color: Color(0xFFF7423A),
                                size: 80,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "No active deliveries found!",
                                style: theme.textTheme.subtitle1!.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => LoadDeliveryInfo(
                                      orderID: orders[index].orderID,
                                      bookingID: orders[index].bookingID,
                                      isReload: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                    boxShadow: [boxShadow],
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: theme.backgroundColor),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: ListTile(
                                        leading: FadedScaleAnimation(
                                          Image.asset("images/home1.png",
                                              scale: 5),
                                          durationInMilliseconds: 400,
                                        ),
                                        title: Text(
                                          "Courier",
                                          style: theme.textTheme.subtitle1!
                                              .copyWith(
                                            color: theme.primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          Jiffy(orders[index].orderDate)
                                              .yMMMMEEEEdjm,
                                          style: theme.textTheme.subtitle1!
                                              .copyWith(fontSize: 12),
                                        ),
                                        trailing: RichText(
                                          textAlign: TextAlign.right,
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: orders[index].status ==
                                                      "SCHEDULED"
                                                  ? "Searching Driver..." + "\n"
                                                  : orders[index].status + "\n",
                                              style: theme.textTheme.bodyText1!
                                                  .copyWith(
                                                      color: theme.primaryColor,
                                                      height: 1.5),
                                            ),
                                            TextSpan(
                                              text: "₹" +
                                                  orders[index].estimatedFare,
                                              style: theme.textTheme.subtitle1!
                                                  .copyWith(
                                                fontSize: 14,
                                                height: 1.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                          color:
                                              theme.cardColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10.0),
                                              bottomRight:
                                                  Radius.circular(10.0))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 90),
                                            child: Text(
                                              name,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.caption,
                                            ),
                                          ),
                                          FadedScaleAnimation(
                                            Icon(
                                              Icons.location_on,
                                              color: theme.primaryColor,
                                              size: 21.0,
                                            ),
                                            durationInMilliseconds: 400,
                                          ),
                                          Text(
                                            "•••••••",
                                            style: theme.textTheme.caption!
                                                .copyWith(
                                                    color: theme.hoverColor
                                                        .withOpacity(0.7)),
                                          ),
                                          FadedScaleAnimation(
                                            Icon(
                                              Icons.navigation,
                                              color: theme.primaryColor,
                                              size: 21.0,
                                            ),
                                            durationInMilliseconds: 400,
                                          ),
                                          ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 90),
                                            child: Text(
                                              "DROPS",
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.caption,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
