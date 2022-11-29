import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/Theme/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//9716293972
class SlideUpPanel extends StatefulWidget {
  @override
  _SlideUpPanelState createState() => _SlideUpPanelState();
}

class _SlideUpPanelState extends State<SlideUpPanel> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    return DraggableScrollableSheet(
      minChildSize: 0.25,
      initialChildSize: 0.25,
      maxChildSize: 0.975,
      builder: (context, controller) {
        var boxDecoration = BoxDecoration(
          boxShadow: [boxShadow],
          color: kWhiteColor,
          borderRadius: BorderRadius.all(Radius.circular(35.0)),
        );
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.7),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            controller: controller,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [boxShadow],
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                      ),
                      child: ListTile(
                        leading: FadedScaleAnimation(
                          CircleAvatar(
                            radius: 25.0,
                            backgroundImage:
                                AssetImage('images/deliveryman.png'),
                          ),
                          durationInMilliseconds: 400,
                        ),
                        title: Text(
                          'James Haydon',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: theme.primaryColorDark),
                        ),
                        subtitle: Text(
                          locale!.deliveryMan!,
                          style: theme.textTheme.subtitle2!.copyWith(
                              color: theme.hintColor.withOpacity(0.7)),
                        ),
                        trailing: FadedScaleAnimation(
                          CircleAvatar(
                            radius: 25.0,
                            backgroundColor: kMainColor,
                            child: Icon(
                              Icons.phone,
                              size: 16.3,
                              color: kWhiteColor,
                            ),
                          ),
                          durationInMilliseconds: 400,
                        ),
                      )),
                  SizedBox(height: 10.0),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 20.0, bottom: 16.0),
                        decoration: boxDecoration,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading:
                                  Icon(Icons.location_on, color: kMainColor),
                              title: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Walmart' + '\n',
                                    style: theme.textTheme.subtitle2!.copyWith(
                                        color:
                                            theme.hintColor.withOpacity(0.7)),
                                  ),
                                  TextSpan(
                                      text: 'Emili Williamson',
                                      style: theme.textTheme.headline6!
                                          .copyWith(
                                              color: theme.primaryColorDark,
                                              height: 1.5))
                                ]),
                              ),
                              subtitle: Text(
                                '128 Mott St, New York, NY 10013, United States',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(height: 1.5),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            ListTile(
                              leading:
                                  Icon(Icons.navigation, color: kMainColor),
                              title: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: locale.cityGarden! + '\n',
                                    style: theme.textTheme.subtitle2!.copyWith(
                                        color:
                                            theme.hintColor.withOpacity(0.7)),
                                  ),
                                  TextSpan(
                                      text: 'Samantha Smith',
                                      style: theme.textTheme.headline6!
                                          .copyWith(
                                              color: theme.primaryColorDark,
                                              height: 1.5))
                                ]),
                              ),
                              subtitle: Text(
                                '2210 St. Merry Church, New York, NY 10013, United States',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        top: 12.0,
                        end: 16.0,
                        child: FadedScaleAnimation(
                          CircleAvatar(
                            radius: 25.0,
                            backgroundColor: kMainColor,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: kWhiteColor,
                            ),
                          ),
                          durationInMilliseconds: 400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  // Container(
                  //   padding: EdgeInsets.all(20),
                  //   decoration: boxDecoration,
                  //     child: Column(
                  //       children: <Widget>[

                  //            Row(

                  //             children: [

                  //               RichText(
                  //                 text: TextSpan(children: [
                  //                   TextSpan(
                  //                     text: locale.courierType! + '\n',
                  //                     style: theme.textTheme.subtitle2!.copyWith(
                  //                         color: theme.hintColor.withOpacity(0.7)),
                  //                   ),
                  //                   TextSpan(
                  //                     text: locale.boxCourier,
                  //                     style: theme.textTheme.bodyText1!
                  //                         .copyWith(fontSize: 16),
                  //                   ),
                  //                 ]),
                  //               ),
                  //               Spacer(),
                  //               RichText(
                  //                 text: TextSpan(children: [
                  //                   TextSpan(
                  //                     text: locale.frangible! + '\n',
                  //                     style: theme.textTheme.subtitle2!.copyWith(
                  //                         color: theme.hintColor.withOpacity(0.7)),
                  //                   ),
                  //                   TextSpan(
                  //                     text: locale.yes,
                  //                     style: theme.textTheme.bodyText1!
                  //                         .copyWith(fontSize: 16),
                  //                   ),
                  //                 ]),
                  //               ),
                  //               SizedBox(width: 40),
                  //             ],
                  //           ),

                  //         SizedBox(height: 16),
                  //         Row(
                  //           children: [
                  //             RichText(
                  //               text: TextSpan(children: [
                  //                 TextSpan(
                  //                   text: locale.height! +
                  //                       ' ' +
                  //                       locale.width! +
                  //                       ' ' +
                  //                       locale.length! +
                  //                       '\n',
                  //                   style: theme.textTheme.subtitle2!.copyWith(
                  //                       color: theme.hintColor.withOpacity(0.7)),
                  //                 ),
                  //                 TextSpan(
                  //                   text: '60 x 75 x 124 (cm)',
                  //                   style: theme.textTheme.bodyText1!
                  //                       .copyWith(fontSize: 16),
                  //                 ),
                  //               ]),
                  //             ),
                  //             Spacer(),
                  //             RichText(
                  //               text: TextSpan(children: [
                  //                 TextSpan(
                  //                   text: locale.weight! + '\n',
                  //                   style: theme.textTheme.subtitle2!.copyWith(
                  //                       color: theme.hintColor.withOpacity(0.7)),
                  //                 ),
                  //                 TextSpan(
                  //                   text: '10 kg',
                  //                   style: theme.textTheme.bodyText1!
                  //                       .copyWith(fontSize: 16),
                  //                 ),
                  //               ]),
                  //             ),
                  //             SizedBox(width: 54),
                  //           ],
                  //         ),
                  //         SizedBox(height: 16),
                  //         RichText(
                  //           text: TextSpan(children: [
                  //             TextSpan(
                  //               text: locale.courierInfo! + '\n',
                  //               style: theme.textTheme.subtitle2!.copyWith(
                  //                   color: theme.hintColor.withOpacity(0.7)),
                  //             ),
                  //             TextSpan(
                  //               text: locale.comment4,
                  //               style: theme.textTheme.bodyText1!
                  //                   .copyWith(fontSize: 16),
                  //             ),
                  //           ]),
                  //         ),
                  //       ],
                  //     ),
                  //   ),

                  SizedBox(height: 10.0),
                  Container(
                      decoration: boxDecoration,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        title: Text(
                          locale.economyDelivery!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Text(locale.paymentViaCashonPickup!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: Color(0xffc2c2c2), fontSize: 11.7)),
                        trailing: Text(
                          '\$8.60',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: theme.primaryColorDark),
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
