import 'dart:convert';

import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/models/AddressModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key? key}) : super(key: key);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  List<AddressModel> locations = [];
  bool isLoading = false;

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
                        Navigator.pop(
                            context, locations[index].formattedAddress);
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
