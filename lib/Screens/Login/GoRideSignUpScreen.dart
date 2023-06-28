import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/Widget/animatedFadeAnimation.dart';
import 'package:cabuser/Screens/Widget/slideAnimation.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../service/AuthService1.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../GoRideDrawerHome.dart';
import '../GoRideHomeScreen.dart';
import '../Widget/AppBar.dart';

class GoRideSignUpScreen extends StatefulWidget {
  final bool socialLogin;
  final String? userName;
  final bool isOtp;
  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;

  GoRideSignUpScreen(
      {super.key,
      this.socialLogin = false,
      this.userName,
      this.isOtp = false,
      this.countryCode,
      this.privacyPolicyUrl,
      this.termsConditionUrl});

  @override
  State<StatefulWidget> createState() {
    return GoRideSignUpScreenState();
  }
}

class GoRideSignUpScreenState extends State<GoRideSignUpScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();
  String countryCode = defaultCountryCode;

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = true;
  bool isAcceptedTc = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    init();
  }

  void init() async {
    if (sharedPref.getString(PLAYER_ID)!.validate().isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .003),
              decoration: GoRideConstant.boxDecorationContainer(
                  GoRideColors.white, false),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(children: [
                    welcomeText(),
                    welcomeSubText(),
                    firstNameEnter(),
                    lastNameEnter(),
                    userNameEnter(),
                    emailEnter(),
                    phoneNoEnter(),
                    pwdEnter(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .02,
                    ),
                    creteAccountBtn(),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * .045,
                    // ),
                    // Text(
                    //   GoRideStringRes.socialMedia,
                    //   style: TextStyle(fontSize: 12, color: Color(0xff7b859a)),
                    // ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * .025,
                    // ),
                    // socialMedia(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .045,
                    ),
                    termText(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .01,
                    ),
                  ]),
                ),
              )),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
    );
  }

  Widget welcomeText() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromLeft,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * .1,
                top: MediaQuery.of(context).size.height * .07),
            child: Text(
              GoRideStringRes.signUp,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
            )));
  }

  Widget welcomeSubText() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromLeft,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
            ),
            child: Text(
              GoRideStringRes.signUpSub,
              style: TextStyle(fontSize: 14, color: Color(0xffa2a2a2)),
            )));
  }

  Widget firstNameEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
              top: MediaQuery.of(context).size.height * .03,
              right: MediaQuery.of(context).size.width * .1,
            ),
            child: TextFormField(
              controller: firstController,
              focusNode: firstNameFocus,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value!.validateUserName(),
              cursorColor: Color(0xffa2a2a2),
              decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.person,
                      color: Color(0xff212121).withOpacity(0.7),
                    )),
                hintText: "First Name",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              ),
            )));
  }

  Widget lastNameEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
              top: MediaQuery.of(context).size.height * .03,
              right: MediaQuery.of(context).size.width * .1,
            ),
            child: TextFormField(
              controller: lastNameController,
              focusNode: lastNameFocus,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value!.validateUserName(),
              cursorColor: Color(0xffa2a2a2),
              decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.person,
                      color: Color(0xff212121).withOpacity(0.7),
                    )),
                hintText: "Last Name",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              ),
            )));
  }

  Widget userNameEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
              top: MediaQuery.of(context).size.height * .03,
              right: MediaQuery.of(context).size.width * .1,
            ),
            child: TextFormField(
              controller: userNameController,
              focusNode: userNameFocus,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value!.validateUserName(),
              cursorColor: Color(0xffa2a2a2),
              decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.person,
                      color: Color(0xff212121).withOpacity(0.7),
                    )),
                hintText: "User Name",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              ),
            )));
  }

  Widget emailEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
              top: MediaQuery.of(context).size.height * .03,
              right: MediaQuery.of(context).size.width * .1,
            ),
            child: TextFormField(
              controller: emailController,
              focusNode: emailFocus,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value!.validateEmail2(),
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
            )));
  }

  Widget phoneNoEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromLeft,
        animationController: _animationController,
        child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1,
              top: MediaQuery.of(context).size.height * .03,
              right: MediaQuery.of(context).size.width * .1,
            ),
            child: TextFormField(
              controller: phoneController,
              focusNode: phoneFocus,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: (value) => value!.validatePhone2(),
              cursorColor: Color(0xffa2a2a2),
              decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.call_outlined,
                      color: Color(0xff212121).withOpacity(0.7),
                    )),
                hintText: "0123456789",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              ),
            )));
  }

  Widget pwdEnter() {
    return SlideAnimation(
        position: 3,
        itemCount: 10,
        slideDirection: SlideDirection.fromLeft,
        animationController: _animationController,
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .1,
            top: MediaQuery.of(context).size.height * .03,
            right: MediaQuery.of(context).size.width * .1,
          ),
          child: TextFormField(
              controller: passController,
              focusNode: passFocus,
              autofocus: false,
              textInputAction: TextInputAction.done,
              validator: (value) => value!.validatePassword2(),
              obscureText: true,
              cursorColor: Color(0xffa2a2a2),
              obscuringCharacter: '●',
              decoration: InputDecoration(
                prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SvgPicture.asset(
                      GoRideConstant.getSvgImagePath("pass_icon.svg"),
                      fit: BoxFit.scaleDown,
                    )),
                suffixIcon: SvgPicture.asset(
                  GoRideConstant.getSvgImagePath("eye_icon.svg"),
                  fit: BoxFit.scaleDown,
                ),
                hintText: "●●●●●●●",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              )),
        ));
  }

  Widget creteAccountBtn() {
    return AnimatedFadeAnimation(
        2.5,
        Container(
          padding: EdgeInsets.only(top: 15),
          child: ElevatedButton(
            onPressed: () {
              xOffset = 0;
              yOffset = 0;
              scaleFactor = 1;
              isDrawerOpen = false;
              register();
            },
            child: Text(
              GoRideStringRes.createAcc,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: GoRideColors.white,
                  fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(315, 50),
              shadowColor: Color(0x33212121),
              elevation: 6,
              primary: GoRideColors.black,
            ),
          ),
        ));
  }

  Widget termText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: const <TextSpan>[
          TextSpan(
              text: GoRideStringRes.agree + " ",
              style: TextStyle(color: Color(0xffa2a2a2), fontSize: 12)),
          TextSpan(
              text: GoRideStringRes.term,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff1f59b6),
                  fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      if (isAcceptedTc) {
        appStore.setLoading(true);
        Map req = {
          'first_name': firstController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'username': widget.socialLogin
              ? widget.userName
              : userNameController.text.trim(),
          'email': emailController.text.trim(),
          "user_type": "rider",
          "contact_number": widget.socialLogin
              ? '${widget.countryCode}${widget.userName}'
              : '$countryCode${phoneController.text.trim()}',
          'password':
              widget.socialLogin ? widget.userName : passController.text.trim(),
          "player_id": sharedPref.getString(PLAYER_ID).validate(),
          if (widget.socialLogin) 'login_type': 'mobile',
        };

        await signUpApi(req).then((value) {
          authService
              .signUpWithEmailPassword(getContext,
                  mobileNumber: widget.socialLogin
                      ? '${widget.countryCode}${widget.userName}'
                      : '$countryCode${phoneController.text.trim()}',
                  email: emailController.text.trim(),
                  fName: firstController.text.trim(),
                  lName: lastNameController.text.trim(),
                  userName: widget.socialLogin
                      ? widget.userName
                      : userNameController.text.trim(),
                  password: widget.socialLogin
                      ? widget.userName
                      : passController.text.trim(),
                  userType: RIDER,
                  isOtpLogin: widget.socialLogin)
              .then((res) async {
            //
          }).catchError((e) {
            appStore.setLoading(false);
            toast('$e');
          });
        }).catchError((error) {
          appStore.setLoading(false);
          toast('${error['message']}');
        });
      } else {
        toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
      }
    }
  }

}
