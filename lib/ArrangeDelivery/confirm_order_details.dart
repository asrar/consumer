import 'dart:async';
import 'dart:convert';

import 'package:consumer/ArrangeDelivery/process_payment.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/models/directions_model.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:consumer/models/package_type.dart';
import 'package:consumer/models/pickup_model.dart';
import 'package:consumer/models/vehicle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class ConfirmOrderDetailsPage extends StatefulWidget {
  List<DropModel> dropLocations;
  PickupLocation pickupLoc;

  ConfirmOrderDetailsPage({
    required this.dropLocations,
    required this.pickupLoc,
  });

  @override
  _ConfirmOrderDetailsPageState createState() =>
      _ConfirmOrderDetailsPageState();
}

class _ConfirmOrderDetailsPageState extends State<ConfirmOrderDetailsPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.6471948, 76.953179),
    zoom: 12,
  );

  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  bool isGeneratingRoute = true;

  PackageType? selectedPackageType =
      PackageType(id: "0", name: "Not Specified");
  List<PackageType> packageTypes = [];

  Vehicle? selectedVehicle;
  List<Vehicle> vehicles = [];

  double totalDistance = 0.0;
  String expectedDeliveryRunTime = "Calculating...";

  @override
  void initState() {
    super.initState();
    devisePickupDropMarkers();
    createRoutes();
    getCourierSettings();
    getVehicles();
  }

  Future<String> getOrderPrice(String vehID) async {
    var _jsonDrops = [];
    widget.dropLocations.forEach((instance) {
      var json = {
        "lat": instance.latitude,
        "long": instance.longitude,
      };
      _jsonDrops.add(
        jsonEncode(
          json,
        ),
      );
    });
    String urlGet =
        "http://shipperdelivery.com/api/user/calculate_fare?s_latitude=${widget.pickupLoc.latitude.toString()}&s_longitude=${widget.pickupLoc.longitude.toString()}&drops=$_jsonDrops&total_distance=${totalDistance.toString()}&service_type=" +
            vehID;

    print(urlGet);

    var response = await http.post(
      Uri.parse(
        urlGet,
      ),
    );
    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'].toString() != "false") {
      double returnedPrice = double.parse(jsonResponse['price'].toString());
      double twentyPercentHike =
          double.parse(jsonResponse['price'].toString()) * 0.2;
      double toReturnPrice = returnedPrice;
      return toReturnPrice.toStringAsFixed(2);
    } else {
      return "515.00";
    }
  }

  calculateTotalDistance() {}

  openVehicleMenu(Vehicle veh) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          "Name: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          veh.name,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ListTile(
                  //   title: Row(
                  //     children: [
                  //       Text(
                  //         "Capacity: ",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       Text(
                  //         veh.capacity + "KGs",
                  //         style: TextStyle(
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          "Price: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹" + veh.price,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Features: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          veh.description,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  getCourierSettings() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.packageSettings,
      ),
    );
    var jsonResponse = json.decode(response.body);
    jsonResponse['productType'].forEach((packageType) {
      setState(() {
        packageTypes.add(
          PackageType.fromJson(
            packageType,
          ),
        );
      });
    });
  }

  getVehicles() async {
    var response = await http.get(
      Uri.parse(
        APIRoutes.getVehicles,
      ),
    );
    var jsonResponse = json.decode(response.body);
    jsonResponse['data'].forEach((vehicleType) {
      setState(() {
        vehicles.add(
          Vehicle.fromJson(
            vehicleType,
          ),
        );
      });
    });
  }

  devisePickupDropMarkers() async {
    setState(
      () {
        markers.add(
          Marker(
            markerId: MarkerId("pickupLocation"),
            position:
                LatLng(widget.pickupLoc.latitude, widget.pickupLoc.longitude),
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
    final CameraPosition _currentLocation = CameraPosition(
      target: LatLng(widget.pickupLoc.latitude, widget.pickupLoc.longitude),
      zoom: 10,
    );
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _currentLocation,
      ),
    );
  }

  createRoutes() async {
    double distanceToUpdate = 0.0;
    setState(() {
      isGeneratingRoute = true;
    });
    var response = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.pickupLoc.latitude},${widget.pickupLoc.longitude}&destination=${widget.dropLocations[0].latitude},${widget.dropLocations[0].longitude}&key=${APIRoutes.googleAPIKey}",
      ),
    );
    if (response.statusCode == 200) {
      final _directions = Directions.fromMap(json.decode(response.body));
      print(_directions.totalDistance);
      setState(() {
        print('\x1B[33m Now Adding::: ${_directions.totalDistance}\x1B[0m');
        totalDistance += double.parse(_directions.totalDistance.split(" ")[0]);
      });
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
              if (_directions.totalDistance.contains("km")) {
                print(
                    '\x1B[33m Now Adding::: ${_directions.totalDistance} to $totalDistance\x1B[0m');
                totalDistance +=
                    double.parse(_directions.totalDistance.split(" ")[0]);
              }
            });
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

  selectCategoryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            // physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: packageTypes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPackageType = packageTypes[index];
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    packageTypes[index].name,
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Order Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(
              context,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios, color: kMainColor),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 12,
            child: isGeneratingRoute
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
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) async {
                            _controller.complete(controller);
                          },
                          markers: markers,
                          polylines: polyLines,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(
                                  20,
                                ),
                                bottomRight: Radius.circular(
                                  20,
                                ),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              totalDistance.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: totalDistance == 0.0
                    ? Center(
                        child: CircularProgressIndicator(
                          color: kMainColor,
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Order will be cancelled in 10 minutes, if no driver is assigned.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Vehicles",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              cacheExtent: 99999999,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedVehicle = vehicles[index];
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: selectedVehicle != null
                                            ? Border.all(
                                                color: selectedVehicle!.id ==
                                                        vehicles[index].id
                                                    ? kMainColor
                                                    : Colors.transparent,
                                              )
                                            : Border.all(
                                                color: Colors.transparent,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 5.0,
                                                top: 5.0,
                                              ),
                                              child: Center(
                                                child: Image.network(
                                                  "http://shipperdelivery.com/service/image/" +
                                                      vehicles[index].image,
                                                  height: 30,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  vehicles[index].name,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                // ₹
                                                FutureBuilder(
                                                  future: getOrderPrice(
                                                      vehicles[index].id),
                                                  initialData: "...",
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<String>
                                                              text) {
                                                    return new Text(
                                                      text.data == null
                                                          ? "₹515"
                                                          : "₹" + text.data!,
                                                      style: new TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    openVehicleMenu(
                                                        vehicles[index]);
                                                  },
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    color: kMainColor,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      selectCategoryMenu(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          50,
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          selectedPackageType!.name !=
                                                  "Not Specified"
                                              ? selectedPackageType!.name
                                              : "Select Package Type",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                selectedPackageType!.name !=
                                                        "Not Specified"
                                                    ? 16
                                                    : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              if (selectedVehicle != null) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => ProcessPaymentPage(
                                      pickupLoc: widget.pickupLoc,
                                      dropLocations: widget.dropLocations,
                                      selectedVehicle: selectedVehicle!,
                                      selectedPackageType: selectedPackageType!,
                                      totalDistance: totalDistance,
                                    ),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      "Please select a vehicle according to your package type",
                                );
                              }
                            },
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF7423A),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    // fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
