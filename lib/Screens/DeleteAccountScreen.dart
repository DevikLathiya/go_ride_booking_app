import 'package:cabuser/Screens/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../Helper/GoRIdeConstant.dart';
import '../Helper/GoRideColor.dart';
import '../Helper/GoRideStringRes.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../service/AuthService1.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/app_common.dart';
import 'GoRideHomeScreen.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  DeleteAccountScreenState createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  AuthServices authService = AuthServices();

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
                  GoRideStringRes.DeleteAccount,
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
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.areYouSureYouWantPleaseReadAffect, style: primaryTextStyle()),
                            SizedBox(height: 16),
                            Text(language.account, style: boldTextStyle()),
                            SizedBox(height: 8),
                            Text(language.deletingAccountEmail, style: primaryTextStyle()),
                            SizedBox(height: 24),
                            Center(
                              child: AppButtonWidget(
                                text: language.deleteAccount,
                                textStyle: boldTextStyle(color: Colors.white),
                                color: Colors.red,
                                onTap: () async {
                                  await showConfirmDialogCustom(
                                    context,
                                    title: language.areYouSureYouWantDeleteAccount,
                                    dialogType: DialogType.DELETE,
                                    positiveText: language.yes,
                                    negativeText: language.no,
                                    onAccept: (c) async {
                                      if (sharedPref.getString(USER_EMAIL) == demoEmail) {
                                        toast(language.demoMsg);
                                      } else {
                                        await deleteAccount(context);
                                      }
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Observer(builder: (context) {
                        return Visibility(
                          visible: appStore.isLoading,
                          child: loaderWidget(),
                        );
                      }),
                    ],
                  );
                }),
              ]))),

    );
  }

  Future deleteAccount(BuildContext context) async {
    appStore.setLoading(true);
    await deleteUser().then((value) async {
      await userService.removeDocument(sharedPref.getString(UID)!).then((value) async {
        await authService.deleteUserFirebase().then((value) async {
          await logout(isDelete: true).then((value) {
            appStore.setLoading(false);
          });
        }).catchError((error) {
          appStore.setLoading(false);
          toast(error.toString());
        });
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }
}
