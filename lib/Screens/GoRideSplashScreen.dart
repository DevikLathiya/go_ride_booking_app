import 'dart:async';

import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:cabuser/Screens/Login/GoRideLoginScreen.dart';
import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cabuser/Helper/GORIdeSplashAnimation.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/GoRideWelcomeScreen.dart';
import 'package:octo_image/octo_image.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class GoRideSplashScreen extends StatefulWidget {
  const GoRideSplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GoRideSplashScreenState();
  }
}

class GoRideSplashScreenState extends State<GoRideSplashScreen>
    with SingleTickerProviderStateMixin {
  Size size = Size.zero;
  late AnimationController _controller;
  late GoRideSplashAnimation _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animations = GoRideSplashAnimation(_controller);
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });
    startTime();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    if (sharedPref.getBool(IS_FIRST_TIME) == false) {
      print("IS_FIRST_TIME : $IS_FIRST_TIME");
      launchScreen(context, GopRideWelcomeScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
    } else {
      if (sharedPref.getBool(IS_FIRST_TIME) == false) {
        launchScreen(context, GoRideLoginScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else {
       /* if (sharedPref.getString(CONTACT_NUMBER)!.validate().isEmptyOrNull) {
          toast("open edit profile screen");
          // launchScreen(context, EditProfileScreen(isGoogle: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else if (sharedPref.getString(UID).validate().isEmptyOrNull) {
          updateProfileUid().then((value) {
            launchScreen(context, GoRideHomeScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          });
        } else {
          launchScreen(context, GoRideHomeScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }*/
        launchScreen(context, GoRideHomeScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      }
    }
    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => GopRideWelcomeScreen(),
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        OctoImage(
          image: CachedNetworkImageProvider(
              "https://firebasestorage.googleapis.com/v0/b/smartkit-8e62c.appspot.com/o/goride%2Fsplash_background.png?alt=media&token=3589ea4f-d610-4dd2-9a0d-6655ac8d37b8"),
          placeholderBuilder: OctoPlaceholder.blurHash(
            "LEHV6nWB2yk8pyoJadR*.7kCMdnj",
          ),
          errorBuilder: OctoError.icon(color: Colors.black),
          fit: BoxFit.contain,
        ),
        SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
                painter: HolePainter(
                    color: GoRideColors.white,
                    holeSize: _animations.holeSize.value * size.width))),
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.5),
              child: SvgPicture.asset(
                  GoRideConstant.getSvgImagePath("appicon.svg")),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .01),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: const <TextSpan>[
                      TextSpan(
                          text: GoRideStringRes.go + "  ",
                          style: TextStyle(
                              color: GoRideColors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1.2)),
                      TextSpan(
                          text: GoRideStringRes.ride,
                          style: TextStyle(
                              color: GoRideColors.black, fontSize: 40)),
                    ],
                  ),
                )),
          ],
        ),
      ],
    ));
  }
}
