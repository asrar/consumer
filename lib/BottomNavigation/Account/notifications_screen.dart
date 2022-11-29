import 'dart:convert';

import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
import 'package:consumer/BottomNavigation/Account/wallet.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/Theme/style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  var notifications;

  @override
  void initState() {
    super.initState();
    getAllNotifications();
  }

  getAllNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
      "http://shipperdelivery.com/api/user/allusernotification?user_id=" +
          prefs.getString("id")!,
    );
    var response = await http.post(
      Uri.parse(
        "http://shipperdelivery.com/api/user/allusernotification?user_id=" +
            prefs.getString("id")!,
      ),
    );
    var jsonResponse = json.decode(response.body);
    // print(jsonResponse[0]['message']);
    setState(() {
      notifications = jsonResponse['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: mediaQuery.size.height - mediaQuery.padding.vertical,
            child: Column(
              children: [
                Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(flex: 2),
                      Text(
                        "Notifications",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headline5,
                      ),
                      Spacer(flex: 3),
                    ],
                  ),
                ),
                Spacer(),
                ClipRRect(
                  borderRadius: borderRadius,
                  child: Container(
                    height: mediaQuery.size.height * 0.9,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: borderRadius,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        if (notifications == null)
                          Center(
                            child: CircularProgressIndicator(
                              color: kMainColor,
                            ),
                          ),
                        if (notifications != null)
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [boxShadow],
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: theme.backgroundColor,
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: FadedScaleAnimation(
                                      Icon(
                                        Icons.notifications,
                                        color: kMainColor,
                                        size: 30,
                                      ),
                                      durationInMilliseconds: 400,
                                    ),
                                  ),
                                  title: Text(
                                    notifications[index]['message'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      Jiffy(notifications[index]['created_at'])
                                          .yMMMMEEEEdjm,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: 64),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
//      ),
    );
  }
}
