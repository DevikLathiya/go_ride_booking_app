import 'dart:io';

import 'package:cabuser/main.dart';
import 'package:cabuser/model/LoginResponse.dart';
import 'package:cabuser/network/RestApis.dart';
import 'package:cabuser/screens/GoRideHomeScreen.dart';
import 'package:cabuser/utils/Common.dart';
import 'package:cabuser/utils/Constants.dart';
import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:flutter/material.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/Extensions/app_common.dart';
import '../Widget/AppBar.dart';
import 'GoRideEditProfileShowData.dart';

class GoRideEditProfile extends StatefulWidget {
  final bool? isGoogle;
  GoRideEditProfile({this.isGoogle = false});

  @override
  State<StatefulWidget> createState() {
    return GoRideEditProfileState();
  }
}

class GoRideEditProfileState extends State<GoRideEditProfile> {

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String Gender="";


  @override
  void initState() {
    super.initState();
    init();
    print("object");
    print(sharedPref.getString(USER_NAME));
  }
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? imageProfile;
  String countryCode = defaultCountryCode;

  void init() async {
    appStore.setLoading(true);
    getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      emailController.text = value.data!.email.validate().toString();
      usernameController.text = value.data!.username.validate().toString();
      contactNumberController.text = value.data!.contactNumber.validate();
      firstNameController.text = value.data!.firstName.validate();
      lastNameController.text = value.data!.lastName.validate();
      addressController.text = value.data!.address.validate();
      Gender = sharedPref.getString(GENDER)!;

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
      appStore.setLoading(false);
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
              MediaQuery.of(context).size.height * .15,
            ),
            child: PreferredSizeAppBar(
              title: GoRideStringRes.editProfile,
            )),
        body: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 40),
            decoration: GoRideConstant.boxDecorationContainer(
                GoRideColors.white, false),
            child: Form(
              key: _formKey,
              child: Column(children: [
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1,
                    ),
                    child: Text(
                      GoRideStringRes.FullName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xffababab),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                fullNameEnter(),
                SizedBox(
                  height: 25,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1,
                    ),
                    child: Text(
                      GoRideStringRes.firstName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xffababab),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                 firstNameEnter(),
                SizedBox(
                  height: 25,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1,
                    ),
                    child: Text(
                      GoRideStringRes.lastName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xffababab),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                lastNameEnter(),
                SizedBox(
                  height: 25,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .1),
                    child: Text(
                      GoRideStringRes.EmailID,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xffababab),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                emailIdEnter(),
                SizedBox(
                  height: 25,
                ),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .1),
                    child: Text(
                      GoRideStringRes.PhoneNumber,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xffababab),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )),
                phoneNoEnter(),
                SizedBox(
                  height: 25,
                ),
                gender(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                ElevatedButton(
                  onPressed: () {
                    saveProfile();
                  },
                  child: Text(
                    GoRideStringRes.SaveProfile,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: GoRideColors.black,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(310, 50),
                    primary: GoRideColors.yellow,
                  ),
                )
              ]),
            )));
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(File(imageProfile!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center),
        ),
      );
    } else {
      if (sharedPref.getString(USER_PROFILE_PHOTO)!.isNotEmpty) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: commonCachedNetworkImage(sharedPref.getString(USER_PROFILE_PHOTO).validate(), fit: BoxFit.cover,
                height: 100, width: 100),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: commonCachedNetworkImage(sharedPref.getString(USER_PROFILE_PHOTO).validate(), height: 90, width: 90),
            ),
          ),
        );
      }
    }
  }

  Future<void> saveProfile() async {
    hideKeyboard(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      appStore.setLoading(true);
      await updateProfile(
        uid: sharedPref.getString(UID).toString(),
        file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
        contactNumber: widget.isGoogle == true ? '$countryCode${contactNumberController.text.trim()}' : contactNumberController.text.trim(),
        address: addressController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userEmail: emailController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);
        toast(language.profileUpdateMsg);
        if (widget.isGoogle == true) {
          launchScreen(context,  GoRideEditProfileShow(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          Navigator.pop(context);
        }
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  Widget fullNameEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
          readOnly: true,
          cursorColor: Color(0xffa2a2a2),
          controller: usernameController,
          onTap: () {
            toast(language.notChangeUsername);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "Enter Full name",
            hintStyle: TextStyle(
                color: GoRideColors.black,
                fontSize: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
          )),
    );
  }

  Widget firstNameEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
          cursorColor: Color(0xffa2a2a2),
          controller: firstNameController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "Enter First Name",
            hintStyle: TextStyle(
                color: GoRideColors.black,
                fontSize: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
          )),
    );
  }

  Widget lastNameEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
          cursorColor: Color(0xffa2a2a2),
          controller: lastNameController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "Enter Last Name",
            hintStyle: TextStyle(
                color: GoRideColors.black,
                fontSize: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
          )),
    );
  }

  Widget emailIdEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
          readOnly: true,
          cursorColor: Color(0xffa2a2a2),
          controller:  emailController,
          onTap: () {
            toast(language.notChangeEmail);
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "Enter Email",
            hintStyle: TextStyle(
                color: GoRideColors.black,
                fontSize: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
          )),
    );
  }

  Widget phoneNoEnter() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .1,
        right: MediaQuery.of(context).size.width * .1,
      ),
      child: TextFormField(
          readOnly: true,
          cursorColor: Color(0xffa2a2a2),
          controller: contactNumberController,
          keyboardType: TextInputType.number,
          onTap: () {
              toast(language.youCannotChangePhoneNumber);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "Enter Mobile",
            hintStyle: TextStyle(
                color: GoRideColors.black,
                fontSize: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa2a2a2)),
            ),
          )),
    );
  }

  String radioButtonItem = 'Male';

  // Group Value for Radio Button.
  int id = 1;
  Widget gender() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * .08),
          child: Radio(
            value: 1,
            groupValue: id,
            activeColor: GoRideColors.yellow,
            onChanged: (val) {
              setState(() {
                Gender = 'Male';
                sharedPref.setString(GENDER, Gender);
                id = 1;
              });
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(right: 40),
          child: Text(
            'Male',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Radio(
          value: 2,
          groupValue: id,
          activeColor: GoRideColors.yellow,
          onChanged: (val) {
            setState(() {
              Gender = 'Female';
              sharedPref.setString(GENDER, Gender);
              id = 2;
            });
          },
        ),
        Container(
            padding: EdgeInsets.only(right: 40),
            child: Text(
              'Female',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
      ],
    );
  }
}
