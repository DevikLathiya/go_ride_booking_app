import 'dart:developer';
import 'dart:io';

import 'package:cabuser/Screens/ChangePasswordScreen.dart';
import 'package:cabuser/main.dart';
import 'package:cabuser/utils/Common.dart';
import 'package:cabuser/utils/Constants.dart';
import 'package:cabuser/utils/Extensions/StringExtensions.dart';
import 'package:cabuser/utils/Extensions/app_common.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Helper/GoRideStringRes.dart';
import 'package:cabuser/Screens/Address/GoRideMyAddress.dart';

import '../../components/ImageSourceDialog.dart';
import '../../network/RestApis.dart';
import '../GoRideDrawerHome.dart';
import '../GoRideHomeScreen.dart';
import 'GoRIdeNewPwd.dart';
import 'GoRideEditProfile.dart';

class GoRideEditProfileShow extends StatefulWidget {
  final bool? isGoogle;
  GoRideEditProfileShow({this.isGoogle = false});

  @override
  State<StatefulWidget> createState() {
    return GoRideEditProfileShowState();
  }
}

class GoRideEditProfileShowState extends State<GoRideEditProfileShow> {
  XFile? imageProfile;
  String countryCode = defaultCountryCode;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String Gender="";

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      emailController.text = value.data!.email.validate();
      usernameController.text = value.data!.username.validate();
      firstNameController.text = value.data!.firstName.validate();
      lastNameController.text = value.data!.lastName.validate();
      addressController.text = value.data!.address.validate();
      contactNumberController.text = value.data!.contactNumber.validate();
      // Gender=value.data!.gender.validate();
      Gender = sharedPref.getString(GENDER) ?? "Male";

      appStore.setUserEmail(value.data!.email.validate());
      appStore.setUserName(value.data!.username.validate());
      appStore.setFirstName(value.data!.firstName.validate());

      sharedPref.setString(USER_EMAIL, value.data!.email.validate());
      sharedPref.setString(FIRST_NAME, value.data!.firstName.validate());
      sharedPref.setString(LAST_NAME, value.data!.lastName.validate());

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
      appStore.setLoading(false);
    });
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
                      width: MediaQuery.of(context).size.width * .2,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .05,
                      ),
                      child: Text(
                        GoRideStringRes.editProfile,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    )
                  ])),

              //  PreferredSizeAppBar(title: GoRideStringRes.editProfile,)
            ),
            body: Form(
              key: _formKey,
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(top: 30),
                  decoration: GoRideConstant.boxDecorationContainer(
                      GoRideColors.white, false),
                  child: Column(children: [
                    imageAndText(),
                    Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1,
                            top: 5),
                        child: Divider(
                          color: Color(0x25707070),
                          thickness: 2,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: Text(
                            GoRideStringRes.personalDetail,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 22.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        GoRideEditProfile(),
                                  ),
                                );
                              },
                              child: Text(
                                GoRideStringRes.Edit,
                                style: TextStyle(
                                    color: GoRideColors.yellow,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: SvgPicture.asset(
                              GoRideConstant.getSvgImagePath("pro.user.svg")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${usernameController.text}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: SvgPicture.asset(
                              GoRideConstant.getSvgImagePath("pro.mail.svg")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${emailController.text}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: SvgPicture.asset(
                              GoRideConstant.getSvgImagePath("pro.phone.svg")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "${contactNumberController.text}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: SvgPicture.asset(
                              GoRideConstant.getSvgImagePath("pro.gender.svg")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: (Gender.isEmpty) ? Text(
                            "Male",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ) :  Text(
                            "${Gender}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: SvgPicture.asset(
                              GoRideConstant.getSvgImagePath("pro.password.svg")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "●●●●●●●",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ChangePasswordScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * .5),
                            child: SvgPicture.asset(
                                GoRideConstant.getSvgImagePath(
                                    "pro.right_arrow.svg")),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1,
                            top: 5),
                        child: Divider(
                          color: Color(0x25707070),
                          thickness: 2,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1),
                          child: Text(
                            GoRideStringRes.Address,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    GoRideMyAddress(),
                              ),
                            );
                          },
                          child: Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width * .08),
                              child: SvgPicture.asset(
                                  GoRideConstant.getSvgImagePath(
                                      "pro.right_arrow.svg"))),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .1,),
                        SvgPicture.asset(
                            GoRideConstant.getSvgImagePath("pro.address.svg")),
                        // SizedBox(width: MediaQuery.of(context).size.width*.1,),
                        Container(
                          width: 270,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.topLeft,
                          child: (addressController.text.isNotEmpty) ? Text(
                            "${addressController.text}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ) : Text(
                            "Address",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ) ,
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        xOffset = 0;
                        yOffset = 0;
                        scaleFactor = 1;
                        isDrawerOpen = false;
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
                  ])),
            )));
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
          launchScreen(context, GoRideHomeScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          Navigator.pop(context);
        }
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  Widget imageAndText() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .12, top: 20),
                height: MediaQuery.of(context).size.height * .08,
                width: MediaQuery.of(context).size.width * .19,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 8.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shad
                    )
                  ],
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: (imageProfile != null) ?
                    Image.file(File(imageProfile!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center)
                        : (sharedPref.getString(USER_PROFILE_PHOTO)!.isNotEmpty) ?
                    commonCachedNetworkImage(sharedPref.getString(USER_PROFILE_PHOTO).validate(), fit: BoxFit.cover,
                        height: 100, width: 100) : commonCachedNetworkImage(sharedPref.getString(USER_PROFILE_PHOTO).validate(), height: 90, width: 90),
                    /*OctoImage(
                      image: CachedNetworkImageProvider(
                          "https://firebasestorage.googleapis.com/v0/b/smartkit-8e62c.appspot.com/o/travelapp%2Ftoptrip_b.jpg?alt=media&token=cd01d6b2-2892-4da7-bfee-4069e2e4f7e8"),
                      placeholderBuilder: OctoPlaceholder.blurHash("L5Jk_:009FDi00oJ-oRj00~VMwM{",),
                      errorBuilder: OctoError.icon(color: GoRideColors.black),
                      fit: BoxFit.contain,
                    )*/)),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * .24,
                top: MediaQuery.of(context).size.height * .09,
              ),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return ImageSourceDialog(
                        onCamera: () async {
                          // Navigator.pop(context);
                          imageProfile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
                          print("imageProfile : $imageProfile");
                          // Navigator.pop(context);
                          // setState(() {});
                        },
                        onGallery: () async {
                          // Navigator.pop(context);
                          imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                          // setState(() {});
                        },
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: SvgPicture.asset(
                    GoRideConstant.getSvgImagePath("pro.edit_image.svg"),
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: 30,
            left: MediaQuery.of(context).size.width * .02,
            top: MediaQuery.of(context).size.height * .03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                "${usernameController.text}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${emailController.text}",
                style: TextStyle(fontSize: 12, color: Color(0xff818181)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
