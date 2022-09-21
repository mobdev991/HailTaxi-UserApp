import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_carride/Assistance/assistanceMethods.dart';
import 'package:grab_carride/screens/account/profile_page.dart';
import 'package:grab_carride/screens/activity/activity.dart';
import 'package:grab_carride/screens/home/my_home.dart';
import 'package:grab_carride/screens/messages/messages.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/appData.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GoogleMapController? newGoogleMapControler;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: TabBarView(
            children: [
              Home(),
              Activity(),
              Messages(),
              ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 2, spreadRadius: 0)
          ], color: Colors.white),
          child: TabBar(
            labelColor: Color(0xFF00843B),
            indicatorColor: Colors.transparent,
            labelPadding: EdgeInsets.all(0.5),
            indicatorWeight: 1,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
            unselectedLabelColor: Colors.black45,
            tabs: [
              Tab(
                icon: Icon(LineAwesomeIcons.compass),
                iconMargin: EdgeInsets.only(bottom: 5),
                text: "Home",
              ),
              Tab(
                icon: Icon(LineAwesomeIcons.newspaper),
                iconMargin: EdgeInsets.only(bottom: 5),
                text: "Activity",
              ),
              Tab(
                icon: Icon(LineAwesomeIcons.comment_dots),
                iconMargin: EdgeInsets.only(bottom: 5),
                text: "Messages",
              ),
              Tab(
                icon: Icon(LineAwesomeIcons.user_circle),
                iconMargin: EdgeInsets.only(bottom: 5),
                text: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    AssistantMethods.getCurrentOnLineUserInfo(context);
    checkPermission();
    getCurrentLocation();
    super.initState();
  }

  void getCurrentLocation() async {
    print('GetCurrent Lcoation executed');

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Provider.of<AppData>(context, listen: false).updateMyLocation(position);

    String address =
        await AssistantMethods().searchCoordinateAddress(position, context);

    print('your address yo bellow' ' :: ${address}');
    // currentLocationText = address;
    // initGeoFireListner();
  }

  void checkPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      print('location permission is denied..............................');
    } else {
      print('location permission is NOT denied..............................');
    }

    if (status.isRestricted) {
      print('location permission is Restricted..............................');
    } else {
      print(
          'location permission is NOT Restricted..............................');
    }

    if (status.isPermanentlyDenied) {
      print(
          'location permission is PermanentlyDenied..............................');
    } else {
      print(
          'location permission is NOT PermanentalyDenied..............................');
    }
    if (status.isGranted) {
      print('location permission is Granted..............................');
    } else {
      showRequestPermissionDialog();
    }
  }

  void showRequestPermissionDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Location Permission',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              content: Text(
                'THL collects location Data to enable "Ride Request" and "Location Tracking" Features, even when the app is closed or not in use',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Allow',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  onPressed: () {
                    // appPermissioncheck = false;
                    Navigator.pop(context);
                    Permission.location.request();
                  },
                ),
              ],
            ));
  }
}
