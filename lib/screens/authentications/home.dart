import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grab_carride/screens/authentications/phone_number.dart';
import 'package:grab_carride/screens/authentications/set_destination_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../Assistance/assistanceMethods.dart';
import '../../config.dart';
import '../../providers/appData.dart';
import 'mapscreen.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xE61978), // used
      // backgroundColor: Color(0xFF00843B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Image(
                image: AssetImage("images/hail.png"),
                height: 300.0,
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50.0,
                      width: 300.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Phone_number()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          "Log In Account!",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50.0,
                    width: 300.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        settingUpAddress = 'dummy';
                        getCurrentLocation();
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SetDestination()));
                        // print(
                        //     "is of homepage is getting printed");
                        print(res);
                        if (res == "dummy") {
                          print('we got response');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen()));
                          print('response :: $res');
                        }
                        // }
                        else {
                          print('no response :: $res');
                          // displayToastMessage(
                          //     "Need Location Permission",
                          //     context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        "Enter Destination!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  void initState() {
    checkPermission();
    super.initState();
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
                      color: Colors.indigo)),
              content: Text(
                'This APP collects location Data to enable "Ride Request" and "Location Tracking" Features, even when the app is closed or not in use',
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
                          color: Colors.indigo)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Allow',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  onPressed: () {
                    Permission.location.request();
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }
}
