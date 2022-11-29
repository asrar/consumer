import 'dart:async';
import 'dart:convert';
import 'package:consumer/models/pickup_model.dart';
import 'package:http/http.dart' as http;

import 'package:consumer/ArrangeDelivery/drop_page.dart';
import 'package:consumer/ArrangeDelivery/search_location.dart';
import 'package:consumer/BottomNavigation/Account/account_page.dart';

import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({Key? key}) : super(key: key);

  @override
  _PickupPageState createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  Completer<GoogleMapController> _controller = Completer();

  String formattedPickup = "Fetching Location...";

  CameraPosition position = CameraPosition(
    target: LatLng(28.6471948, 76.953179),
    zoom: 12,
  );

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.6471948, 76.953179),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<LatLng> convertAddressToCoords(String address) async {
    var responsePick = await http.get(
      Uri.parse(
        APIRoutes.googleGeometryAPI + address,
      ),
    );
    var jsonResponsePick = json.decode(responsePick.body);
    print(jsonResponsePick);
    String _lat = jsonResponsePick['results'][0]['geometry']['location']['lat']
        .toString();
    String _lng = jsonResponsePick['results'][0]['geometry']['location']['lng']
        .toString();
    return LatLng(
      double.parse(
        _lat,
      ),
      double.parse(
        _lng,
      ),
    );
  }

  Future<String> convertCoordsToAddress(String latLng) async {
    print(
      APIRoutes.googleReverseGeometryAPI + latLng,
    );
    var responseAddress = await http.get(
      Uri.parse(
        APIRoutes.googleReverseGeometryAPI + latLng,
      ),
    );
    var jsonResponseAddress = json.decode(responseAddress.body);
    print(jsonResponseAddress['results'][0]['formatted_address']);
    String currentLocation =
        jsonResponseAddress['results'][0]['formatted_address'];
    return currentLocation;
  }

  getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    String _formattedPickupAddress = await convertCoordsToAddress(
      _locationData.latitude.toString() +
          "," +
          _locationData.longitude.toString(),
    );

    setState(
      () {
        formattedPickup = _formattedPickupAddress;
      },
    );

    final CameraPosition _currentLocation = CameraPosition(
      target: LatLng(_locationData.latitude!, _locationData.longitude!),
      zoom: 15,
    );
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _currentLocation,
      ),
    );
    Future.delayed(
      Duration(
        seconds: 1,
      ),
      () {
        setState(
          () {
            controller.showMarkerInfoWindow(
              MarkerId(
                "currentLocation",
              ),
            );
          },
        );
      },
    );
  }

  fetchAndShow() async {
    final returnedAddress = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => SearchLocation(),
      ),
    );
    if (returnedAddress.toString().trim() != "") {
      LatLng searchedLoc =
          await convertAddressToCoords(returnedAddress.toString());
      setState(() async {
        formattedPickup = returnedAddress.toString();
        final GoogleMapController controller = await _controller.future;
        final CameraPosition _currentLocation = CameraPosition(
          target: searchedLoc,
          zoom: 15,
        );
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            _currentLocation,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Place Order",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AccountPage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.menu, color: kMainColor),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned(
                  child: GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                    },
                    onCameraMove: (_position) async {
                      setState(() {
                        formattedPickup = "Fetching Location...";
                      });
                      setState(() {
                        position = _position;
                      });
                    },
                    onCameraIdle: () async {
                      print("CAMERA HAS STOPPED MOVINGGGGG");
                      String _formattedPickupAddress =
                          await convertCoordsToAddress(
                        position.target.latitude.toString() +
                            "," +
                            position.target.longitude.toString(),
                      );
                      setState(() {
                        formattedPickup = _formattedPickupAddress;
                      });
                    },
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (formattedPickup != "Fetching Location...")
                        GestureDetector(
                          onTap: () async {
                            await fetchAndShow();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              color: kMainColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Change Pickup Location",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "images/pin.png",
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pickup Location",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            getCurrentLocation();
                          },
                          child: Icon(
                            Icons.location_searching,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await fetchAndShow();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(
                            100,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            title: Text(
                              formattedPickup,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(flex: 3),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => DropoffPage(
                                pickupLoc: PickupLocation(
                                  latitude: position.target.latitude,
                                  longitude: position.target.longitude,
                                  formattedAddress: formattedPickup,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: formattedPickup != "Fetching Location..."
                                ? kMainColor
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                              vertical: 10,
                            ),
                            child: Text(
                              "Proceed",
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
                    Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
