import 'dart:async';
import 'dart:convert';
// import 'package:alt_sms_autofill/alt_sms_autofill.dart';
// import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/ArrangeDelivery/pickup_page.dart';
import 'package:consumer/Components/continue_button.dart';
import 'package:consumer/Components/custom_app_bar.dart';
import 'package:consumer/Components/entry_field.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Routes/api_routes.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/main_tab_navigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VerificationScreen extends StatefulWidget {
  String? otp;
  final dynamic userData;

  VerificationScreen({this.otp, this.userData});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _counter = 10;
  late Timer _timer;

  bool _checkbox = true;
  bool checkboxError = false;

  bool isResendDisabled = true;

  String errorMessage = "The OTP you entered is not valid. Please try again.";
  bool hasError = false;

  String? enteredOTP = "";

  TextEditingController otpController = TextEditingController();

  _startTimer() {
    //shows timer
    _counter = 30; //time counter

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _counter > 0
            ? _counter--
            : setState(() {
                isResendDisabled = false;
                _timer.cancel();
              });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    // initSmsListener();
  }

  // Future<void> initSmsListener() async {
  //   String comingSms;
  //   try {
  //     comingSms = (await AltSmsAutofill().listenForSms)!;
  //     print(comingSms);
  //     final splitted = comingSms.split(' ');
  //     if (splitted.last == "Shipper") {
  //       print(splitted.first);
  //       setState(() {
  //         otpController.text = splitted.first;
  //         enteredOTP = splitted.first;
  //       });
  //       verifyPhoneNumber();
  //     }
  //     initSmsListener();
  //   } on PlatformException {
  //     comingSms = 'Failed to get Sms.';
  //   }
  // }

  Future<void> verifyPhoneNumber() async {
    print("OTP IS HERE ${enteredOTP}");
    print(widget.otp);
    if (enteredOTP == widget.otp) {
      if (!_checkbox) {
        setState(() {
          checkboxError = true;
        });
      } else {
        setState(() {
          hasError = false;
          checkboxError = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", widget.userData['email'].toString());
        prefs.setString("mobile", widget.userData['mobile'].toString());
        prefs.setString("full_name", widget.userData['fullname'].toString());
        prefs.setString("id", widget.userData['id'].toString());
        getFCMToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabNavigation(
              initialPageIndex: 0,
            ),
          ),
        );
      }
    } else {
      setState(() {
        hasError = true;
      });
    }
  }

  getFCMToken() async {
    FirebaseMessaging.instance.getToken().then((value) async {
      String? token = value;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userID = prefs.getString("id");
      print(
        "FCM TOKEN:::: " + value.toString(),
      );
      print(
          "http://shipperdelivery.com/api/user/update_key?user_id=$userID&token=$token");
      var response = await http.post(
        Uri.parse(
          "http://shipperdelivery.com/api/user/update_key?user_id=$userID&token=$token",
        ),
      );
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
    });
  }

  Future<void> resendButton() async {
    if (!isResendDisabled) {
      setState(() {
        isResendDisabled = true;
      });
      var response = await http.post(
        Uri.parse(
          APIRoutes.loginAccount + widget.userData['mobile'],
        ),
      );
      var jsonResponse = json.decode(response.body);
      print(jsonResponse['data']['otp']);
      setState(() {
        widget.otp = jsonResponse['data']['otp'];
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    // AltSmsAutofill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    return Scaffold(
      body: FadedSlideAnimation(
        SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: mediaQuery.size.height - mediaQuery.padding.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Spacer(),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      locale.otpText!,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "$_counter seconds",
                          style: Theme.of(context).textTheme.button,
                        ),
                        CustomButton(
                          text: locale.resendText,
                          color: !isResendDisabled
                              ? Color(0xFFF7423A)
                              : Colors.grey,
                          onPressed: () {
                            resendButton();
                          },
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: mediaQuery.size.height * 0.63,
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(35.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25.0,
                            vertical: 10,
                          ),
                          child: Text(
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25.0,
                            vertical: 10,
                          ),
                          child: TextFormField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.black,
                              height: 1,
                            ),
                            onChanged: (val) {
                              setState(() {
                                enteredOTP = val;
                              });
                            },
                            validator: (val) {
                              if (val!.length != 6) {
                                setState(() {
                                  hasError = true;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: kMainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (hasError)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _checkbox,
                                  activeColor: Color(0xFFF7423A),
                                  onChanged: (value) {
                                    setState(() {
                                      _checkbox = !_checkbox;
                                    });
                                  },
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'I agree ',
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            launch(
                                                "https://shipperdelivery.com/termandcondition");
                                          },
                                          child: Text(
                                            "Terms & Conditions",
                                            style: TextStyle(
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          ' and acknowledge',
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Text('that I have read the '),
                                        GestureDetector(
                                          onTap: () {
                                            launch(
                                                "https://shipperdelivery.com/privacypolicy");
                                          },
                                          child: Text(
                                            "Privacy Policy",
                                            style: TextStyle(
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        if (checkboxError)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Text(
                              "User can't be registered without agreeting to T&Cs and Privacy Policy",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Spacer(flex: 4),
                        CustomButton(
                          radius: BorderRadius.only(
                            topLeft: Radius.circular(35.0),
                          ),
                          onPressed: () {
                            verifyPhoneNumber();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }
}
