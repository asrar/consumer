import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/BottomNavigation/Account/account_page.dart';
import 'package:consumer/BottomNavigation/Account/add_address.dart';
import 'package:consumer/Components/address_field.dart';
import 'package:consumer/Components/continue_button.dart';
import 'package:consumer/Components/custom_app_bar.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/Theme/style.dart';
import 'package:consumer/models/saved_addresses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SavedAddressesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SavedAddressesBody();
  }
}

class SavedAddressesBody extends StatefulWidget {
  @override
  _SavedAddressesBodyState createState() => _SavedAddressesBodyState();
}

class _SavedAddressesBodyState extends State<SavedAddressesBody> {
  List<SavedAddress> savedAddresses = [];

  bool isLoadingAddresses = true;

  String name = "";
  String mobile = "";
  String userID = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("id")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      userID = prefs.getString("id")!;
    });
    getSavedAddresses();
  }

  getSavedAddresses() async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.savedAddresses + userID,
      ),
    );
    var jsonResponse = json.decode(
      response.body,
    );
    setState(() {
      isLoadingAddresses = false;
    });
    jsonResponse['data'].forEach((element) {
      setState(() {
        savedAddresses.add(
          SavedAddress.fromJson(
            element,
          ),
        );
      });
    });
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
            builder: (_) => AccountPage(),
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
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Saved Addresses",
                          style: TextStyle(
                              color: theme.backgroundColor, fontSize: 28),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Spacer(),
                  Container(
                    height: mediaQuery.size.height * 0.9,
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(35.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              "Saved Addresses",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => AddAddressScreen(),
                                  ),
                                );
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
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (isLoadingAddresses)
                            Center(
                              child: CircularProgressIndicator(
                                color: kMainColor,
                              ),
                            ),
                          if (savedAddresses.length == 0 && !isLoadingAddresses)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Icon(
                                    Icons.location_off,
                                    color: Color(0xFFF7423A),
                                    size: 80,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "No saved addresses found!",
                                    style: theme.textTheme.subtitle1!.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!isLoadingAddresses && savedAddresses.length != 0)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: savedAddresses.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color: kMainColor,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            10.0,
                                          ),
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        savedAddresses[index].title,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        savedAddresses[index].formattedAddress,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
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
}
