import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/GoRideDrawerHome.dart';
import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/Extensions/StringExtensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../main.dart';
import '../model/SettingModel.dart';
import '../utils/Common.dart';
import '../utils/images.dart';

class AboutScreen extends StatefulWidget {
  final SettingModel settingModel;

  AboutScreen({required this.settingModel});

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
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
                      GoRideStringRes.AboutUs,
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
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(ic_taxi_logo, height: 150, width: 150, fit: BoxFit.cover),
                            SizedBox(height: 16),
                            Text(mAppName, style: primaryTextStyle(size: 20)),
                            SizedBox(height: 8),
                            FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  return Text('v${snap.data!.version}', style: secondaryTextStyle());
                                }
                                return SizedBox();
                              },
                            ),
                            SizedBox(height: 16),
                            Text(widget.settingModel.siteDescription.validate(), style: secondaryTextStyle(), maxLines: 6, textAlign: TextAlign.justify, overflow: TextOverflow.visible),
                          ],
                        ),
                      );
                    }),
                  ]))),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              height: 120,
              child: Column(
                children: [
                  Text(language.lblFollowUs, style: boldTextStyle()),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      inkWellWidget(
                        onTap: () {
                          if (widget.settingModel.instagramUrl != null && widget.settingModel.instagramUrl!.isNotEmpty) {
                            launchUrl(Uri.parse(widget.settingModel.instagramUrl.validate()), mode: LaunchMode.externalApplication);
                          } else {
                            toast(language.txtURLEmpty);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_insta, height: 35, width: 35),
                        ),
                      ),
                      inkWellWidget(
                        onTap: () {
                          if (widget.settingModel.twitterUrl != null && widget.settingModel.twitterUrl!.isNotEmpty) {
                            launchUrl(Uri.parse(widget.settingModel.twitterUrl.validate()), mode: LaunchMode.externalApplication);
                          } else {
                            toast(language.txtURLEmpty);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_twitter, height: 35, width: 35),
                        ),
                      ),
                      inkWellWidget(
                        onTap: () {
                          if (widget.settingModel.linkedinUrl != null && widget.settingModel.linkedinUrl!.isNotEmpty) {
                            launchUrl(Uri.parse(widget.settingModel.linkedinUrl.validate()), mode: LaunchMode.externalApplication);
                          } else {
                            toast(language.txtURLEmpty);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_linked, height: 35, width: 35),
                        ),
                      ),
                      inkWellWidget(
                        onTap: () {
                          if (widget.settingModel.facebookUrl != null && widget.settingModel.facebookUrl!.isNotEmpty) {
                            launchUrl(Uri.parse(widget.settingModel.facebookUrl.validate()), mode: LaunchMode.externalApplication);
                          } else {
                            toast(language.txtURLEmpty);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(ic_facebook, height: 35, width: 35),
                        ),
                      ),
                      inkWellWidget(
                        onTap: () {
                          if (widget.settingModel.contactNumber != null && widget.settingModel.contactNumber!.isNotEmpty) {
                            launchUrl(Uri.parse('tel:${widget.settingModel.contactNumber.validate()}'), mode: LaunchMode.externalApplication);
                          } else {
                            toast(language.txtURLEmpty);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.call,
                            color: appStore.isDarkMode ? Colors.white : primaryColor,
                            size: 36,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  widget.settingModel.siteCopyright != null && widget.settingModel.siteCopyright!.isNotEmpty
                      ? Text(widget.settingModel.siteCopyright.validate(), style: secondaryTextStyle(), maxLines: 1)
                      : Text('Copyright' + " @${DateTime.now().year} meetmighty", style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
          ),

        )
    );



  }
}
