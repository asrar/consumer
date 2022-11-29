import 'dart:convert';
import 'package:consumer/Pages/third.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/Authentication/Verification/verification_page.dart';
// import 'package:consumer/Authentication/signin_navigator.dart';
import 'package:consumer/BottomNavigation/Account/account_page.dart';
import 'package:consumer/BottomNavigation/Account/contact_us_page.dart';
import 'package:consumer/Components/continue_button.dart';
import 'package:consumer/Components/entry_field.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginBody();
  }
}

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;

  String mobile = "";

  loginAccount() async {
    print("pressed");
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      var response = await http.post(
        Uri.parse(
          APIRoutes.loginAccount + mobile,
        ),
      );
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null) {
        print(jsonResponse);
        var otpResponse = await http.post(
          Uri.parse(
            APIRoutes.generateOTP + "?mobile=$mobile&device_id=356829",
          ),
        );
        var otpJsonResponse = json.decode(otpResponse.body);
        var otp = otpJsonResponse['otp'];
        print(otp);
        print(jsonResponse['data']['fullname']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              otp: jsonResponse['data']['otp'],
              userData: jsonResponse['data'],
            ),
          ),
        );
      } else if (jsonResponse['message'] == "Invalid Mobile Number") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Third(
              mobile: mobile,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
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
          backgroundColor: Color(0xFFF7423A),
          body: ListView(children: [
            Center(
              child: Container(
                height: mediaQuery.size.height - mediaQuery.padding.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacer(),
                    Container(
                      height: mediaQuery.size.height * 0.96,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(35.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                color: Color(0xFFF7423A),
                              ),
                              Positioned(
                                top: 85,
                                child: CircleAvatar(
                                    radius: 65,
                                    backgroundImage:
                                        AssetImage("images/Group7.png"),
                                    backgroundColor: Colors.transparent),
                              )
                            ],
                          ),

                          // SizedBox(height: 2.0),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 90.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Fastest logistics service\nin your city",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontFamily: "ProductSans",
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      validator: (val) {
                                        if (val!.length != 10) {
                                          return "Please enter a valid phone number (10 Digits)";
                                        }
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          mobile = val;
                                        });
                                      },
                                      onFieldSubmitted: (val) {
                                        loginAccount();
                                      },
                                      style: TextStyle(
                                        height: 1,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFF7423A),
                                            width: 2.0,
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
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "You will receive an OTP on this number.",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontFamily: "ProductSans",
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.0),
                                    if (isLoading)
                                      Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFF7423A),
                                        ),
                                      ),
                                    if (!isLoading)
                                      InkWell(
                                        onTap: () {
                                          loginAccount();
                                        },
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF7423A),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Text(
                                              "Proceed",
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
                        ],
                      ),
                    ),
                    // Spacer(),
                    // Container(
                    //     height: 50,
                    //     width: double.infinity,
                    //     color: Color(0xFFF7423A),
                    //     child: Center(
                    //       child: Text(""),
                    //     )),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
