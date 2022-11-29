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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class TransactionCard {
  final String image;
  final String? itemType;
  final String? deliveryType;
  final String paidMoney;
  final String paidVia;
  final String earnedMoney;

  TransactionCard(
    this.image,
    this.itemType,
    this.deliveryType,
    this.paidMoney,
    this.paidVia,
    this.earnedMoney,
  );
}

class _WalletPageState extends State<WalletPage> {
  TextEditingController amountController = TextEditingController();

  List<SavedAddress> savedAddresses = [];

  bool isLoadingAddresses = true;

  String name = "";
  String mobile = "";
  String userID = "";
  String walletBalance = "";

  var _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    getUserDetails();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initiateTransaction(String amount) async {
    Map<String, dynamic> body = {
      'amount': amount,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "gyconix.com", // my ip address , localhost
        "payshipper/generate_token.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    print(res.statusCode);
    if (res.statusCode == 200) {
      var bodyJson = jsonDecode(res.body);
      //  on success of txtoken generation api
      //  start transaction

      var response = AllInOneSdk.startTransaction(
        bodyJson['mid'], // merchant id  from api
        bodyJson['orderId'], // order id from api
        amount, // amount
        bodyJson['txnToken'], // transaction token from api
        "", // callback url
        true, // isStaging
        false, // restrictAppInvoke
      ).then((value) async {
        //  on payment completion we will verify transaction with transaction verify api
        //  after payment completion we will verify this transaction
        //  and this will be final verification for payment
        print("ISKE NEECHE VALU HAI");
        print(value);
        var responseAdd = await http.post(
          Uri.parse(
            APIRoutes.addMoney + amountController.text + "&user_id=" + userID,
          ),
        );
        setState(() {
          walletBalance = "...";
        });
        getWalletAmount();
        Fluttertoast.showToast(
            msg: "Payment was successfully processed, updating balance...");
      }).catchError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }

  addMoney() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            "Amount",
          ),
          children: [
            SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: amountController,
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
                hintText: "This will be added to your wallet.",
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  if (double.parse(amountController.text) < 100) {
                    Fluttertoast.showToast(
                      msg: "Minimum amount to charge is 100 rupee.",
                    );
                  } else {
                    Navigator.pop(context);
                    initiateTransaction(amountController.text);
                  }
                  // var responseAdd = await http.post(
                  //   Uri.parse(
                  //     APIRoutes.addMoney +
                  //         amountController.text +
                  //         "&user_id=" +
                  //         userID,
                  //   ),
                  // );
                  // setState(() {
                  //   walletBalance = "...";
                  // });
                  // getWalletAmount();
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

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("PAYMENT SUCCESS: $response");
    var responseAdd = await http.post(
      Uri.parse(
        APIRoutes.addMoney + amountController.text + "&user_id=" + userID,
      ),
    );
    setState(() {
      walletBalance = "...";
    });
    getWalletAmount();
    Fluttertoast.showToast(
        msg: "Payment was successfully processed, updating balance...");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("PAYMENT FAILED: $response");
    Fluttertoast.showToast(msg: "Payment failed, please try again!");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print("PAYMENT FAILED: $response");
    Fluttertoast.showToast(msg: "Payment failed, please try again!");
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("USERNAME ::::::::::::: " + prefs.getString("id")!);
    setState(() {
      name = prefs.getString("full_name")!;
      mobile = prefs.getString("mobile")!;
      userID = prefs.getString("id")!;
    });
    getWalletAmount();
  }

  getWalletAmount() async {
    var response = await http.post(
      Uri.parse(
        APIRoutes.getDetails + mobile,
      ),
    );
    var jsonResponse = json.decode(response.body);

    if (jsonResponse['data'] != null) {
      setState(() {
        walletBalance = jsonResponse['data']['wallet_balance'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    final List<TransactionCard> cards = [
      TransactionCard(
        'images/home1.png',
        "Courier",
        "",
        '\$ 12.00',
        'PayPal',
        '\$ 9.50',
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: mediaQuery.size.height - mediaQuery.padding.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(flex: 2),
                Text(
                  "Balance",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline5,
                ),
                Spacer(),
                Text(
                  '₹ $walletBalance',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline4!.copyWith(
                      color: theme.backgroundColor,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(
                    onTap: addMoney,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                        border: Border.all(
                          color: Colors.white,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "+ Add Money",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headline4!.copyWith(
                            color: theme.backgroundColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 2),
                ClipRRect(
                  borderRadius: borderRadius,
                  child: Container(
                    height: mediaQuery.size.height * 0.76,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: borderRadius,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "RECENTS",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [boxShadow],
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: theme.backgroundColor,
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: FadedScaleAnimation(
                                        Image.asset(cards[index].image,
                                            scale: 4.2),
                                        durationInMilliseconds: 400,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: cards[index].itemType! + '\n',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: cards[index].deliveryType,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(color: theme.hintColor),
                                        ),
                                      ]),
                                    ),
                                    Spacer(),
                                    RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: cards[index].paidMoney + '\n',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color: theme.hintColor,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: cards[index].paidVia,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ]),
                                    ),
                                    SizedBox(width: 24.0),
                                    RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: cards[index].earnedMoney + '\n',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color: theme.hintColor,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: "EARNED",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ]),
                                    ),
                                  ],
                                ));
                          },
                        ),
                        SizedBox(height: 64),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
