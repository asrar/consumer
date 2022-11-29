import 'dart:convert';

import 'package:consumer/Authentication/Login/login_page.dart';
import 'package:consumer/Authentication/Verification/verification_page.dart';
import 'package:consumer/BottomNavigation/Account/account_page.dart';
import 'package:consumer/BottomNavigation/Account/contact_us_page.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AccountType { Personal, Business }

class Third extends StatefulWidget {
  final String mobile;

  Third({required this.mobile});

  @override
  _ThirdState createState() => _ThirdState();
}

class _ThirdState extends State<Third> {
  bool _checkbox = true;
  bool checkboxError = false;
  bool isLoading = false;

  String email = "";
  String fullName = "";
  String referralCode = "";
  String locality = "";
  String zipcode = "";
  String gst = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController gstController = TextEditingController();

  AccountType _character = AccountType.Personal;

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  registerAccount() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      print(_checkbox);
      if (!_checkbox) {
        setState(() {
          checkboxError = true;
        });
      } else {
        setState(() {
          checkboxError = false;
          isLoading = true;
        });
        String accountType =
            _character == AccountType.Personal ? "Personal" : "Business";
        print("SENDING REQ TO: " +
            APIRoutes.registerAccount +
            "?fullname=$fullName&email=$email&mobile=${widget.mobile}&country_code=91&referral_code=$referralCode&account_type=$accountType&locality=$locality&zipcode=$zipcode&gst=$gst");
        var response = await http.post(
          Uri.parse(
            APIRoutes.registerAccount +
                "?fullname=$fullName&email=$email&mobile=${widget.mobile}&country_code=91&referral_code=$referralCode&account_type=$accountType&locality=$locality&zipcode=$zipcode&gst=$gst",
          ),
        );
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          print(jsonResponse);
          String title = "Registration Complete";
          String message =
              "Your account was successfully registered. Start placing deliveries now!";
          var sendnotification = await http.post(
            Uri.parse(
              APIRoutes.sendNotifications +
                  jsonResponse['data']['id'].toString() +
                  "&title=$title&message=$message",
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationScreen(
                otp: jsonResponse['data']['otp'],
                userData: jsonResponse['data'],
              ),
            ),
          );
        } else {
          print(jsonResponse['message']);
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                jsonResponse['message'],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              duration: Duration(
                seconds: 3,
              ),
              dismissDirection: DismissDirection.endToStart,
            ),
          );
          setState(() {
            isLoading = false;
          });
        }

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        Future<bool> isReturn = Future.delayed(
            Duration(
              milliseconds: 10,
            ), () {
          return true;
        });
        return isReturn;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFF7423A),
          ),
          body: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    color: Color(0xFFF7423A),
                  ),
                  Positioned(
                    top: 10,
                    child: CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage("images/Group7.png"),
                        backgroundColor: Colors.transparent),
                  )
                ],
              ),
              SizedBox(
                height: 80,
              ),
              Form(
                key: _formKey,
                child: Container(
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topCenter,
                            child: ClipRRect(),
                          ),
                          Center(
                            child: Container(
                              height: 20,
                              child: Text(
                                "Same-Day | Reliable | Quick | Safest",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "ProductSans",
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 25,
                              child: Text(
                                "Logistics service in Delhi & NCR",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "ProductSans",
                                  color: Color(0xFFF7423A),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Enter Full Name",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: nameController,
                            onChanged: (val) {
                              setState(() {
                                fullName = val;
                              });
                            },
                            validator: (val) {
                              if (val!.length < 3) {
                                return "Please enter your full name";
                              }
                              if (val.length > 25) {
                                return "Only 25 characters are allowed";
                              }
                            },
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
                              hintText: "John Doe",
                            ),
                          ),
                          SizedBox(height: 17),
                          Text(
                            "Enter Email",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: emailController,
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (!val!.contains("@")) {
                                return "Please enter a valid email address";
                              }
                              if (!val.contains(".")) {
                                return "Please enter a valid email address";
                              }
                            },
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
                              hintText: "john@doe.com",
                            ),
                          ),
                          SizedBox(height: 17),
                          Text(
                            "Enter City",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            // controller: referralController,
                            onChanged: (val) {
                              // setState(() {
                              //   referralCode = val;
                              // });
                            },
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
                              hintText: "Delhi",
                            ),
                          ),
                          SizedBox(height: 17),
                          Text(
                            "Enter Referral Code (optional)",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: referralController,
                            onChanged: (val) {
                              setState(() {
                                referralCode = val;
                              });
                            },
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
                              hintText: "XXXXXX",
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            readOnly: true,
                            initialValue: widget.mobile,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val!.length != 10) {
                                return "Please enter a valid phone number (10 Digits)";
                              }
                            },
                            style: TextStyle(
                              height: 1,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  top: 12,
                                  bottom: 0,
                                  left: 15,
                                  right: 15,
                                ),
                                child: Text(
                                  '+91 ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              hintText: "Enter 10 digit number",
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Account Type",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "ProductSans",
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text(
                                    'Personal',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  leading: Radio<AccountType>(
                                    activeColor: kMainColor,
                                    value: AccountType.Personal,
                                    groupValue: _character,
                                    onChanged: (AccountType? value) {
                                      setState(() {
                                        _character = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const Text(
                                    'Business',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  leading: Radio<AccountType>(
                                    activeColor: kMainColor,
                                    value: AccountType.Business,
                                    groupValue: _character,
                                    onChanged: (AccountType? value) {
                                      setState(() {
                                        _character = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          if (_character == AccountType.Business)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Enter GST Number (optional)",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "ProductSans",
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  controller: gstController,
                                  onChanged: (val) {
                                    setState(() {
                                      gst = val;
                                    });
                                  },
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
                                    hintText: "123456789012345",
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Locality",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "ProductSans",
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  controller: localityController,
                                  validator: (val) {
                                    if (val!.length < 1) {
                                      return "Please enter a valid locality";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      locality = val;
                                    });
                                  },
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
                                    hintText: "Delhi",
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Pin Code",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "ProductSans",
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  controller: zipCodeController,
                                  onChanged: (val) {
                                    setState(() {
                                      zipcode = val;
                                    });
                                  },
                                  validator: (val) {
                                    if (val!.length != 6) {
                                      return "Please enter a valid pin code.";
                                    }
                                  },
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
                                    hintText: "772502",
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 30),
                          if (isLoading)
                            Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF7423A),
                              ),
                            ),
                          if (!isLoading)
                            InkWell(
                              onTap: () {
                                registerAccount();
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 7,
              ),
              InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, SignInRoutes.signInRoot);
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  color: kMainColor,
                  // child: Center(
                  //    child: Text(""),
                  // )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
