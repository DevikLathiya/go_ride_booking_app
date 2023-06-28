import 'dart:async';
import 'dart:developer';

import 'package:cabuser/Screens/LocationPermissionScreen.dart';
import 'package:cabuser/Screens/NewEstimateRideListWidget.dart';
import 'package:cabuser/Screens/ReviewScreen.dart';
import 'package:cabuser/utils/Constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cabuser/Helper/GoRIdeConstant.dart';
import 'package:cabuser/Helper/GoRideColor.dart';
import 'package:cabuser/Screens/Payment/GoRideChooseDesScreen.dart';
import 'package:cabuser/Screens/Widget/slideAnimation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:octo_image/octo_image.dart';

import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';
import 'OrderDetailScreen.dart';
import 'Profile/GoRideEditProfileShowData.dart';

class GoRideHomeScreen extends StatefulWidget {
  const GoRideHomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GoRideHomeScreenState();
  }
}

double xOffset = 0;
double yOffset = 0;
double scaleFactor = 1;
bool isDrawerOpen = false;

class GoRideHomeScreenState extends State<GoRideHomeScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  bool isSearch = false;
  LocationPermission? permissionData;
  LatLng? sourceLocation;
  double cameraZoom = 14;
  double cameraTilt = 0;
  double cameraBearing = 30;
  int onTapIndex = 0;
  List<Marker> markers = [];
  int selectIndex = 0;
  String sourceLocationTitle = '';
  late BitmapDescriptor riderIcon;
  late BitmapDescriptor driverIcon;
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  OnRideRequest? servicesListData;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.242001, 69.666931),
    zoom: 13,
  );

  Future<void> getCurrentUserLocation() async {
    if (permissionData != LocationPermission.denied) {
      final geoPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).catchError((error) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
      });
      sourceLocation = LatLng(geoPosition.latitude, geoPosition.longitude);
      List<Placemark>? placemarks = await placemarkFromCoordinates(geoPosition.latitude, geoPosition.longitude);
      sharedPref.setString(COUNTRY, placemarks[0].isoCountryCode.validate(value: defaultCountry));

      Placemark place = placemarks[0];
      if (place != null) {
        sourceLocationTitle = "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
        polylineSource = LatLng(geoPosition.latitude, geoPosition.longitude);
      }
      markers.add(
        Marker(
          markerId: MarkerId('Order Detail'),
          position: sourceLocation!,
          draggable: true,
          infoWindow: InfoWindow(title: sourceLocationTitle, snippet: ''),
          icon: riderIcon,
        ),
      );
      startLocationTracking();
      getNearByDriverList(latLng: sourceLocation).then((value) async {
        value.data!.forEach((element) {
          markers.add(
            Marker(
              markerId: MarkerId('Driver${element.id}'),
              position: LatLng(double.parse(element.latitude!.toString()), double.parse(element.longitude!.toString())),
              infoWindow: InfoWindow(title: '${element.firstName} ${element.lastName}', snippet: ''),
              icon: driverIcon,
            ),
          );
        });
        setState(() {});
      });
      setState(() {});
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
    }
  }

  void init() async {
    getCurrentUserLocation();
    riderIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), MultipleDriver);
    await getAppSetting().then((value) {
      if (value.walletSetting != null) {
        value.walletSetting!.forEach((element) {
          if (element.key == PRESENT_TOPUP_AMOUNT) {
            appStore.setWalletPresetTopUpAmount(element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }
          if (element.key == MIN_AMOUNT_TO_ADD) {
            if (element.value != null) appStore.setMinAmountToAdd(int.parse(element.value!));
          }
          if (element.key == MAX_AMOUNT_TO_ADD) {
            if (element.value != null) appStore.setMaxAmountToAdd(int.parse(element.value!));
          }
        });
      }
      if (value.rideSetting != null) {
        value.rideSetting!.forEach((element) {
          if (element.key == PRESENT_TIP_AMOUNT) {
            appStore.setWalletTipAmount(element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }
          if (element.key == RIDE_FOR_OTHER) {
            appStore.setIsRiderForAnother(element.value ?? "0");
          }
          if (element.key == MAX_TIME_FOR_RIDER_MINUTE) {
            appStore.setRiderMinutes(element.value ?? '4');
          }
        });
      }
      if (value.currencySetting != null) {
        appStore.setCurrencyCode(value.currencySetting!.symbol ?? currencySymbol);
        appStore.setCurrencyName(value.currencySetting!.code ?? currencyNameConst);
        appStore.setCurrencyPosition(value.currencySetting!.position ?? LEFT);
      }
    }).catchError((error) {
      log('${error.toString()}');
    });
    polylinePoints = PolylinePoints();
  }

  Future<void> startLocationTracking() async {
    Map req = {
      "status": "active",
      "latitude": sourceLocation!.latitude.toString(),
      "longitude": sourceLocation!.longitude.toString(),
    };
    await updateStatus(req).then((value) {
      //
    }).catchError((error) {
      log(error);
    });
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) {
      servicesListData = value.rideRequest ?? value.onRideRequest;
      if (servicesListData != null) {
        if (servicesListData!.status != COMPLETED) {
          launchScreen(
            getContext,
            isNewTask: true,
            NewEstimateRideListWidget(
              sourceLatLog: LatLng(double.parse(servicesListData!.startLatitude!), double.parse(servicesListData!.startLongitude!)),
              destinationLatLog: LatLng(double.parse(servicesListData!.endLatitude!), double.parse(servicesListData!.endLongitude!)),
              sourceTitle: servicesListData!.startAddress!,
              destinationTitle: servicesListData!.endAddress!,
              isCurrentRequest: true,
              servicesId: servicesListData!.serviceId,
              id: servicesListData!.id,
            ),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          );
        } else if (servicesListData!.status == COMPLETED && servicesListData!.isRiderRated == 0) {
          launchScreen(context, ReviewScreen(rideRequest: servicesListData!, driverData: value.driver), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
        }
      } else if (value.payment != null && value.payment!.paymentStatus != COMPLETED) {
        launchScreen(context, OrderDetailScreen(rideId: value.payment!.rideRequestId), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  final Set<Marker> _markers = {
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(23.242001, 69.666931),
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {}),
    Marker(
        markerId: MarkerId("2"),
        position: LatLng(23.199090, 69.645000),
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {}),
    /* Marker(
        markerId: MarkerId("3"),
        position: LatLng(23.265670, 69.676900),
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {})*/
  };
  List<ListDataView> location = [
    ListDataView(
        title: "Home",
        imageUrl: GoRideConstant.getSvgImagePath("home_address.svg"),
        description: "80, Vile Parle East",
        dropOff: "80, Vile Parle West"),
    ListDataView(
        title: "Work",
        imageUrl: GoRideConstant.getSvgImagePath("work_address.svg"),
        description: "80, Vile Parle West",
        dropOff: "80, Vile Parle East"),
    ListDataView(
        title: "Coffee Shop",
        imageUrl: GoRideConstant.getSvgImagePath("coffee_address.svg"),
        description: "80, Vile Parle North",
        dropOff: "80, Vile Parle West")
  ];

  AnimationController? _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    afterBuildCreated(() {
      init();
      getCurrentRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        transform: Matrix4.translationValues(xOffset, yOffset, 0)
          ..scale(scaleFactor)
          ..rotateY(isDrawerOpen ? -0.5 : 0),
        duration: Duration(milliseconds: 250),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isDrawerOpen ? 100 : 0.0)),
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [topDesign(), middleDesign()],
            )));
  }

  Widget topDesign() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: GoRideColors.yellow,
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .03),
      child: isDrawerOpen
          ? Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .03,
                    ),
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        xOffset = 0;
                        yOffset = 0;
                        scaleFactor = 1;
                        isDrawerOpen = false;
                      });
                    },
                  ),
                )
              ],
            )
          : Row(
              children: [
                // SizedBox(width:35 /*MediaQuery.of(context).size.width*.05,*/),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30),
                  child: IconButton(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .05),
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          xOffset = 230;
                          yOffset = 150;
                          scaleFactor = 0.6;
                          isDrawerOpen = true;
                        });
                      }),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .59,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: /*Stack(
              children: [*/
                      GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              GoRideEditProfileShow(),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .03),
                      /* height: MediaQuery.of(context).size.height*.11,
                        width:  MediaQuery.of(context).size.width*.11,
                     */
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          )),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 22,
                        child: ClipOval(
                            child: OctoImage(
                          image: CachedNetworkImageProvider(
                              "https://firebasestorage.googleapis.com/v0/b/smartkit-8e62c.appspot.com/o/travelapp%2Fprofilepic.png?alt=media&token=af80c7e4-e14d-4645-b706-c651fb08116e"),
                          placeholderBuilder: OctoPlaceholder.blurHash(
                            "LRHe%pIA.m_2KjxawKNGIWkWD*M{",
                            fit: BoxFit.contain,
                          ),
                          errorBuilder: OctoError.icon(color: Colors.black),
                          fit: BoxFit.contain,
                          height: MediaQuery.of(context).size.height * .11,
                          width: MediaQuery.of(context).size.width * .11,
                        )),
                      ),
                    ),
                  ), /*
                 Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*.06,left: MediaQuery.of(context).size.width*.07),
                    child: CircleAvatar(
                      radius: 13,
                      child: FloatingActionButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GoRideEditProfileShow(),),);
                      },
                          backgroundColor: GoRideColors.yellow,
                          mini: true,
                          child: Icon(Icons.edit,color: Colors.white,size: 15,)),
                    ),
                  ),
              ],
            )*/
                ),
              ],
            ),
    );
  }

  Widget middleDesign() {
    return Container(
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .15),
        // width: MediaQuery.of(context).size.width,
        decoration:
            GoRideConstant.boxDecorationContainer(GoRideColors.white, false),
        child: SingleChildScrollView(
          child: Column(children: [
            mapImageShow(),
            search(),
            SizedBox(
              height: 15,
            ),
            listData()
          ]),
        ));
  }

  bool check = false;
  late GoogleMapController mapController;
  final List<Polyline> _polyLine = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  GoogleMapController? controller;

  Widget mapImageShow() {
    _polyLine.add(Polyline(
      polylineId: PolylineId("route1"),
      color: Colors.black,
      jointType: JointType.bevel,
      /*  patterns: [
        PatternItem.dash(20.0),
        PatternItem.gap(10)
      ],*/
      width: 5,
      points: const [
        LatLng(23.242001, 69.666931),
        LatLng(23.199090, 69.645000),
      ],
    ));
    return Stack(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height * .65,
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(60)),
            child: GoogleMap(
              initialCameraPosition:  CameraPosition(
                target: sourceLocation!,
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing,
              ), //_kGooglePlex,
              mapType: MapType.normal,
              markers: markers.map((e) => e).toSet(),//_markers,
              zoomControlsEnabled: false,
              compassEnabled: check,
              mapToolbarEnabled: check,
              polylines: _polyLines,
              //polylines:_polyLine.toSet() ,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _controller.complete(controller);
              },
            ),
          )),
      Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .57, right: 30),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                check = !check;
                print(check);
                /* mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target:
                          // Will be fetching in the next step
                          LatLng(23.242001, 69.666931),
                        zoom: 18.0,
                      ),
                    ),
                  );*/
              });
            },
            backgroundColor: GoRideColors.yellow,
            heroTag: "data",
            mini: true,
            child: SvgPicture.asset(
              GoRideConstant.getSvgImagePath("add.location.svg"),
              color: GoRideColors.white,
            ),
          ))
    ]);
  }

  /*  Stack(
      children: [
        Container ( height: MediaQuery.of(context).size.height*.65,
          child: ClipRRect(borderRadius:BorderRadius.only(topLeft: Radius.circular(60)),
            child:SmartKitProConstant.isfirebaseimage?OctoImage(image: CachedNetworkImageProvider(
                "https://firebasestorage.googleapis.com/v0/b/smartkit-8e62c.appspot.com/o/goride%2Fmap.jpg?alt=media&token=39013a81-98ea-4e47-aea4-919963651f0e"),
              placeholderBuilder: OctoPlaceholder.blurHash(
                "L2Pt0\$S;F_Y83N];^8I+3p9_[dD~",
              ),
              errorBuilder: OctoError.icon(color: GoRideColors.black),
              fit: BoxFit.fill,
            ):Image.asset(
              GoRideConstant.getPngImagePath("map.jpg"), fit: BoxFit.fill,
            ),

          ),
        ),
        Container(
            alignment:Alignment.bottomRight,
            padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*.57,right: 30),
            child: FloatingActionButton(onPressed: () {  },
              backgroundColor: GoRideColors.yellow,
              mini: true,
              child:SvgPicture.asset(GoRideConstant.getSvgImagePath("add.location.svg"),color: GoRideColors.white,),
            ))
      ],
    );*/
  String? _dropDownValue;
  Widget search() {
    return Container(
      color: Color(0xfff6f6f6),
      height: MediaQuery.of(context).size.height * .06,
      margin: EdgeInsets.only(left: 35, right: 35, top: 15),
      child: DropdownButtonFormField(
        alignment: Alignment.centerLeft,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.circle,
            color: GoRideColors.yellow,
            size: 15,
          ),
          suffixIcon: SvgPicture.asset(
            GoRideConstant.getSvgImagePath("search.svg"),
            fit: BoxFit.scaleDown,
          ),
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        iconSize: 0.0,
        isDense: true,
        hint: _dropDownValue == null
            ? Text('Where to?')
            : Text(
                _dropDownValue!,
                style: TextStyle(color: Colors.black),
              ),
        //  icon: SvgPicture.asset(GoRideConstant.getSvgImagePath("search.svg"),fit: BoxFit.scaleDown,),
        isExpanded: true,
        //iconSize: 30.0,
        style: TextStyle(color: Colors.black),
        items: [
          'Bhuj-Mundra',
          'Jamnagar-Rajkot',
          'Surat-Mumbai',
          "Vadodara-Bharuch"
        ].map(
          (val) {
            return DropdownMenuItem<String>(
              value: val,
              // alignment: Alignment.center,
              child: Text(val),
            );
          },
        ).toList(),
        onChanged: (val) {
          setState(
            () {
              _dropDownValue = val as String?;
            },
          );
        },
      ),

      /*TextFormField(cursorColor: GoRideColors.black,
        onTap: (){
        setState(() {
          isSearch=true;
          print(isSearch);
        });
        },
        onChanged: (value) => _runFilter(value),
        decoration: new InputDecoration(isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,),
            hintText: 'Where to?',
            prefixIcon: Icon(Icons.circle,color:GoRideColors.yellow,size: 15,),
            //prefixText: '●',prefixStyle: TextStyle(color: GoRideColors.yellow,fontSize: 20),
            suffixIcon: SvgPicture.asset(GoRideConstant.getSvgImagePath("search.svg"),fit: BoxFit.scaleDown,),

      ),
    )*/
    );
  }

  Widget listData() {
    return SlideAnimation(
        position: 5,
        itemCount: 15,
        slideDirection: SlideDirection.fromRight,
        animationController: _animationController,
        child: Container(
          height: MediaQuery.of(context).size.height * .08,
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * .06),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: location.length,
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: MediaQuery.of(context).size.width * .395,
                  margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: GoRideColors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A212121),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 0.0, //extend the shadow
                      )
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              GoRideChooseDesScreen(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(location[index].imageUrl),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .05,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(location[index].title),
                            Text(
                              location[index].description,
                              style: TextStyle(
                                  fontSize: 9, color: Color(0xff212121)),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}

class ListDataView {
  late final String imageUrl;
  late final String title;
  late final String description;
  late final String dropOff;
  ListDataView({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.dropOff,
  });
}
