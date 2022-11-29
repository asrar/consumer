import 'dart:io';

import 'package:consumer/Pages/third.dart';
import 'package:consumer/Theme/colors.dart';
import 'package:consumer/firebase_options.dart';
import 'package:consumer/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Locale/language_cubit.dart';
import 'Locale/locales.dart';
import 'Theme/style.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message FROM MAIN DART");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: SystemUiOverlay.values,
  );
  runApp(
    Phoenix(
      child: BlocProvider<LanguageCubit>(
        create: (context) => LanguageCubit(),
        child: MyApp(homeScreen: Splash()), //MyApp()
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  Widget? homeScreen;

  MyApp({this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) => MaterialApp(
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.getSupportedLocales(),
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        locale: locale,
        home: homeScreen,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
