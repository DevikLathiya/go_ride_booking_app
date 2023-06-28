import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Screens/Widget/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      Map req = {
        'old_password': oldPassController.text.trim(),
        'new_password': newPassController.text.trim(),
      };
      appStore.setLoading(true);

      await sharedPref.setString(USER_PASSWORD, newPassController.text.trim());

      await changePassword(req).then((value) {
        toast(value.message.toString());
        appStore.setLoading(false);

        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GoRideColors.yellow,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * .24,
            ),
            child: AppbarImageDesign(
              image: 'new_pass.svg',
              bottomPadding: 0,
              showBackBtn: true,
              onPress: () {
                Navigator.pop(context);
              },
            )),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: GoRideConstant.boxDecorationContainer(
                GoRideColors.white, false),
            child: Stack(
              children: [
                Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1,
                            top: MediaQuery.of(context).size.height * .05,
                            right: MediaQuery.of(context).size.width * .1,
                          ),
                          child: AppTextField(
                            controller: oldPassController,
                            textFieldType: TextFieldType.PASSWORD,
                            focus: oldPassFocus,
                            nextFocus: newPassFocus,
                            decoration: inputDecoration(context, label: language.oldPassword),
                            errorThisFieldRequired: language.thisFieldRequired,
                            errorMinimumPasswordLength: language.passwordInvalid,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1,
                            top: MediaQuery.of(context).size.height * .02,
                            right: MediaQuery.of(context).size.width * .1,
                          ),
                          child: AppTextField(
                            controller: newPassController,
                            textFieldType: TextFieldType.PASSWORD,
                            focus: newPassFocus,
                            nextFocus: confirmPassFocus,
                            decoration: inputDecoration(context, label: language.newPassword),
                            errorThisFieldRequired: language.thisFieldRequired,
                            errorMinimumPasswordLength: language.passwordInvalid,
                          ),
                        ),
                        SizedBox(height: 16),
                        AppTextField(
                          controller: confirmPassController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: confirmPassFocus,
                          decoration: inputDecoration(context, label: language.confirmPassword),
                          errorThisFieldRequired: language.thisFieldRequired,
                          errorMinimumPasswordLength: language.passwordInvalid,
                          validator: (val) {
                            if (val!.isEmpty) return language.thisFieldRequired;
                            if (val != newPassController.text) return language.passwordDoesNotMatch;
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (context) {
                    return Visibility(
                      visible: appStore.isLoading,
                      child: loaderWidget(),
                    );
                  },
                ),
              ],
            )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.save,
          onTap: () {
            if (sharedPref.getString(USER_EMAIL) == demoEmail) {
              toast(language.demoMsg);
            } else {
              submit();
            }
          },
        ),
      ),
    );

    //   Scaffold(
    //   appBar: AppBar(
    //     title: Text(language.changePassword, style: boldTextStyle(color: appTextPrimaryColorWhite)),
    //   ),
    //   body: Stack(
    //     children: [
    //       Form(
    //         key: formKey,
    //         child: SingleChildScrollView(
    //           padding: EdgeInsets.only(left: 16, top: 30, right: 16),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               AppTextField(
    //                 controller: oldPassController,
    //                 textFieldType: TextFieldType.PASSWORD,
    //                 focus: oldPassFocus,
    //                 nextFocus: newPassFocus,
    //                 decoration: inputDecoration(context, label: language.oldPassword),
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 errorMinimumPasswordLength: language.passwordInvalid,
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: newPassController,
    //                 textFieldType: TextFieldType.PASSWORD,
    //                 focus: newPassFocus,
    //                 nextFocus: confirmPassFocus,
    //                 decoration: inputDecoration(context, label: language.newPassword),
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 errorMinimumPasswordLength: language.passwordInvalid,
    //               ),
    //               SizedBox(height: 16),
    //               AppTextField(
    //                 controller: confirmPassController,
    //                 textFieldType: TextFieldType.PASSWORD,
    //                 focus: confirmPassFocus,
    //                 decoration: inputDecoration(context, label: language.confirmPassword),
    //                 errorThisFieldRequired: language.thisFieldRequired,
    //                 errorMinimumPasswordLength: language.passwordInvalid,
    //                 validator: (val) {
    //                   if (val!.isEmpty) return language.thisFieldRequired;
    //                   if (val != newPassController.text) return language.passwordDoesNotMatch;
    //                   return null;
    //                 },
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Observer(
    //         builder: (context) {
    //           return Visibility(
    //             visible: appStore.isLoading,
    //             child: loaderWidget(),
    //           );
    //         },
    //       ),
    //     ],
    //   ),
    //   bottomNavigationBar: Padding(
    //     padding: EdgeInsets.all(16),
    //     child: AppButtonWidget(
    //       text: language.save,
    //       onTap: () {
    //         if (sharedPref.getString(USER_EMAIL) == demoEmail) {
    //           toast(language.demoMsg);
    //         } else {
    //           submit();
    //         }
    //       },
    //     ),
    //   ),
    // );
  }
}
