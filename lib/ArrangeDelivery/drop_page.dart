import 'dart:convert';

// import 'package:ekery/ArrangeDelivery/confirm_order_details.dart';
// import 'package:ekery/ArrangeDelivery/pickup_page.dart';
// import 'package:ekery/ArrangeDelivery/search_location.dart';
// import 'package:ekery/ArrangeDelivery/search_location_drop.dart';
// import 'package:ekery/Routes/api_routes.dart';
// import 'package:ekery/Theme/colors.dart';
// import 'package:ekery/models/drop_model.dart';
// import 'package:ekery/models/pickup_model.dart';
import 'package:consumer/ArrangeDelivery/confirm_order_details.dart';
import 'package:consumer/ArrangeDelivery/search_location_drop.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:consumer/models/pickup_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DropoffPage extends StatefulWidget {
  PickupLocation pickupLoc;

  DropoffPage({required this.pickupLoc});

  @override
  _DropoffPageState createState() => _DropoffPageState();
}

class _DropoffPageState extends State<DropoffPage> {
  List<DropModel> dropLocations = [];

  bool isLoading = false;

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

  fetchAndAdd() async {
    final returnedModel = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => SearchLocationDrop(),
      ),
    );
    if (returnedModel.toString().trim() != "") {
      setState(() {
        isLoading = true;
      });
      LatLng searchedLoc = await convertAddressToCoords(
        returnedModel.formattedAddress.toString(),
      );
      setState(() {
        dropLocations.add(
          DropModel(
            formattedAddress: returnedModel.formattedAddress,
            latitude: searchedLoc.latitude.toString(),
            longitude: searchedLoc.longitude.toString(),
            name: returnedModel.name,
            number: returnedModel.number,
          ),
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Add Drop Locations",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => PickupPage(),
            //   ),
            // );
            Navigator.pop(context);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (dropLocations.length > 0 && !isLoading)
                  Text(
                    dropLocations.length == 0
                        ? "Click the + sign"
                        : "Click the + sign to add \nanother drop location",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: dropLocations.length == 0 ? 18 : 16,
                    ),
                  ),
                if (dropLocations.length > 0 && !isLoading)
                  GestureDetector(
                    onTap: () {
                      fetchAndAdd();
                    },
                    child: Column(
                      children: [
                        Container(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Add Stop",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 30,
          // ),
          if (dropLocations.length < 1 && !isLoading)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                GestureDetector(
                  onTap: () {
                    fetchAndAdd();
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
                        size: 80,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    fetchAndAdd();
                  },
                  child: Text(
                    "Add a drop",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          if (isLoading)
            Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                color: kMainColor,
              )),
            ),
          if (!isLoading)
            Expanded(
              // height: MediaQuery.of(context).size.height * 0.71,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dropLocations.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              100,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.map_rounded,
                                color: kMainColor,
                              ),
                              title: Text(
                                dropLocations[index].formattedAddress,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dropLocations[index].name +
                                      " (+91 ${dropLocations[index].number})",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    dropLocations.removeAt(index);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 0,
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                if (dropLocations.length != 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmOrderDetailsPage(
                        pickupLoc: widget.pickupLoc,
                        dropLocations: dropLocations,
                      ),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Please enter atleast one drop location",
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
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      // fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
