import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/AboutScreen.dart';
import 'package:cabuser/Screens/ChangePasswordScreen.dart';
import 'package:cabuser/Screens/DeleteAccountScreen.dart';
import 'package:cabuser/Screens/GoRideDrawerHome.dart';
import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:cabuser/Screens/LanguageScreen.dart';
import 'package:cabuser/Screens/Profile/GoRIdeNewPwd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../model/SettingModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';

import 'TermsConditionScreen.dart';

class SettingScreen extends StatefulWidget {
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  SettingModel settingModel = SettingModel();
  String? privacyPolicy;
  String? termsCondition;
  String? mHelpAndSupport;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await getAppSetting().then((value) {
      if (value.settingModel!.helpSupportUrl != null) mHelpAndSupport = value.settingModel!.helpSupportUrl!;
      settingModel = value.settingModel!;
      if (value.privacyPolicyModel!.value != null) privacyPolicy = value.privacyPolicyModel!.value!;
      if (value.termsCondition!.value != null) termsCondition = value.termsCondition!.value!;
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          xOffset = 0;
          yOffset = 0;
          scaleFactor = 1;
          isDrawerOpen = false;

          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          ) as Future<bool>;
        },
        child: Scaffold(
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
                                  builder: (context) => HomePage()));
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
                      GoRideStringRes.Setting,
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
                  child: Column(children: [
                    Observer(builder: (context) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Visibility(
                              visible: sharedPref.getString(LOGIN_TYPE) != 'mobile' && sharedPref.getString(LOGIN_TYPE) != LoginTypeGoogle && sharedPref.getString(LOGIN_TYPE) != null,
                              child: settingItemWidget(Icons.lock_outline, language.changePassword, () {
                                launchScreen(context, GoRideNewPwd(), pageRouteAnimation: PageRouteAnimation.Slide);
                              }),
                            ),
                            settingItemWidget(Icons.language, language.language, () {
                              launchScreen(context, LanguageScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                            settingItemWidget(Icons.assignment_outlined, language.privacyPolicy, () {
                              launchScreen(context, TermsConditionScreen(title: language.privacyPolicy, subtitle: privacyPolicy), pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                            settingItemWidget(Icons.help_outline, language.helpSupport, () {
                              if (mHelpAndSupport != null) {
                                launchUrl(Uri.parse(mHelpAndSupport!));
                              } else {
                                toast(language.txtURLEmpty);
                              }
                            }),
                            settingItemWidget(Icons.assignment_outlined, language.termsConditions, () {
                              if (termsCondition != null) {
                                launchScreen(context, TermsConditionScreen(title: language.termsConditions, subtitle: termsCondition), pageRouteAnimation: PageRouteAnimation.Slide);
                              } else {
                                toast(language.txtURLEmpty);
                              }
                            }),
                            settingItemWidget(
                              Icons.info_outline,
                              language.aboutUs,
                                  () {
                                launchScreen(context, AboutScreen(settingModel: settingModel), pageRouteAnimation: PageRouteAnimation.Slide);
                              },
                            ),
                            settingItemWidget(Icons.delete_outline, language.deleteAccount, () {
                              launchScreen(context, DeleteAccountScreen(), pageRouteAnimation: PageRouteAnimation.Slide);
                            }, isLast: true),
                          ],
                        ),
                      );
                    }),
                  ]))),

        )
    );
  }

  Widget settingItemWidget(IconData icon, String title, Function() onTap, {bool isLast = false, IconData? suffixIcon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 16, right: 16),
          leading: Icon(icon, size: 24, color: primaryColor),
          title: Text(title, style: primaryTextStyle()),
          trailing: suffixIcon != null ? Icon(suffixIcon, color: Colors.green) : Icon(Icons.navigate_next, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 0)
      ],
    );
  }
}
