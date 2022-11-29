import 'dart:convert';

import 'package:consumer/BottomNavigation/Account/account_page.dart';
import 'package:consumer/BottomNavigation/Account/saved_address_page.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/Theme/style.dart';
import 'package:consumer/models/AddressModel.dart';
import 'package:consumer/models/saved_addresses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  List<SavedAddress> savedAddresses = [];

  bool isLoadingAddresses = true;

  String name = "";
  String mobile = "";
  String userID = "";
  TextEditingController pickController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<AddressModel> pickupLocations = [];

  bool isLoadingPickup = false;

  late GoogleMapController _controllerPickupMap;

  Marker? pickupMarker;

  searchLocationByText(String text) async {
    setState(() {
      pickupLocations = [];
      isLoadingPickup = true;
    });
    var response = await http.get(
      Uri.parse(
        APIRoutes.googleSearchAPI + text,
      ),
    );
    var jsonResponse = json.decode(response.body);
    print(jsonResponse);
    jsonResponse['predictions'].forEach((result) {
      setState(() {
        pickupLocations.add(
          AddressModel.fromJson(
            result,
          ),
        );
      });
    });
    setState(() {
      isLoadingPickup = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  showOnMap(String _formattedAddress) async {
    var responseCoords = await http.get(
      Uri.parse(
        APIRoutes.googleGeometryAPI + _formattedAddress,
      ),
    );
    var jsonResponseCoords = json.decode(responseCoords.body);
    print(jsonResponseCoords);
    String _lat = jsonResponseCoords['results'][0]['geometry']['location']
            ['lat']
        .toString();
    String _lng = jsonResponseCoords['results'][0]['geometry']['location']
            ['lng']
        .toString();
    setState(
      () {
        pickupMarker = Marker(
          markerId: MarkerId(
            "PickupMarker",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          position: LatLng(
            double.parse(_lat),
            double.parse(_lng),
          ),
          infoWindow: InfoWindow(
            title: "Tap to save location",
            onTap: () {
              showLocationAdder(
                context,
                _formattedAddress,
              );
            },
          ),
        );
      },
    );
    Future.delayed(
      Duration(
        seconds: 1,
      ),
      () {
        setState(
          () {
            _controllerPickupMap.showMarkerInfoWindow(
              MarkerId(
                "PickupMarker",
              ),
            );
          },
        );
      },
    );
    await _controllerPickupMap.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(_lat),
            double.parse(_lng),
          ),
          zoom: 11.5,
        ),
      ),
    );
  }

  showLocationAdder(BuildContext context, String formattedAddress) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Add Location"),
          children: [
            Container(
              margin:
                  EdgeInsetsDirectional.only(top: 16.0, start: 16.0, end: 10.0),
              child: TextFormField(
                key: ValueKey("Title"),
                controller: titleController,
                style: TextStyle(
                  color: Colors.black,
                ),
                cursorColor: Color(0xFFF7423A),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.title,
                    color: kMainColor,
                  ),
                  hintText: "Enter Title",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  counter: Offstage(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                saveLocation(titleController.text, formattedAddress);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF7423A),
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  width: 200,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  saveLocation(String title, String formattedAddress) async {
    if (title.trim() == "") {
      Fluttertoast.showToast(msg: "Title can not be left empty");
    } else {
      var response = await http.post(
        Uri.parse(
          APIRoutes.saveAddress +
              "$userID&title=$title&formated_address=$formattedAddress",
        ),
      );
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == "success") {
        Fluttertoast.showToast(
          msg: "New address saved as $title.",
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SavedAddressesPage(),
          ),
        );
      }
    }
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("id")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      userID = prefs.getString("id")!;
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
            builder: (_) => SavedAddressesPage(),
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
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => SavedAddressesPage(),
                              ),
                            );
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
                          "Add Address",
                          style: TextStyle(
                              color: theme.backgroundColor, fontSize: 28),
                        ),
                      ],
                    ),
                  ),
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
                              "Add Address",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                    top: 26.0,
                                    start: 16.0,
                                    end: 10.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: TextFormField(
                                            key: ValueKey("Pick Location"),
                                            controller: pickController,
                                            onChanged: (value) {
                                              searchLocationByText(
                                                value,
                                              );
                                            },
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            cursorColor: Color(0xFFF7423A),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.location_on,
                                                color: theme.primaryColor,
                                              ),
                                              hintText:
                                                  "Enter pickup location.",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      Colors.grey.withOpacity(
                                                    0.6,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  35.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: kMainColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  35.0,
                                                ),
                                              ),
                                              counter: Offstage(),
                                              fillColor: theme.backgroundColor,
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      GoogleMap(
                                        markers: {
                                          if (pickupMarker != null)
                                            pickupMarker!,
                                        },
                                        onMapCreated: (controller) {
                                          setState(() {
                                            _controllerPickupMap = controller;
                                          });
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            28.7041,
                                            77.1025,
                                          ),
                                          zoom: 10,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          if (isLoadingPickup ||
                                              pickupLocations.isNotEmpty)
                                            Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  boxShadow,
                                                ],
                                                color: kWhiteColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15.0)),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 20.0,
                                              ),
                                              margin:
                                                  EdgeInsetsDirectional.only(
                                                start: 16.0,
                                                end: 10.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: <Widget>[
                                                  if (isLoadingPickup)
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Color(0xFFF7423A),
                                                      ),
                                                    ),
                                                  MediaQuery.removePadding(
                                                    removeTop: true,
                                                    context: context,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount: pickupLocations
                                                                  .length >
                                                              3
                                                          ? 3
                                                          : pickupLocations
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            showOnMap(
                                                                pickupLocations[
                                                                        index]
                                                                    .formattedAddress);
                                                            setState(() {
                                                              pickController
                                                                      .text =
                                                                  pickupLocations[
                                                                          index]
                                                                      .formattedAddress;
                                                              pickupLocations =
                                                                  [];
                                                            });
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            // _pageController!.animateToPage(
                                                            //     currentIndex,
                                                            //     duration: Duration(
                                                            //         milliseconds:
                                                            //             500),
                                                            //     curve: Curves
                                                            //         .linearToEaseOut);
                                                          },
                                                          child: ListTile(
                                                            title: Text(
                                                              pickupLocations[
                                                                      index]
                                                                  .formattedAddress,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
