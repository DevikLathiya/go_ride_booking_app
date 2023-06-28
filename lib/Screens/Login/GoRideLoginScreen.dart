import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/Widget/animatedFadeAnimation.dart';
import 'package:cabuser/Screens/Widget/slideAnimation.dart';
import '../../components/OTPDialog.dart';
import '../../main.dart';
import '../../model/LoginResponse.dart';
import '../../network/RestApis.dart';
import '../../service/AuthService.dart';
import '../../service/AuthService1.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../GoRideDrawerHome.dart';
import '../GoRideHomeScreen.dart';
import '../TermsConditionScreen.dart';
import '../Widget/AppBar.dart';
import 'GoRideForgotPass.dart';
import 'GoRideSignUpScreen.dart';

class GoRideLoginScreen extends StatefulWidget {
  const GoRideLoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GoRideLoginScreenState();
  }
}

late UserModel _userModel;

class GoRideLoginScreenState extends State<GoRideLoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthServices authService = AuthServices();

  GoogleAuthServices googleAuthService = GoogleAuthServices();

  bool checkBoxValue = true;
  AnimationController? _animationController;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool isPasswordVisible = false;

  String? privacyPolicy;
  String? termsCondition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    init();
  }

  void init() async {
    appSetting();
    if (sharedPref.getString(PLAYER_ID).validate().isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
      });
    }
    checkBoxValue = sharedPref.getBool(REMEMBER_ME) ?? false;
    if (checkBoxValue) {
      emailController.text = sharedPref.getString(USER_EMAIL).validate();
      passController.text = sharedPref.getString(USER_PASSWORD).validate();
    }
  }

  Future<void> appSetting() async {
    await getAppSettingApi().then((value) {
      if (value.privacyPolicyModel!.value != null)
        privacyPolicy = value.privacyPolicyModel!.value;
      if (value.termsCondition!.value != null)
        termsCondition = value.termsCondition!.value;
    }).catchError((error) {
      log(error.toString());
    });
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
            image: 'login.svg',
            bottomPadding: 20,
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
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AnimatedFadeAnimation(1, welcomeText()),
                      AnimatedFadeAnimation(1, welcomeSubText()),
                      AnimatedFadeAnimation(1.3, emailEnter()),
                      AnimatedFadeAnimation(1.6, pwdEnter()),
                      AnimatedFadeAnimation(1.9, rememberOrForgotPwd()),
                      AnimatedFadeAnimation(1.12, loginBtn()),
                      AnimatedFadeAnimation(1.15, creteAccountBtn()),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .045,
                      ),
                      AnimatedFadeAnimation(
                          1.18,
                          Text(
                            GoRideStringRes.socialMedia,
                            style: TextStyle(
                                fontSize: 12, color: Color(0xff7b859a)),
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .025,
                      ),
                      socialMedia(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .055,
                      ),
                      AnimatedFadeAnimation(1.24, termText())
                    ],
                  ),
                ),
              )),
          Observer(
            builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget welcomeText() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .1,
            top: MediaQuery.of(context).size.height * .07),
        child: Text(
          GoRideStringRes.welcomeBack,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
        ));
  }

  Widget welcomeSubText() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .1,
        ),
        child: Text(
          GoRideStringRes.welSub,
          style: TextStyle(fontSize: 14, color: Color(0xffa2a2a2)),
        ));
  }

  Widget emailEnter() {
    return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .1,
          top: MediaQuery.of(context).size.height * .03,
          right: MediaQuery.of(context).size.width * .1,
        ),
        // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*.1,top:MediaQuery.of(context).size.height*.03,right:MediaQuery.of(context).size.width*.08,),
        child: TextFormField(
          focusNode: emailFocus,
          autofocus: false,
          controller: emailController,
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
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) => value!.validateEmail2(),
        ));
  }

  Widget pwdEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        top: MediaQuery.of(context).size.height * .04,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
        focusNode: passFocus,
        autofocus: false,
        obscureText: !isPasswordVisible,
        controller: passController,
        cursorColor: Color(0xffa2a2a2),
        obscuringCharacter: '●',
        decoration: InputDecoration(
          prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SvgPicture.asset(
                GoRideConstant.getSvgImagePath("pass_icon.svg"),
                fit: BoxFit.scaleDown,
              )),
          // suffixIcon: SvgPicture.asset(
          //   GoRideConstant.getSvgImagePath("eye_icon.svg"),
          //   fit: BoxFit.scaleDown,
          // ),
          suffixIcon: GestureDetector(
            child: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFFA2A2A2),
            ),
            onTap: () {
              isPasswordVisible = !isPasswordVisible;

              setState(() {});
            },
          ),
          hintText: "●●●●●●●",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff707070)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff707070)),
          ),
        ),
        validator: (value) => value!.validatePassword2(),
      ),
    );
  }

  Widget rememberOrForgotPwd() {
    return Row(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .07,
              top: MediaQuery.of(context).size.height * .02),
          child: Row(
            children: [
              Checkbox(
                  value: checkBoxValue,
                  activeColor: GoRideColors.yellow,
                  onChanged: (bool? newValue) {
                    setState(() {
                      checkBoxValue = newValue!;
                    });
                  }),
              Text(
                GoRideStringRes.rememberMe,
                style: TextStyle(color: Color(0xff7b859a), fontSize: 14),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => GoRideForgotPass(),
              ),
            );
          },
          child: Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .18,
                  top: MediaQuery.of(context).size.height * .012),
              child: Text(
                GoRideStringRes.forgotPwd + "?",
                style: TextStyle(color: Color(0xff7b859a), fontSize: 14),
              )),
        )
      ],
    );
  }

  Widget loginBtn() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .017),
      child: ElevatedButton(
        onPressed: () {
          xOffset = 0;
          yOffset = 0;
          scaleFactor = 1;
          isDrawerOpen = false;

          logIn();

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => HomePage(),
          //   ),
          // );
        },
        child: Text(
          GoRideStringRes.loginBtn,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: GoRideColors.black,
              fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(310, 50),
          primary: GoRideColors.yellow,
        ),
      ),
    );
  }

  Widget creteAccountBtn() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .02),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => GoRideSignUpScreen(),
            ),
          );
        },
        child: Text(
          GoRideStringRes.createAcc,
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

  Widget socialMedia() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlideAnimation(
            position: 5,
            itemCount: 15,
            slideDirection: SlideDirection.fromLeft,
            animationController: _animationController,
            child: GestureDetector(
              onTap: () {
                xOffset = 0;
                yOffset = 0;
                scaleFactor = 1;
                isDrawerOpen = false;
                googleSignIn();
              },
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: GoRideColors.red,
                  child: SvgPicture.asset(
                    GoRideConstant.getSvgImagePath("google.svg"),
                  )),
            )),
        SizedBox(
          width: 10,
        ),
        SlideAnimation(
            position: 5,
            itemCount: 15,
            slideDirection: SlideDirection.fromBottom,
            animationController: _animationController,
            child: GestureDetector(
                onTap: () {
                  xOffset = 0;
                  yOffset = 0;
                  scaleFactor = 1;
                  isDrawerOpen = false;

                  phoneLogin();
                },
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xff3379e4),
                    child: Icon(
                      FontAwesomeIcons.mobileAlt,
                      color: Colors.white,
                    )))),
        // SizedBox(
        //   width: 10,
        // ),
        // SlideAnimation(
        //     position: 5,
        //     itemCount: 15,
        //     slideDirection: SlideDirection.fromRight,
        //     animationController: _animationController,
        //     child: GestureDetector(
        //       onTap: () {
        //         xOffset = 0;
        //         yOffset = 0;
        //         scaleFactor = 1;
        //         isDrawerOpen = false;
        //         Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //             builder: (BuildContext context) => HomePage(),
        //           ),
        //         );
        //       },
        //       child: CircleAvatar(
        //           radius: 20,
        //           backgroundColor: Color(0xff38a1f3),
        //           child: SvgPicture.asset(
        //             GoRideConstant.getSvgImagePath("twitter.svg"),
        //           )),
        //     ))
      ],
    );
  }

  Widget termText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: GoRideStringRes.agree + " ",
              style: TextStyle(color: Color(0xffa2a2a2), fontSize: 12)),
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  hideKeyboard(context);
                  if (privacyPolicy != null && privacyPolicy!.isNotEmpty) {
                    launchScreen(
                        context,
                        TermsConditionScreen(
                            title: language.privacyPolicy,
                            subtitle: privacyPolicy),
                        pageRouteAnimation: PageRouteAnimation.Slide);
                  } else {
                    toast(language.txtURLEmpty);
                  }
                },
              text: GoRideStringRes.term,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff1f59b6),
                  fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> logIn() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // if (isAcceptedTc) {
      appStore.setLoading(true);

      Map req = {
        'email': emailController.text.trim(),
        'password': passController.text.trim(),
        "player_id": sharedPref.getString(PLAYER_ID)!.validate(),
        'user_type': RIDER,
      };

      if (checkBoxValue) {
        await sharedPref.setBool(REMEMBER_ME, checkBoxValue);
        await sharedPref.setString(USER_EMAIL, emailController.text);
        await sharedPref.setString(USER_PASSWORD, passController.text);
      }

      await logInApi(req).then((value) {
        _userModel = value.data!;

        _auth.signInWithEmailAndPassword(
                email: emailController.text, password: passController.text)
            .then((value) {
          sharedPref.setString(UID, value.user!.uid);
          // sharedPref.setBool(IS_FIRST_TIME,true);
          updateProfileUid();
          launchScreen(context, GoRideHomeScreen(),
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        }).catchError((e) {
          if (e.toString().contains('user-not-found')) {
            authService.signUpWithEmailPassword(
              context,
              mobileNumber: _userModel.contactNumber,
              email: _userModel.email,
              fName: _userModel.firstName,
              lName: _userModel.lastName,
              userName: _userModel.username,
              password: passController.text,
              userType: RIDER,
            );
          } else {
            launchScreen(context, GoRideHomeScreen(),
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          }
          //toast(e.toString());
          log(e.toString());
        });
        appStore.setLoading(false);
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });

      // } else {
      //   toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
      // }
    }
  }

  void googleSignIn() async {
    hideKeyboard(context);
    appStore.setLoading(true);

    await googleAuthService.signInWithGoogle(context).then((value) async {
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      print(e.toString());
    });
  }

  void phoneLogin() async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          content: OTPDialog(),
        );
      },
    );
  }
}
