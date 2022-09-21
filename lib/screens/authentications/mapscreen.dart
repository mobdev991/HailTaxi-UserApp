import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_carride/providers/appData.dart';
import 'package:grab_carride/screens/authentications/set_destination_page.dart';
import 'package:grab_carride/screens/main/main_screen.dart';
import 'package:grab_carride/screens/main/payment_page.dart';
import 'package:provider/provider.dart';

import '../../Assistance/assistanceMethods.dart';
import '../../Assistance/geoFireAssistance.dart';
import '../../Models/direactionDetails.dart';
import '../../Models/nearByAvailableDrivers.dart';
import '../../config.dart';
import '../../main.dart';
import '../no_driver_available.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  Position? usercurrentLocation;
  bool nearbyAvailableDriverKeysLoaded = false;
  BitmapDescriptor? nearByIcon;
  bool isPromoCode = false;

  double searchContainerHeight = 200; //225

  double taxiTypeContainerHeight = 0;
  double parcelTypeContainerHeight = 0;
  double petTypeContainerHeight = 0;
  double promoCodeContainerHeight = 0;

  bool orderDetailsVisibility = false;

  double findingDriverContainerHeight = 0;
  late Stream<DatabaseEvent> rideStreamSubscription;

  GoogleMapController? newGoogleMapControler;
  DirectionDetails? tripDirectionDetails;

  @override
  void dispose() {
    newGoogleMapControler?.dispose();
    super.dispose();
  }

  List<Marker> _markers = [];
  List<Marker> _list = const [
    Marker(
        markerId: MarkerId(''),
        position: LatLng(37.42796133580664, -122.085749655962),
        infoWindow: InfoWindow(title: 'Current Location'))
  ];

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-33.873652, 151.204629),
    zoom: 14.4746,
  );

  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  List<LatLng> pLineCoordinates = [];

  Color miniContainerColor = Colors.white;
  Color goContainerColor = Colors.white;
  Color buzzContainerColor = Colors.white;
  Color familyContainerColor = Colors.white;

  bool findDriverVisibility = false;
  bool topBandVisbility = false;
  bool driverDetailsVisibility = false;

  String topBandText = 'Finding Driver';

  GlobalKey<ScaffoldState> _scaffoldKEY = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  List<NearbyAvailableDrivers>? availableDrivers;
  String? picURL;
  DatabaseReference? rideRequestRef;

  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  CountryCode countryCode = CountryCode.fromDialCode('+61');

  String nameRideRequest = 'NA';
  String phoneRideRequest = 'NA';

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    createIconMarker();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
                myLocationEnabled: true,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                initialCameraPosition: _kGooglePlex,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                polylines: polylineSet,
                markers: markersSet,
                circles: circlesSet,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapControler = controller;

                  if (settingUpAddress != 'dummy') {
                    availableDrivers =
                        GeoFireAssistant.nearByAvailableDriversList;
                  }
                  print(
                      'in google maap ........................................');
                  getCurrentLocationButton();
                }),
            // current location button
            Positioned(
                top: screenHeight / 2,
                right: 10,
                child: Container(
                    height: 60,
                    child: Card(
                      child: IconButton(
                        icon: Icon(Icons.my_location),
                        color: Colors.green,
                        iconSize: 35,
                        onPressed: () {
                          getCurrentLocationButton();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => OnRideScreen()),
                          // );
                        },
                      ),
                    ))),
            // top band..
            Visibility(
              visible: topBandVisbility,
              child: Positioned(
                top: 10,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.green.withOpacity(0.3), width: 2),
                    color: Colors.white70,
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    topBandText,
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ),
            //Enter Location
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Container(
                height: searchContainerHeight,
                color: Colors.green.shade300,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          settingUpAddress = 'normal';
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetDestination()));
                          print(res);
                          if (res == "normal") {
                            if (rideType == 'Taxi') {
                              await displayTaxiTypeContainerHeight();
                            } else if (rideType == 'Package') {
                              await displayParcelTypeContainerHeight();
                            } else if (rideType == 'Pet') {
                              await displayPetTypeContainerHeight();
                            } else {
                              print('no ride type selected');
                            }

                            print('Ride Type == $rideType');
                            print('response :: $res');
                          } else {
                            print('no response :: $res');
                          }
                        },
                        decoration: InputDecoration(
                          hintText: setHintText(),
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          errorStyle:
                              TextStyle(color: Colors.redAccent, fontSize: 15),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            //  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            settingUpAddress = 'home';
                            if (homeAddress != null) {
                              print(
                                  'berro berro Everything in homeAddress ..................');
                              if (rideType == 'Taxi') {
                                await displayTaxiTypeContainerHeight();
                              } else if (rideType == 'Package') {
                                await displayParcelTypeContainerHeight();
                              } else if (rideType == 'Pet') {
                                await displayPetTypeContainerHeight();
                              } else {
                                print('no ride type selected');
                              }

                              print('Ride Type == $rideType');
                            } else {
                              var res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SetDestination()));

                              if (res == 'home') {
                                print('response of home is $res');
                              } else {
                                print('response of home is else');
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            width: 120,
                            height: 50,
                            alignment: Alignment.center,
                            child: Text('HOME',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green)),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            settingUpAddress = 'work';
                            if (workAddress != null) {
                              print(
                                  'berro berro everything in workAddress ..................');
                              if (rideType == 'Taxi') {
                                await displayTaxiTypeContainerHeight();
                              } else if (rideType == 'Package') {
                                await displayParcelTypeContainerHeight();
                              } else if (rideType == 'Pet') {
                                await displayPetTypeContainerHeight();
                              } else {
                                print('no ride type selected');
                              }

                              print('Ride Type == $rideType');
                            } else {
                              var res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SetDestination()));

                              if (res == 'work') {
                                print('response of work is $res');
                              } else {
                                print('response of work is else');
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            width: 120,
                            height: 50,
                            alignment: Alignment.center,
                            child: Text('WORK',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Ride Type
            Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: taxiTypeContainerHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      //spreadRadius: 0.5,
                      //  offset: Offset(0.7, 0.7),
                    ),
                  ]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 18,
                                color: Colors.green,
                              ),
                              label: Text(
                                'BACK',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                              onPressed: () {
                                // resetApp();
                              },
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Text(
                              'Selected Ride',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.green.shade100;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.white;
                              });
                              print('mini ride selected');
                              rideSubType = 'THL-Mini';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: miniContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/smalCar.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'THL-Mini',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '3-seat',
                                        // ((tripDirectionDetails != null)
                                        //     ? tripDirectionDetails!.distanceText
                                        //     : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'THL-Mini')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.green.shade100;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.white;
                              });
                              print('go ride selected');
                              rideSubType = 'THL-Sedan';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: goContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/mediumCar.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'THL-Sedan',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '5-seat',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, "THL-Sedan")}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.green.shade100;
                                familyContainerColor = Colors.white;
                              });
                              print('buzz ride selected');
                              rideSubType = 'Maxi-Taxi';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: buzzContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/bigCar.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Maxi-Taxi',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '7-seat',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'Maxi-Taxi')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.green.shade100;
                              });
                              rideSubType = 'THL-Super';
                              print('family ride selected');
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: familyContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/carIcon.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'THL-Super',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'WheelChair',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'THL-Super')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            // Type Parcel
            Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: parcelTypeContainerHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      //spreadRadius: 0.5,
                      //  offset: Offset(0.7, 0.7),
                    ),
                  ]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 18,
                                color: Colors.green,
                              ),
                              label: Text(
                                'BACK',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                              onPressed: () {
                                // resetApp();
                              },
                            ),
                            SizedBox(
                              width: screenWidth / 10,
                            ),
                            Text(
                              'Select Parcel Type',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.green.shade100;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.white;
                              });
                              print('go ride selected');
                              rideSubType = 'Small Parcel';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: goContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/smalBox.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Small Parcel',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '4x4 / 5 kg',
                                        // ((tripDirectionDetails != null)
                                        //     ? tripDirectionDetails!.distanceText
                                        //     : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'Small Parcel')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.green.shade100;
                                familyContainerColor = Colors.white;
                              });
                              rideSubType = 'Medium Parcel';
                              print('buzz ride selected');
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: buzzContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/mediumBox.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Medium Parcel',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '8x8 / 10 kg',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'Medium Parcel')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.green.shade100;
                              });
                              rideSubType = 'Large Parcel';
                              print('family ride selected');
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: familyContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/bigBox.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Large Parcel',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        '20 kg',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'Large Parcel')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            // Type Pet
            Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: petTypeContainerHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      //spreadRadius: 0.5,
                      //  offset: Offset(0.7, 0.7),
                    ),
                  ]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 18,
                                color: Colors.green,
                              ),
                              label: Text(
                                'BACK',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                              onPressed: () {
                                // resetApp();
                              },
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Text(
                              'Select Pet Type',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.green.shade100;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.white;
                              });
                              print('go ride selected');
                              rideSubType = 'dog';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: goContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/dog.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Dog',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'All Dog Types',
                                        // ((tripDirectionDetails != null)
                                        //     ? tripDirectionDetails!.distanceText
                                        //     : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'dog')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.green.shade100;
                                familyContainerColor = Colors.white;
                              });
                              print('buzz ride selected');
                              rideSubType = 'cat';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: buzzContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "images/cat.png",
                                    height: 80,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Cat',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'All Cat Types',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'cat')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                miniContainerColor = Colors.white;
                                goContainerColor = Colors.white;
                                buzzContainerColor = Colors.white;
                                familyContainerColor = Colors.green.shade100;
                              });
                              print('family ride selected');
                              rideSubType = 'bird';
                              await displayRideDetailsContainerHeight();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: familyContainerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      //spreadRadius: 0.5,
                                      //  offset: Offset(0.7, 0.7),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ImageIcon(
                                    AssetImage("images/bird.png"),
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Birds',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        'All Bird Types',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Fare',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AD \$ ${AssistantMethods.calculateFares(tripDirectionDetails!, 'cat')}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            // Confirm order details
            Visibility(
              visible: orderDetailsVisibility,
              child: DraggableScrollableSheet(
                initialChildSize: 0.1,
                minChildSize: 0.1,
                maxChildSize: 0.7,
                builder: (context, controller) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey, boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        //spreadRadius: 0.5,
                        //  offset: Offset(0.7, 0.7),
                      ),
                    ]),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.green.shade300,
                            height: 60,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              'Confirm Order Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              color: Colors.grey.shade300,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: screenWidth / 1.4,
                                        child: Text(
                                          Provider.of<AppData>(context,
                                                  listen: false)
                                              .pickUpLocation!
                                              .placeName,
                                          style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.my_location,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: screenWidth / 1.4,
                                        child: Text(
                                          Provider.of<AppData>(context,
                                                  listen: false)
                                              .dropOffLocation!
                                              .placeName,
                                          style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Colors.green.shade300,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Booking type !',
                                    style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order Type',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '$rideType',
                                        style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sub Type',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '$rideSubType',
                                        style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Colors.grey.shade300,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Booking Stats !',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Trip Fare',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? 'AUD \$${AssistantMethods.calculateFares(tripDirectionDetails!, rideSubType)}'
                                            : ''),
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Trip Distance',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        tripDirectionDetails!.distanceText,
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Colors.green.shade300,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Add Promo Code!',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Image.asset(
                                        "images/promoCode.png",
                                        height: 40,
                                        width: 40,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  isPromoCode
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            displayPromoCodeContainerHeight();
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              color: Colors.grey.shade300,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() => isPromoCode = false);
                                      // await resetApp();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade300,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red,
                                              blurRadius: 8,
                                              //spreadRadius: 0.5,
                                              //  offset: Offset(0.7, 0.7),
                                            ),
                                          ]),
                                      child: Icon(Icons.cancel),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (settingUpAddress == 'dummy') {
                                        print(
                                            'signed up...........................');
                                        signUpPhoneNumberBottomSheet();
                                      } else {
                                        await displayFindingDriverContainer();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.green.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green,
                                              blurRadius: 8,
                                              //spreadRadius: 0.5,
                                              //  offset: Offset(0.7, 0.7),
                                            ),
                                          ]),
                                      child: Row(
                                        children: [
                                          Text(
                                            settingUpAddress == 'dummy'
                                                ? 'Register to proceed'
                                                : 'Find Driver',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.forward,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // add promo code nibba
            Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  height: promoCodeContainerHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      //spreadRadius: 0.5,
                      //  offset: Offset(0.7, 0.7),
                    ),
                  ]),
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          color: Colors.grey.shade200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  displayRideDetailsContainerHeight();
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                              Text(
                                'Promo Code',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    letterSpacing: 1),
                              ),
                              Icon(
                                Icons.back_hand,
                                color: Colors.transparent,
                              ),
                            ],
                          )),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(width: 2, color: Colors.black26),
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            // autocorrect: true,
                            decoration: InputDecoration(
                              hintText: 'Enter Promo Code',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: ImageIcon(
                                  AssetImage(
                                    "images/promoCode.png",
                                  ),
                                ),
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 15),
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 00, horizontal: 20),
                        color: Colors.white,
                        child: GestureDetector(
                            onTap: () {
                              setState(() => isPromoCode = true);
                              displayRideDetailsContainerHeight();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 50),
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        letterSpacing: 1),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                )),
            // searching driver
            Visibility(
              visible: findDriverVisibility,
              child: DraggableScrollableSheet(
                initialChildSize: 0.27,
                minChildSize: 0.1,
                maxChildSize: 0.4,
                builder: (context, controller) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Colors.grey.shade300, boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        //spreadRadius: 0.5,
                        //  offset: Offset(0.7, 0.7),
                      ),
                    ]),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey.shade300,
                            height: 60,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              'Searching nearest driver',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: SpinKitFadingCube(
                              color: Colors.green,
                              size: 50.0,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              color: Colors.grey.shade300,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await resetApp();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade300,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red,
                                              blurRadius: 16,
                                              //spreadRadius: 0.5,
                                              //  offset: Offset(0.7, 0.7),
                                            ),
                                          ]),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Cancel Ride',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Driver info after ride accepted
            Visibility(
              visible: driverDetailsVisibility,
              child: DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.15,
                maxChildSize: 0.4,
                builder: (context, controller) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      //         boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black,
                      //     blurRadius: 16,
                      //     //spreadRadius: 0.5,
                      //     //  offset: Offset(0.7, 0.7),
                      //   ),
                      // ]
                    ),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 20, bottom: 5),
                            color: Colors.transparent,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 60,
                                  width: 120,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white54,
                                      border: Border.all(
                                          color: Colors.green, width: 3)),
                                  child: Text(
                                    'AUD ${rideDetails!.fareRide}',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 0),
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  width: 120,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white54,
                                      border: Border.all(
                                          color: Colors.green, width: 3)),
                                  child: Text(
                                    '10m away',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20, bottom: 5),
                            color: Colors.grey.shade200,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text(
                                  '${rideDetails!.carColor} - ${rideDetails!.carName}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 0),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.green.withOpacity(0.8),
                                          width: 1),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      '${rideDetails!.carNumber}',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1),
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            color: Colors.grey.shade400,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: NetworkImage(rideDetails!
                                              .picDriver !=
                                          null
                                      ? '${rideDetails!.picDriver}'
                                      : 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg&w=640&h=960'),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${rideDetails!.nameDriver}',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          letterSpacing: 0),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '4.9',
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              letterSpacing: 0),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 30,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 80,
                                ),
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.green.shade400,
                                  child: Icon(
                                    Icons.chat_bubble,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Report An Issue With Order !',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0),
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.red.shade400,
                                  child: Icon(
                                    Icons.dangerous,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future signUpPhoneNumberBottomSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Wrap(
              children: <Widget>[
                Container(
                    color: Colors.green.shade300,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Register an account',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    )),
                Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.only(left: 20, bottom: 20, top: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please Enter Your Phone Number',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.5),
                        ),
                      ],
                    )),
                Container(
                  color: Colors.grey.shade300,
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10, left: 20.0, right: 20),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    //controller: phoneController,
                    decoration: InputDecoration(
                      prefixIcon: SizedBox(
                        height: 20,
                        child: CountryCodePicker(
                          textOverflow: TextOverflow.visible,
                          padding: EdgeInsets.only(
                            top: 2,
                            bottom: 7,
                          ),
                          onChanged: (code) {
                            countryCode = code;
                          },
                          initialSelection: countryCode.dialCode,
                          showCountryOnly: true,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                      ),
                      hintText: 'Phone Number',
                      // border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    verifyPhoneNumberBottomSheet();
                  },
                  child: Container(
                      color: Colors.grey.shade300,
                      padding: EdgeInsets.only(bottom: 50, top: 20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 150,
                              height: 50,
                              color: Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1),
                                  ),
                                ],
                              ))
                        ],
                      )),
                ),
              ],
            ));
  }

  Future verifyPhoneNumberBottomSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Wrap(
              children: <Widget>[
                Container(
                    color: Colors.green.shade300,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Verify Your Phone Number',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    )),
                Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.only(left: 20, bottom: 20, top: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter OTP',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.5),
                        ),
                      ],
                    )),
                Container(
                  color: Colors.grey.shade300,
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10, left: 20.0, right: 20),
                  child: TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    //controller: phoneController,
                    decoration: InputDecoration(
                      prefixIcon: SizedBox(
                        height: 20,
                      ),
                      hintText: 'Enter OTP',
                      // border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    phoneRideRequest = phoneController.text;
                    Navigator.pop(context);
                    enterPersonalInfoBottomSheet();
                  },
                  child: Container(
                      color: Colors.grey.shade300,
                      padding: EdgeInsets.only(bottom: 50, top: 20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 150,
                              height: 50,
                              color: Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1),
                                  ),
                                ],
                              ))
                        ],
                      )),
                ),
              ],
            ));
  }

  Future enterPersonalInfoBottomSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Wrap(
              children: <Widget>[
                Container(
                    color: Colors.green.shade300,
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Enter Your Information',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    )),
                Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.only(left: 20, top: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What should we call you!',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5),
                        ),
                      ],
                    )),
                Container(
                  color: Colors.grey.shade300,
                  padding: EdgeInsets.only(bottom: 10, left: 20.0, right: 20),
                  child: TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.number,
                    //controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      // border: InputBorder.none,
                    ),
                  ),
                ),
                // email
                Container(
                    color: Colors.grey.shade300,
                    padding: EdgeInsets.only(left: 20, top: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please enter your email!',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5),
                        ),
                      ],
                    )),
                Container(
                  color: Colors.grey.shade300,
                  padding: EdgeInsets.only(bottom: 10, left: 20.0, right: 20),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.number,
                    //controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      // border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    nameRideRequest = nameController.text;
                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.pop(context);
                    await displayFindingDriverContainer();
                  },
                  child: Container(
                      color: Colors.grey.shade300,
                      padding: EdgeInsets.only(bottom: 50, top: 20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 150,
                              height: 50,
                              color: Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1),
                                  ),
                                ],
                              ))
                        ],
                      )),
                ),
              ],
            ));
  }

  resetApp() {
    setState(() {
      searchContainerHeight = 200;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;

      rideType = 'N/A';
      rideSubType = 'N/A';
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
      cancelRideRequest();
    });
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false);
  }

  void locatUserOnMap() {
    newGoogleMapControler?.setMapStyle("[]");
    print('GetCurrent  executed');
    Position? position =
        Provider.of<AppData>(context, listen: false).myPosition;
    LatLng currentPosition = LatLng(position!.latitude, position.longitude);

    usercurrentLocation = position;

    CameraPosition cameraPositionuser =
        new CameraPosition(target: currentPosition, zoom: 14);

    newGoogleMapControler!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPositionuser));
    // initGeoFireListner();
  }

  void getCurrentLocationButton() async {
    print('GetCurrent Lcoation executed');

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    usercurrentLocation = position;

    print('GetCurrent  executed');
    LatLng currentPosition = LatLng(position.latitude, position.longitude);
    print('GetCurrent Lcoation ');
    CameraPosition cameraPositionuser =
        new CameraPosition(target: currentPosition, zoom: 14);

    newGoogleMapControler!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPositionuser));
    String address =
        await AssistantMethods().searchCoordinateAddress(position, context);

    print('your address yo bellow' ' :: ${address}');

    print("currentFirebaseUser 00000000000000000000000000000000");
    print(currentFirebaseUser);
    print("currentFirebaseUser 00000000000000000000000000000000");
    if (settingUpAddress != 'dummy') {
      initGeoFireListner();
    } else {
      rideType = 'Taxi';
      await displayTaxiTypeContainerHeight();
    }
  }

  void getCurrentLocation() async {
    print('GetCurrent Lcoation executed');

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    usercurrentLocation = position;
    Provider.of<AppData>(context, listen: false).updateMyLocation(position);

    String address =
        await AssistantMethods().searchCoordinateAddress(position, context);

    print('your address yo bellow' ' :: ${address}');
    if (settingUpAddress != 'dummy') {
      initGeoFireListner();
      print('we running ...............................');
    }
  }

  void initGeoFireListner() {
    Geofire.initialize("availableDrivers");

    print("inside init geo firelistner==============================");

    //comment
    Geofire.queryAtLocation(
            usercurrentLocation!.latitude, usercurrentLocation!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            print("onkeyentered==============================");
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);

            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            } else {
              print(
                  "near by available driver keys loaded  is falase==============================");
            }

            break;

          // when any driver goes offline

          case Geofire.onKeyExited:
            print("onkeyexited==============================");
            GeoFireAssistant.remobeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          //updating realtime location for drivers
          case Geofire.onKeyMoved:
            print("onkeymoved==============================");
            // Update your key's location
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];

            GeoFireAssistant.updateDriverNearByLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();

            break;

          // display on map

          case Geofire.onGeoQueryReady:
            print("onkeyready==============================");
            // All Intial Data is loaded
            updateAvailableDriversOnMap();
            break;
        }
      }
    });

    //comment
  }

  void updateAvailableDriversOnMap() {
    print('updateAvailableDriversOnMap running.............');
    markersSet.clear();

    Set<Marker> tMarkers = Set<Marker>();

    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvaiablePosition =
          LatLng(driver.latitude!, driver.longitude!);

      Marker marker = Marker(
        markerId: MarkerId('driver ${driver.key}'),
        position: driverAvaiablePosition,
        icon: nearByIcon!,
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMarkers.add(marker);
    }
    markersSet = tMarkers;
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/mapCar.png")
          .then((value) {
        nearByIcon = value;
        print(
            "icon assigned ---------------------------------------------------");
      });
    }
  }

  Future<void> getPlaceDirection() async {
    print("getplacedirections executed");
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    // currentLocation = Provider.of<AppData>(context, listen: false).pickUpLocation!.placeName;
    var finalPos;
    if (settingUpAddress == 'normal') {
      finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    } else if (settingUpAddress == 'home') {
      finalPos = homeAddress;
    } else if (settingUpAddress == 'work') {
      finalPos = workAddress;
    } else if (settingUpAddress == 'dummy') {
      print('requesting dummy address...');
      finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    } else {
      print('nibba drop address error');
    }

    var pickUpLapLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLapLng = LatLng(finalPos!.latitude, finalPos.longitude);
    print("getsinitial values");

    var details = await AssistantMethods.obtainDirectionDetails(
        pickUpLapLng, dropOffLapLng);

    setState(() {
      tripDirectionDetails = details;
    });

    print('this is encoded point');
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.lightBlueAccent,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (pickUpLapLng.latitude > dropOffLapLng.latitude &&
        pickUpLapLng.longitude > dropOffLapLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLapLng);
    } else if (pickUpLapLng.longitude > dropOffLapLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude),
          northeast: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude));
    } else if (pickUpLapLng.latitude > dropOffLapLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude),
          northeast: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLapLng, northeast: dropOffLapLng);
    }

    newGoogleMapControler!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "Current Location"),
      position: pickUpLapLng,
      markerId: MarkerId("pickUpId"),
    );
    markersSet.clear();
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Destination"),
      position: dropOffLapLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      circleId: CircleId("pickUpId"),
      fillColor: Colors.white,
      center: pickUpLapLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
    );

    Circle dropOffLocCircle = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.white,
      center: dropOffLapLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void saveRideRequest() {
    if (settingUpAddress != 'dummy') {
      nameRideRequest = userCurrentInfo!.name!;
      phoneRideRequest = userCurrentInfo!.phone!;
    }
    print("save ride request function chalo");
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Requests").push();

    print("Ride Request Ref ------------------------------");
    print(rideRequestRef!.key);
    rideRequestId = rideRequestRef!.key;

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp?.latitude.toString(),
      "longitude": pickUp?.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff?.latitude.toString(),
      "longitude": dropOff?.longitude.toString(),
    };

    Map rideInfoMap = {
      "drive_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo!.name,
      "ride_phone": userCurrentInfo!.phone,
      "pickup_address": pickUp?.placeName,
      "dropoff_address": dropOff?.placeName,
      "status": "looking driver",
      "rideTpye": rideType,
      "rideSubTpye": rideSubType,
      "referral_code": isPromoCode,
      "fare":
          AssistantMethods.calculateFares(tripDirectionDetails!, rideSubType),
      "distance_text": tripDirectionDetails!.distanceText,
      "distance_value": tripDirectionDetails!.distanceValue,
      "duration_text": tripDirectionDetails!.durationText,
      "duration_value": tripDirectionDetails!.durationValue,
      "pickup_short": pickUpShort,
      "pickup_rest": pickUpRest,
      "dropoff_short": dropOffShort,
      "dropoff_rest": dropOffRest
    };

    rideRequestRef!.set(rideInfoMap);
    readData();
    searchNearestDriver();
  }

  String setHintText() {
    if (rideType == 'Taxi') {
      return 'Enter Destination';
    } else if (rideType == 'Pet') {
      return 'Enter Pet PickUp Location';
    } else if (rideType == 'Package') {
      return 'Enter Drop-off Location';
    } else {
      return 'Enter Destination';
    }
  }

  void noDriverFound() {
    print('no driver found');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverAvailableDialog());
  }

  void cancelRideRequest() {
    rideRequestRef!.remove();
    resetApp();
  }

  void searchNearestDriver() {
    print('in search near driver');
    if (availableDrivers!.isEmpty) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      print('no drivers available--------------------------------');
      return;
    }
    print('driver found notification sent--------------------------------');

    var driver = availableDrivers![0];
    notifyDriver(driver);
    availableDrivers!.remove(0);
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    print("rideRequestRef Key === ${rideRequestRef!.key}");
    rideRequestId = rideRequestRef!.key;
    driversRef.child(driver.key!).child('newRide').set(rideRequestRef!.key);

    driversRef
        .child(driver.key!)
        .child('token')
        .once()
        .then((DatabaseEvent event) async {
      DataSnapshot snap = event.snapshot;
      print('driver token :: ');

      if (snap.exists) {
        String token = snap.value.toString();
        print(token);

        // AssistantMethods.sendNotificationToDriver(
        //     token, context, rideRequestRef!.key!);
      } else {
        print(
            'driver token doesnt exists--------------------------------------------');
      }
    });
  }

  void readData() async {
    rideStreamSubscription = rideRequestRef!.onValue;
    rideStreamSubscription.listen((DatabaseEvent event) async {
      var data = event.snapshot.value as Map;
      print(data);
      if (event.snapshot.value == null) {
        print('ride status is no ride exists');
        return;
      }
      if (data["status"] != null) {
        statusRide = data["status"]!.toString();
        print(statusRide);
      } else {
        print('no status');
      }

      if (statusRide == "accepted") {
        await Future.delayed(const Duration(seconds: 10));
        AssistantMethods.getRideDetails(context);
        print(rideDetails);
        await Future.delayed(const Duration(seconds: 10));
        print(rideDetails);
        displayDriverDetailsContainer();
      } else if (statusRide == 'arrived') {
        print('ride status is arrived');
        displayDriverWaitingDetails();
      } else if (statusRide == 'onride') {
        print('ride status is onRide');
        displayOnRideDetails();
      } else if (statusRide == 'ended') {
        print('ride status is Ended');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PaymentPage()),
            (route) => false);
      }
    });
  }

  Future<void> displayTaxiTypeContainerHeight() async {
    print("displayTaxiTypeContainerHeight fuction called");

    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 390;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      findDriverVisibility = false;
      orderDetailsVisibility = false;
      topBandVisbility = false;
      driverDetailsVisibility = false;
      topBandText = 'Finding Driver';
    });
  }

  Future<void> displayPromoCodeContainerHeight() async {
    print("displayTaxiTypeContainerHeight fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      findDriverVisibility = false;
      orderDetailsVisibility = false;
      topBandVisbility = false;
      driverDetailsVisibility = false;
      promoCodeContainerHeight = 290;
      topBandText = 'Finding Driver';
    });
  }

  Future<void> displayParcelTypeContainerHeight() async {
    print("displayParcelTypeContainerHeight fuction called");

    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 340;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;
      findDriverVisibility = false;
      topBandVisbility = false;
      driverDetailsVisibility = false;
      topBandText = 'Finding Driver';
    });
  }

  Future<void> displayPetTypeContainerHeight() async {
    print("displayPetTypeContainerHeight fuction called");

    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 330;
      orderDetailsVisibility = false;
      findDriverVisibility = false;
      topBandVisbility = false;
      driverDetailsVisibility = false;
      topBandText = 'Finding Driver';
    });
  }

  Future<void> displayRideDetailsContainerHeight() async {
    print("displayRideDetailsContainerHeight fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = true;
      findDriverVisibility = false;
      topBandVisbility = false;
      driverDetailsVisibility = false;
      promoCodeContainerHeight = 0;
      topBandText = 'Finding Driver';
    });
  }

  Future<void> displayFindingDriverContainer() async {
    print("displayFindingDriverContainer fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;
      findDriverVisibility = true;
      topBandVisbility = true;
      driverDetailsVisibility = false;
      topBandText = 'Finding Driver';
    });
    saveRideRequest();
  }

  Future<void> displayDriverDetailsContainer() async {
    print("displayDriverDetailsContainer fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;
      findDriverVisibility = false;
      topBandVisbility = true;
      driverDetailsVisibility = true;
      topBandText = 'Driver Arriving ';
    });
  }

  Future<void> displayDriverWaitingDetails() async {
    print("displayDriverDetailsContainer fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;
      findDriverVisibility = false;
      topBandVisbility = true;
      driverDetailsVisibility = true;
      topBandText = 'Driver Waiting';
    });
  }

  Future<void> displayOnRideDetails() async {
    print("displayDriverDetailsContainer fuction called");
    setState(() {
      searchContainerHeight = 0;
      findingDriverContainerHeight = 0;
      taxiTypeContainerHeight = 0;
      parcelTypeContainerHeight = 0;
      petTypeContainerHeight = 0;
      orderDetailsVisibility = false;
      findDriverVisibility = false;
      topBandVisbility = true;
      driverDetailsVisibility = true;
      topBandText = 'On Ride';
    });
  }
}
