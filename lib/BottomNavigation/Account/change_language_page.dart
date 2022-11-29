import 'package:consumer/Components/custom_app_bar.dart';
import 'package:consumer/Locale/language_cubit.dart';
import 'package:consumer/Locale/locales.dart';
// import 'package:consumer/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangeLanguagePage extends StatefulWidget {
  final bool fromRoot;

  ChangeLanguagePage([this.fromRoot = false]);

  @override
  _ChangeLanguagePageState createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  late LanguageCubit _languageCubit;
  int? _selectedLanguage = -1;

  @override
  void initState() {
    super.initState();
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var theme = Theme.of(context);
    final List<String> _languages = [
      'English',
      'عربى',
      'français',
      'bahasa Indonesia',
      'português',
      'Español',
      'italiano',
      'Türk',
      'Kiswahili'
    ];
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        if (!widget.fromRoot) _selectedLanguage = getCurrentLanguage(locale);
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: mediaQuery.size.height - mediaQuery.padding.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacer(),
                    if (!widget.fromRoot) CustomAppBar(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '\n' + AppLocalizations.of(context)!.changeLanguage!,
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
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView.builder(
                          itemCount:
                              AppLocalizations.getSupportedLocales().length,
                          itemBuilder: (context, index) => RadioListTile(
                            activeColor: theme.primaryColor,
                            onChanged: (dynamic value) {
                              setState(() {
                                _selectedLanguage = value;
                              });
                              if (_selectedLanguage == 0) {
                                _languageCubit.selectLanguage('en');
                              } else if (_selectedLanguage == 1) {
                                _languageCubit.selectLanguage('ar');
                              } else if (_selectedLanguage == 2) {
                                _languageCubit.selectLanguage('fr');
                              } else if (_selectedLanguage == 3) {
                                _languageCubit.selectLanguage('id');
                              } else if (_selectedLanguage == 4) {
                                _languageCubit.selectLanguage('pt');
                              } else if (_selectedLanguage == 5) {
                                _languageCubit.selectLanguage('es');
                              } else if (_selectedLanguage == 6) {
                                _languageCubit.selectLanguage('it');
                              } else if (_selectedLanguage == 7) {
                                _languageCubit.selectLanguage('tr');
                              } else if (_selectedLanguage == 8) {
                                _languageCubit.selectLanguage('sw');
                              }
                              // Navigator.pushNamed(
                              //     context, PageRoutes.signInNavigator);
                            },
                            groupValue: _selectedLanguage,
                            value: index,
                            title: Text(_languages[index]),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int getCurrentLanguage(Locale locale) {
    if (locale == Locale('en'))
      return 0;
    else if (locale == Locale('ar'))
      return 1;
    else if (locale == Locale('fr'))
      return 2;
    else if (locale == Locale('id'))
      return 3;
    else if (locale == Locale('pt'))
      return 4;
    else if (locale == Locale('es'))
      return 5;
    else if (locale == Locale('it'))
      return 6;
    else if (locale == Locale('tr'))
      return 7;
    else if (locale == Locale('sw'))
      return 8;
    else
      return -1;
  }
}
