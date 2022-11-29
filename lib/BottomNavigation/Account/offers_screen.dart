import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/Theme/style.dart';
import 'package:flutter/material.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: mediaQuery.size.height - mediaQuery.padding.vertical,
            child: Column(
              children: [
                Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(flex: 2),
                      Text(
                        "Offers",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headline5,
                      ),
                      Spacer(flex: 3),
                    ],
                  ),
                ),
                Spacer(),
                ClipRRect(
                  borderRadius: borderRadius,
                  child: Container(
                    height: mediaQuery.size.height * 0.9,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: borderRadius,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                boxShadow: [boxShadow],
                                borderRadius: BorderRadius.circular(10.0),
                                color: theme.backgroundColor,
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: FadedScaleAnimation(
                                    Icon(
                                      Icons.discount,
                                      color: kMainColor,
                                      size: 30,
                                    ),
                                    durationInMilliseconds: 400,
                                  ),
                                ),
                                title: Text(
                                  "Invite a friend and get 10% cashback on first ride",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Valid until: 10:00AM, 3rd Jan 2022",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            );
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
//      ),
    );
  }
}
