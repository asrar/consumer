import 'dart:convert';

import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/models/AddressModel.dart';
import 'package:consumer/models/drop_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocationDrop extends StatefulWidget {
  const SearchLocationDrop({Key? key}) : super(key: key);

  @override
  _SearchLocationDropState createState() => _SearchLocationDropState();
}

class _SearchLocationDropState extends State<SearchLocationDrop> {
  List<AddressModel> locations = [];
  bool isLoading = false;

  TextEditingController receiverNameController = TextEditingController();
  TextEditingController receiverNumberController = TextEditingController();

  searchLocationByText(String text) async {
    setState(() {
      locations = [];
      isLoading = true;
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
        locations.add(
          AddressModel.fromJson(
            result,
          ),
        );
      });
    });
    setState(() {
      isLoading = false;
    });
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

  addNameAndNumber(String address) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            "Receiver Information",
          ),
          children: [
            SizedBox(height: 15),
            TextFormField(
              controller: receiverNameController,
              style: TextStyle(
                height: 1,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                hintText: "Receiver Name",
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: receiverNumberController,
              style: TextStyle(
                height: 1,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                hintText: "Receiver Number",
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  DropModel dropLocationReturn = DropModel(
                    formattedAddress: address,
                    latitude: '',
                    longitude: '',
                    name: prefs.getString("full_name")!,
                    number: prefs.getString("mobile")!,
                  );
                  Navigator.pop(context);
                  Navigator.pop(context, dropLocationReturn);
                },
                child: Text(
                  "Same as Sender",
                  style: TextStyle(
                    color: kMainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (receiverNameController.text.length < 4) {
                    Fluttertoast.showToast(
                      msg: "Please enter receiver's full name",
                    );
                  } else {
                    if (receiverNumberController.text.length != 10) {
                      Fluttertoast.showToast(
                        msg: "Please enter a valid phone number(10 digits)",
                      );
                    } else {
                      DropModel dropLocationReturn = DropModel(
                        formattedAddress: address,
                        latitude: '',
                        longitude: '',
                        name: receiverNameController.text.toString(),
                        number: receiverNumberController.text.toString(),
                      );
                      Navigator.pop(context);
                      Navigator.pop(context, dropLocationReturn);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kMainColor,
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
            SizedBox(height: 15),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () => Navigator.pop(context, ""),
                child: Icon(
                  Icons.arrow_back_ios,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
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

                  addNameAndNumber(_formattedPickupAddress);
                },
                child: Icon(
                  Icons.location_searching,
                ),
              ),
              title: TextFormField(
                autofocus: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  searchLocationByText(value);
                },
                decoration: InputDecoration(
                  hintText: "Search for a location (ex: Connaught Place)",
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.grey),
                    //borderSide: const BorderSide(),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: kMainColor),
                    //borderSide: const BorderSide(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (isLoading)
              Center(
                child: Container(
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              ),
            if (!isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigator.pop(
                        //     context, locations[index].formattedAddress);
                        addNameAndNumber(
                          locations[index].formattedAddress,
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.map_rounded,
                          color: kMainColor,
                        ),
                        title: Text(
                          locations[index].formattedAddress,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Divider(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
