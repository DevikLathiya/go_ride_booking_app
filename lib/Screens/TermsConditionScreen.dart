import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/GoRideDrawerHome.dart';
import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../utils/Colors.dart';
import '../utils/Extensions/app_common.dart';

class TermsConditionScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;

  TermsConditionScreen({this.title, this.subtitle});

  @override
  TermsConditionScreenState createState() => TermsConditionScreenState();
}

class TermsConditionScreenState extends State<TermsConditionScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRideColors.yellow,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * .15,
        ),
        child: Container(
            height: MediaQuery.of(context).size.height * .15,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .02),
            child: Row(children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    top: MediaQuery.of(context).size.height * .05),
                child: CircleAvatar(
                  radius: 15,
                  child: FloatingActionButton(
                    onPressed: () {
                      xOffset = 0;
                      yOffset = 0;
                      scaleFactor = 1;
                      isDrawerOpen = false;
                      Navigator.pop(context);
                    },
                    mini: true,
                    backgroundColor: GoRideColors.white,
                    elevation: 3,
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: GoRideColors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .27,
              ),
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .05,
                ),
                child: Text(
                  widget.title.toString(),
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              )
            ])),

        // PreferredSizeAppBar(title: GoRideStringRes.MyTrips,)
      ),
      body:Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 35,left: 5,right: 5),
          decoration: GoRideConstant.boxDecorationContainer(
              GoRideColors.white, false),
          child: DefaultTabController(
              length: 3,
              child: SingleChildScrollView(
                child: Column(children: [
                  Observer(builder: (context) {
                    return HtmlWidget("${widget.subtitle}");
                  }),
                ]),
              ))),

    );


  }
}
