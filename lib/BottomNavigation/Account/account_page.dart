import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/ArrangeDelivery/pickup_page.dart';
import 'package:consumer/Authentication/Login/login_page.dart';
import 'package:consumer/BottomNavigation/Account/notifications_screen.dart';
import 'package:consumer/BottomNavigation/Account/offers_screen.dart';
import 'package:consumer/BottomNavigation/Account/saved_address_page.dart';
import 'package:consumer/BottomNavigation/Account/tnc_page.dart';
import 'package:consumer/BottomNavigation/Account/wallet.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountBody();
  }
}

class AccountBody extends StatefulWidget {
  @override
  _AccountBodyState createState() => _AccountBodyState();
}

class _AccountBodyState extends State<AccountBody> {
  String name = "Loading...";
  String mobile = "Loading...";
  String userID = "Loading...";
  String email = "Loading...";

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("full_name")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      userID = prefs.getString("id")!;
      email = prefs.getString("email")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 0,
            ),
          ),
        );
        print("Replaced");
        Future<bool> isReturn = Future.delayed(
            Duration(
              milliseconds: 10,
            ), () {
          return true;
        });
        return isReturn;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: mediaQuery.size.height - mediaQuery.padding.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      locale.accountText!,
                      style:
                          TextStyle(color: theme.backgroundColor, fontSize: 28),
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    // onTap: () =>
                    //     Navigator.pushNamed(context, PageRoutes.myProfilePage),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.0),
                      child: Row(
                        children: [
                          SizedBox(width: 24.0),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: name + '\n',
                                style: theme.textTheme.headline5,
                              ),
                              TextSpan(
                                text: "Phone: +91$mobile\n",
                              ),
                              TextSpan(
                                text: "Email: $email\n",
                              )
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: mediaQuery.size.height * 0.8,
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(35.0),
                      ),
                    ),
                    child: ListView(
                      children: [
                        buildListTile(
                          Icons.money,
                          "Wallet",
                          "Manage your wallet",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WalletPage(),
                              ),
                            );
                          },
                        ),
                        buildListTile(
                          Icons.notifications_active,
                          "Notifications",
                          "Your notification history.",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationScreen(),
                              ),
                            );
                          },
                        ),
                        buildListTile(
                          Icons.discount,
                          "Offers",
                          "Avail amazing discounts",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OffersScreen(),
                              ),
                            );
                          },
                        ),

                        buildListTile(
                          Icons.location_on,
                          locale.savedAddresses!,
                          locale.saveAddress!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SavedAddressesPage(),
                              ),
                            );
                          },
                        ),
                        // buildListTile(
                        //   Icons.list_alt,
                        //   "My Deliveries",
                        //   "List all active deliveries",
                        //   onTap: () {
                        //     Navigator.pushReplacement(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => MyDeliveriesPage(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        buildListTile(
                          Icons.sync_problem,
                          "Help",
                          "Raise a dispute if your experience was ruined in our logistics process.",
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                        buildListTile(
                          Icons.assignment,
                          locale.tnc!,
                          locale.knowtnc!,
                          onTap: () {
                            launch(
                                "https://shipperdelivery.com/termandcondition");
                          },
                        ),
                        buildListTile(
                          Icons.policy,
                          "Privacy Policy",
                          "Know our Privacy Policy",
                          onTap: () {
                            launch("https://shipperdelivery.com/privacypolicy");
                          },
                        ),
                        buildListTile(
                          Icons.call_split,
                          locale.shareApp!,
                          locale.shareFriends!,
                          onTap: () {
                            Share.share(
                              "Shipper, Fastest logistics service provider: https://play.google.com/store/apps/details?id=com.delivery.shipper",
                            );
                          },
                        ),
                        buildListTile(
                          Icons.exit_to_app,
                          locale.logout!,
                          locale.signoutAccount!,
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(locale.loggingout!),
                                  content: Text(locale.sureText!),
                                  actions: <Widget>[
                                    MaterialButton(
                                      child: Text(locale.no!),
                                      textColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: theme.backgroundColor)),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    MaterialButton(
                                      child: Text(locale.yes!),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: theme.backgroundColor)),
                                      textColor: theme.primaryColor,
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.clear();
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(IconData icon, String title, String subtitle,
      {Function? onTap}) {
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20.0),
      child: ListTile(
        leading: FadedScaleAnimation(
          Icon(
            icon,
            color: theme.primaryColor,
          ),
          durationInMilliseconds: 400,
        ),
        title: Text(
          title,
          style: theme.textTheme.headline5!.copyWith(
              color: theme.primaryColorDark, height: 1.72, fontSize: 22),
        ),
        subtitle: Text(subtitle,
            style: theme.textTheme.subtitle1!.copyWith(height: 1.3)),
        onTap: onTap as void Function()?,
      ),
    );
  }
}
