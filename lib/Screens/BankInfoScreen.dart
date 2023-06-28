import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/GoRideDrawerHome.dart';
import 'package:cabuser/Screens/GoRideHomeScreen.dart';
import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../model/UserDetailModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class BankInfoScreen extends StatefulWidget {
  @override
  BankInfoScreenState createState() => BankInfoScreenState();
}

class BankInfoScreenState extends State<BankInfoScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();

  UserBankAccount? bankDetail;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      if (value.data!.userBankAccount != null) {
        bankDetail = value.data!.userBankAccount!;
        bankNameController.text = bankDetail!.bankName.validate();
        bankCodeController.text = bankDetail!.bankCode.validate();
        accountHolderNameController.text = bankDetail!.accountHolderName.validate();
        accountNumberController.text = bankDetail!.accountNumber.validate();
        appStore.setLoading(false);
        setState(() {});
      }
      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> updateBankInfo() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      updateBankDetail(
        accountName: accountHolderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        bankCode: bankCodeController.text.trim(),
        bankName: bankNameController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);

        Navigator.pop(context,true);
        toast(language.bankInfoUpdated);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
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
                      GoRideStringRes.MyBankinfo,
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
                      return Form(
                        key: formKey,
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  AppTextField(
                                    controller: bankNameController,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: inputDecoration(context, label: language.bankName),
                                  ),
                                  SizedBox(height: 16),
                                  AppTextField(
                                    controller: bankCodeController,
                                    textFieldType: TextFieldType.NAME,
                                    errorThisFieldRequired: language.thisFieldRequired,
                                    decoration: inputDecoration(context, label: language.bankCode),
                                  ),
                                  SizedBox(height: 16),
                                  AppTextField(
                                    controller: accountHolderNameController,
                                    textFieldType: TextFieldType.NAME,
                                    errorThisFieldRequired: language.thisFieldRequired,
                                    decoration: inputDecoration(context, label: language.accountHolderName),
                                  ),
                                  SizedBox(height: 16),
                                  AppTextField(
                                    controller: accountNumberController,
                                    textFieldType: TextFieldType.PHONE,
                                    errorThisFieldRequired: language.thisFieldRequired,
                                    decoration: inputDecoration(context, label: language.accountNumber),
                                  ),
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
                        ),
                      );
                    }),
                  ]))),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(16),
            child: AppButtonWidget(
              text: bankDetail != null ? language.updateBankDetail : language.addBankDetail,
              color: primaryColor,
              textStyle: boldTextStyle(color: Colors.white),
              onTap: () {
                updateBankInfo();
              },
            ),
          ),

        )
    );

    //   Scaffold(
    //   appBar: AppBar(
    //     title: Text(language.bankInfo, style: boldTextStyle(color: Colors.white)),
    //   ),
    //   body: Form(
    //     key: formKey,
    //     child: Stack(
    //       children: [
    //         SingleChildScrollView(
    //           padding: EdgeInsets.all(16),
    //           child: Column(
    //             children: [
    //               AppTextField(
    //                 controller: bankNameController,
    //                 textFieldType: TextFieldType.NAME,
    //                 decoration: inputDecoration(context, label: language.bankName),
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: bankCodeController,
    //                 textFieldType: TextFieldType.NAME,
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.bankCode),
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: accountHolderNameController,
    //                 textFieldType: TextFieldType.NAME,
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.accountHolderName),
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: accountNumberController,
    //                 textFieldType: TextFieldType.PHONE,
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 decoration: inputDecoration(context, label: language.accountNumber),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Observer(builder: (context) {
    //           return Visibility(
    //             visible: appStore.isLoading,
    //             child: loaderWidget(),
    //           );
    //         }),
    //       ],
    //     ),
    //   ),
    //   bottomNavigationBar: Padding(
    //     padding: EdgeInsets.all(16),
    //     child: AppButtonWidget(
    //       text: bankDetail != null ? language.updateBankDetail : language.addBankDetail,
    //       color: primaryColor,
    //       textStyle: boldTextStyle(color: Colors.white),
    //       onTap: () {
    //         updateBankInfo();
    //       },
    //     ),
    //   ),
    // );
  }
}
