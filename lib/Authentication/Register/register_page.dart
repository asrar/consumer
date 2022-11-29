import 'package:animation_wrappers/animation_wrappers.dart';
// import 'package:consumer/Authentication/signin_navigator.dart';
import 'package:consumer/Components/continue_button.dart';
import 'package:consumer/Components/custom_app_bar.dart';
import 'package:consumer/Components/entry_field.dart';
import 'package:consumer/Locale/locales.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RegisterBody();
  }
}

class RegisterBody extends StatefulWidget {
  @override
  _RegisterBodyState createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
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
                  CustomAppBar(title: locale.registerText),
                  new Container(
                      width: 81.0,
                      height: 81.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                "https://i.picsum.photos/id/1005/5760/3840.jpg?hmac=2acSJCOwz9q_dKtDZdSB-OIK1HUcwBeXco_RMMTUgfY")),
                      )),
                  Container(
                    height: mediaQuery.size.height * 0.8,
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
                        EntryField(
                          label: locale.nameText,
                          hint: locale.nameHint,
                          textCapitalization: TextCapitalization.words,
                        ),
                        EntryField(
                          label: locale.emailText,
                          hint: locale.emailHint,
                        ),
                        EntryField(
                          suffixIcon: Icons.arrow_drop_down,
                          label: locale.countryText,
                          hint: locale.selectCountryFromList,
                          readOnly: true,
                        ),
                        EntryField(
                          label: locale.phoneText,
                          hint: locale.phoneHint,
                        ),
                        Spacer(flex: 2),
                        CustomButton(
                          radius: BorderRadius.only(
                            topLeft: Radius.circular(35.0),
                          ),
                          // onPressed: () => Navigator.pushNamed(
                          //     context, SignInRoutes.verification),
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
