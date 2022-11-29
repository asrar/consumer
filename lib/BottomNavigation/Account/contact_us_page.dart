import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/Components/continue_button.dart';
import 'package:consumer/Components/custom_app_bar.dart';
import 'package:consumer/Components/entry_field.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContactUsBody();
  }
}

class ContactUsBody extends StatefulWidget {
  @override
  _ContactUsBodyState createState() => _ContactUsBodyState();
}

class _ContactUsBodyState extends State<ContactUsBody> {
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
                  CustomAppBar(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      '\n' + locale.contactUs!,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                  Spacer(flex: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35.0),
                    ),
                    child: Container(
                      height: mediaQuery.size.height * 0.77,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Spacer(flex: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.email,
                                color: Color(0xFFF7423A),
                              ),
                              Text("codedayy@gmail.com",
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                  )),
                              Icon(
                                Icons.phone,
                                color: Color(0xFFF7423A),
                              ),
                              Text("+91-85423687",
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              '\n' + locale.feedbackText!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: theme.primaryColorDark),
                            ),
                          ),
                          Spacer(),
                          EntryField(
                            label: locale.fullName,
                            hint: locale.enterFullName,
                            textCapitalization: TextCapitalization.words,
                          ),
                          EntryField(
                            label: locale.phoneText,
                            hint: locale.phoneHint,
                            keyboardType: TextInputType.number,
                          ),
                          EntryField(
                            label: locale.yourMessage,
                            hint: locale.entermsg,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          Spacer(flex: 2),
                          CustomButton(
                            text: locale.sendmsg,
                            radius: BorderRadius.only(
                                topLeft: Radius.circular(35.0)),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
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
