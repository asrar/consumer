import 'dart:convert';

import 'package:consumer/ArrangeDelivery/pickup_page.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/my_deliveries.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainTabNavigation extends StatefulWidget {
  final int initialPageIndex;

  MainTabNavigation({
    required this.initialPageIndex,
  });

  @override
  _MainTabNavigationState createState() => _MainTabNavigationState();
}

class _MainTabNavigationState extends State<MainTabNavigation> {
  PageController? pageController;
  int currentInd = 0;

  double rating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPageIndex != currentInd) {
      setState(() {
        currentInd = widget.initialPageIndex;
      });
    }
    setState(() {
      pageController = PageController(initialPage: currentInd);
    });

    getUnratedProjects();
  }

  getUnratedProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("id")!;
    print(
      "SENDING REQ TO: " + APIRoutes.getUnratedOrders + userID,
    );
    var response = await http.post(
      Uri.parse(
        APIRoutes.getUnratedOrders + userID,
      ),
    );
    //9716293972
    var jsonResponse = json.decode(response.body);
    print(">>>>>>>>>>>>>>>   response <<<<<<<<<<<<<<");
    print("here is total response ${jsonResponse} ");
    jsonResponse['requestdata'].forEach((v) {
      print("response line ${v}");
      showRatingMenu(v);
    });
  }

  showRatingMenu(dynamic v) {
    Future.delayed(
      Duration(
        seconds: 1,
      ),
      () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Rate your delivery experience",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  RatingBar.builder(
                    initialRating: rating,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                        case 1:
                          return Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.redAccent,
                          );
                        case 2:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: Colors.amber,
                          );
                        case 3:
                          return Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.lightGreen,
                          );
                        case 4:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                        default:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                      }
                    },
                    onRatingUpdate: (_rating) {
                      print(rating);
                      setState(() {
                        rating = _rating;
                      });
                    },
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "How was your overall experience with your driver at Shipper in your previous delivery (order #" +
                        v['booking_id'] +
                        ")?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (rating > 0) {
                        var response = await http.post(
                          Uri.parse(
                            APIRoutes.rateOrder + v['booking_id'],
                          ),
                        );
                        setState(() {
                          rating = 0.0;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "Order was rated successfully");
                      } else {
                        Fluttertoast.showToast(
                          msg:
                              "Please tap on an icon to select how satisfied were you with the delivery process.",
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7423A),
                        borderRadius: BorderRadius.circular(
                          100,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Rate Order",
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
                  Container(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentInd,
        selectedItemColor: kMainColor,
        selectedLabelStyle: TextStyle(
          color: kMainColor,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        onTap: (pgNum) {
          setState(() {
            currentInd = pgNum;
          });
          pageController!.animateToPage(
            pgNum,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book_online,
              size: 18,
            ),
            label: "Create Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_pin,
              size: 18,
            ),
            label: "Track Order",
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          PickupPage(),
          MyDeliveriesPage(),
        ],
      ),
    );
  }
}
