import 'dart:async';
import 'dart:developer';

import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:cabuser/utils/Constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Screens/GoRideSplashScreen.dart';
import 'package:cabuser/Screens/NoInternetScreen.dart';
import 'package:cabuser/language/AppLocalizations.dart';
import 'package:cabuser/main.dart';
import 'package:cabuser/model/LanguageDataModel.dart';
import 'package:cabuser/utils/Common.dart';
import 'package:cabuser/utils/Extensions/StringExtensions.dart';

import 'utils/Extensions/app_common.dart';

class GoRideMain extends StatefulWidget {
  const GoRideMain({Key? key}) : super(key: key);

  @override
  State<GoRideMain> createState() => _GoRideMainState();
}
bool isCurrentlyOnNoInternet = false;
class _GoRideMainState extends State<GoRideMain> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool next = false;

  @override
  void initState() {
    super.initState();
    next = sharedPref.getBool(IS_FIRST_TIME) ?? false;
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    connectivitySubscription.cancel();
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        launchScreen(navigatorKey.currentState!.overlay!.context, NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) => MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "GO RIDE",
      theme: ThemeData(
        fontFamily: 'salonfont',
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        primaryTextTheme:
        const TextTheme(headline6: TextStyle(color: GoRideColors.black)),
      ),
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child!);
        },
      home: GoRideSplashScreen() ,
      supportedLocales: LanguageDataModel.languageLocales(),
      localizationsDelegates: [
        AppLocalizations(),
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) => locale,
      locale: Locale(appStore.selectedLanguage.validate(value: default_Language)),
    ),);
  }
}
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}