import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Screens/GoRideDrawerHome.dart';
import 'package:cabuser/Screens/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../Helper/GoRIdeConstant.dart';
import '../Helper/GoRideStringRes.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_common.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';
import 'GoRideHomeScreen.dart';

class LanguageScreen extends StatefulWidget {
  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingScreen()));
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
                  GoRideStringRes.Language,
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
          padding: EdgeInsets.only(top: 30),
          decoration: GoRideConstant.boxDecorationContainer(
              GoRideColors.white, false),
          child: DefaultTabController(
              length: 3,
              child: ListView(
                children: List.generate(localeLanguageList.length, (index) {
                  LanguageDataModel data = localeLanguageList[index];
                  return inkWellWidget(
                    onTap: () async {
                      await sharedPref.setString(SELECTED_LANGUAGE_CODE, data.languageCode!);
                      selectedLanguageDataModel = data;
                      appStore.setLanguage(data.languageCode!, context: context);
                      setState(() {});
                      LiveStream().emit(CHANGE_LANGUAGE);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Image.asset("assets/${data.flag.validate()}", width: 34),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data.name.validate()}', style: boldTextStyle()),
                                SizedBox(height: 8),
                                Text('${data.subTitle.validate()}', style: secondaryTextStyle()),
                              ],
                            ),
                          ),
                          if ((sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? default_Language) == data.languageCode) Icon(Icons.check_circle, color: primaryColor),
                        ],
                      ),
                    ),
                  );
                }),
              ))),

    );
  }
}
