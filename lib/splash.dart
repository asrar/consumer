import 'dart:convert';

import 'package:consumer/ArrangeDelivery/pickup_page.dart';
import 'package:consumer/Authentication/Login/login_page.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    decideAndSend();
    getFCMToken();
  }

  getFCMToken() async {
    FirebaseMessaging.instance.getToken().then((value) async {
      String? token = value;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userID = prefs.getString("id");
      print(
        "FCM TOKEN:::: " + value.toString(),
      );
      print(
          "http://shipperdelivery.com/api/user/update_key?user_id=$userID&token=$token");
      var response = await http.post(
        Uri.parse(
          "http://shipperdelivery.com/api/user/update_key?user_id=$userID&token=$token",
        ),
      );
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
    });
  }

  decideAndSend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    var homeScreen = email == null
        ? LoginPage()
        : MainTabNavigation(
            initialPageIndex: 0,
          );
    Future.delayed(
      Duration(
        seconds: 2,
      ),
      () {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (_) => homeScreen,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: kMainColor,
            height: 40,
          ),
          Spacer(),
          Center(
            child: Image.asset(
              'images/Group7.png',
              width: 300,
              height: 300,
            ),
          ),
          Spacer(),
          Container(
            color: kMainColor,
            height: 40,
          ),
        ],
      ),
    );
  }
}
