import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_carride/providers/appData.dart';
import 'package:grab_carride/screens/authentications/home.dart';
import 'package:grab_carride/screens/authentications/phone_number.dart';
import 'package:provider/provider.dart';

import '../../Assistance/assistanceMethods.dart';
import '../../Assistance/geoFireAssistance.dart';
import '../../Models/direactionDetails.dart';
import '../../Models/nearByAvailableDrivers.dart';

class MapScreenDummy extends StatefulWidget {
  @override
  _MapScreenDummyState createState() => _MapScreenDummyState();
}

class _MapScreenDummyState extends State<MapScreenDummy> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  Position? usercurrentLocation;
  bool nearbyAvailableDriverKeysLoaded = false;
  BitmapDescriptor? nearByIcon;

  static const colorizeColors = [
    Colors.blue,
    Colors.lightBlueAccent,
    Colors.blueGrey,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontFamily: 'Horizon',
  );

  double rideDetailsContainerHeight = 0;
  double ridePlanContainer = 0;

  double searchContainerHeight = 200; //225
  double driverArrivingContainerHeight = 0;
  double driverOnSpotContainerHeight = 0;
  double rideStartedContainerHeight = 0;

  double findingRioOneContainerHeight = 0;
  double findingRioTwoContainerHeight = 0;
  double findingDriverContainerHeight = 0;

  double rioOneArrivingContainerHeight = 0;
  double rioOneArrivedOnSpotContainerHeight = 0;
  double rioOneRidingContainerHeight = 0;

  double rioTwoArrivingContainerHeight = 0;
  double rioTwoArrivedOnSpotContainerHeight = 0;
  double rioTwoRidingContainerHeight = 0;

  double travelOnTrainContainerHeight = 0;

  late Stream<DatabaseEvent> rideStreamSubscription;

  GoogleMapController? newGoogleMapControler;
  DirectionDetails? tripDirectionDetails;
  DatabaseReference? rideRequestRef;

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
    target: LatLng(31.5204, 74.3587),
    zoom: 14.4746,
  );

  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  List<LatLng> pLineCoordinates = [];
  List<NearbyAvailableDrivers>? availableDrivers;

  Color miniContainerColor = Colors.white;
  Color goContainerColor = Colors.white;
  Color buzzContainerColor = Colors.white;
  Color familyContainerColor = Colors.white;

  GlobalKey<ScaffoldState> _scaffoldKEY = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  @override
  void initState() {
    print(
        'mapscreen  dummy running 0000000000000000000000000000000000000000000000000000');
    print('UserName ${Provider.of<AppData>(context, listen: false).userName}');
    print(
        'UserEmail ${Provider.of<AppData>(context, listen: false).userEmail}');
    print(
        'UserPhone ${Provider.of<AppData>(context, listen: false).userPhone}');
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    getPlaceDirection();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
                padding: EdgeInsets.only(bottom: 200),
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
                  availableDrivers =
                      GeoFireAssistant.nearByAvailableDriversList;
                  print(
                      'in google maap ........................................');
                }),
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Container(
                height: searchContainerHeight,
                color: Colors.grey.shade100,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.add_location,
                          color: Colors.green,
                          size: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Estimated Fare',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey)),
                        SizedBox(
                          width: 35,
                        ),
                        Text('\$ 2.5',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.green))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.add_location,
                          color: Colors.green,
                          size: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Estimated Time',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey)),
                        SizedBox(
                          width: 35,
                        ),
                        Text('20 m',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.green))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Phone_number()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                            ),
                            child: Text('Login!')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => home()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey),
                            ),
                            child: Text('Cancel')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

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
}
