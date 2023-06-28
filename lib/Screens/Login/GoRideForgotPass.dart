// ignore_for_file: unnecessary_import, use_key_in_widget_constructors

import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_common.dart';
import '../Widget/AppBar.dart';
import 'GoRideOtpScreen.dart';

class GoRideForgotPass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GoRideForgotPassState();
  }
}

class GoRideForgotPassState extends State<GoRideForgotPass> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GoRideColors.yellow,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * .22,
            ),
            child: AppbarImageDesign(
              image: 'forgot_password.svg',
              bottomPadding: 0,
              showBackBtn: true,
              onPress: () {
                Navigator.pop(context);
              },
            )),
        body: Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: GoRideConstant.boxDecorationContainer(
                    GoRideColors.white, false),
                child: Form(
                  key: formKey,
                  child: Column(children: [
                    welcomeText(),
                    welcomeSubText(),
                    emailEnter(),
                    SizedBox(
                      height: 20,
                    ),
                    resetPwdBtn()
                  ]),
                )),
            Observer(
              builder: (context) {
                return Visibility(
                  visible: appStore.isLoading,
                  child: loaderWidget(),
                );
              },
            )
          ],
        ));
  }

  Widget welcomeText() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .1,
            top: MediaQuery.of(context).size.height * .08),
        child: Text(
          GoRideStringRes.forgotPwd,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        ));
  }

  Widget welcomeSubText() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .1,
            right: MediaQuery.of(context).size.width * .05),
        child: Text(
          GoRideStringRes.resetPwd,
          style: TextStyle(fontSize: 14, color: Color(0xffa2a2a2)),
        ));
  }

  Widget emailEnter() {
    return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .02,
          top: MediaQuery.of(context).size.height * .02,
          right: MediaQuery.of(context).size.width * .04,
        ),
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .1,
          top: MediaQuery.of(context).size.height * .02,
          right: MediaQuery.of(context).size.width * .08,
        ),
        child: TextFormField(
          controller: forgotEmailController,
          cursorColor: Color(0xffa2a2a2),
          decoration: InputDecoration(
            prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.email_outlined,
                  color: Color(0xff212121).withOpacity(0.7),
                )),
            hintText: GoRideStringRes.hintEmail,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff707070)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff707070)),
            ),
          ),
          validator: (value) => value!.validateEmail2(),
          keyboardType: TextInputType.emailAddress,
        ));
  }

  Widget resetPwdBtn() {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: () {
          submit();
        },
        child: Text(
          GoRideStringRes.resetBtn,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: GoRideColors.white,
              fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(310, 50),
          shadowColor: Color(0x33212121),
          elevation: 6,
          primary: GoRideColors.black,
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      Map req = {
        'email': forgotEmailController.text.trim(),
      };
      appStore.setLoading(true);

      await forgotPassword(req).then((value) {
        toast(value.message!.validate());

        appStore.setLoading(false);

        Navigator.pop(context);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => GoRideOtpScreen(),
        //   ),
        // );
      }).catchError((error) {
        appStore.setLoading(false);

        toast(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
}
