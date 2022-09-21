import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_carride/Models/rideDetails.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Assistance/requestAssistant.dart';
import '../Models/address.dart';
import '../Models/allUsers.dart';
import '../Models/direactionDetails.dart';
import '../Models/history.dart';
import '../config.dart';
import '../main.dart';
import '../providers/appData.dart';

class AssistantMethods {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _endpoint = 'https://api.rnfirebase.io/messaging/send';
  final String _contentType = 'application/json';
  final String _authorization = serverToken;

  Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyCmWajWpkwewN2uRPUxU5Z21UZUzJ02fV4";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];

      st1 = response["results"][0]["address_components"][1]["long_name"];
      st2 = response["results"][0]["address_components"][2]["long_name"];
      st3 = response["results"][0]["address_components"][3]["long_name"];
      st4 = response["results"][0]["address_components"][4]["long_name"];
      // st5 = response["results"][0]["address_components"][5]["long_name"]; Country
      // st6 = response["results"][0]["address_components"][6]["long_name"]; Code

      placeAddress = st1 + ',' + st2 + ', ' + st3 + ', ' + st4;

      print('printing address yoyo st1 :: $st1');
      print('printing address yoyo st2 :: $st2');
      print('printing address yoyo st3 :: $st3');
      print('printing address yoyo st4 :: $st4');

      pickUpShort = st1;
      pickUpRest = st2 + ', ' + st3 + ', ' + st4;

      Address userPickUpAddress = new Address(
          placeAddress, placeAddress, position.latitude, position.longitude);

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);

      print("This is PickUp Short :: ");
      print("${pickUpShort}");
      print("This is PickUp Rest :: ");
      print("${pickUpRest}");
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=AIzaSyCmWajWpkwewN2uRPUxU5Z21UZUzJ02fV4';
    var res = await RequestAssistant.getRequest(directionUrl);

    print('res on assistanceMethod called');
    print(res);
    // if (res == "failed") {
    //   return "";
    // }
    DirectionDetails directionDetails = DirectionDetails(
        distanceValue: res["routes"][0]["legs"][0]["distance"]["value"],
        durationValue: res["routes"][0]["legs"][0]["duration"]["value"],
        distanceText: res["routes"][0]["legs"][0]["distance"]["text"],
        durationText: res["routes"][0]["legs"][0]["duration"]["text"],
        encodedPoints: res["routes"][0]["overview_polyline"]["points"]);

    print('printing direction details');
    print(directionDetails);
    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails, String subType) {
    if (subType == 'THL-Mini' ||
        subType == 'Small Parcel' ||
        subType == 'THL-Mini') {
      double totalFareAmount = (directionDetails.distanceValue / 1000) * 1.7;
      return totalFareAmount.truncate();
    } else if (subType == 'THL-Sedan' ||
        subType == 'Medium Parcel' ||
        subType == 'pet' ||
        subType == 'bird' ||
        subType == 'cat') {
      double totalFareAmount = (directionDetails.distanceValue / 1000) * 1.85;
      return totalFareAmount.truncate();
    } else if (subType == 'Maxi-Taxi' ||
        subType == 'THL-Super' ||
        subType == 'Large Parcel') {
      double totalFareAmount = (directionDetails.distanceValue / 1000) * 2;
      return totalFareAmount.truncate();
    } else {
      double totalFareAmount = (directionDetails.distanceValue / 1000) * 1.85;
      return totalFareAmount.truncate();
    }
  }

  static void getCurrentOnLineUserInfo(BuildContext context) async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = currentFirebaseUser!.uid;

    print('userUID = uid');
    DatabaseReference reference =
        await FirebaseDatabase.instance.ref().child("users").child(userId);

    DatabaseEvent event = await reference.once();
    DataSnapshot snap = event.snapshot;

    print(
        "--------------------------------------------------------------------------- /n \n "
        "getcurrentonlineUSerINfo");
    print(reference.key);
    print(snap.value);

    if (snap.exists) {
      userCurrentInfo = Users.fromSnapshot(snap);
      print("user current info printing ----------------");
      print(userCurrentInfo?.phone);

      Provider.of<AppData>(context, listen: false)
          .updateName(userCurrentInfo!.name!);
      Provider.of<AppData>(context, listen: false)
          .updateEmail(userCurrentInfo!.email!);
      Provider.of<AppData>(context, listen: false)
          .updatePhone(userCurrentInfo!.phone!);
    } else {
      return;
    }
    print(' getting out of current user info ................');
  }

  static void getRideDetails(BuildContext context) async {
    print(
        'getRideDetails ...............................................................................');
    print(rideRequestId);
    DatabaseReference reference = await FirebaseDatabase.instance
        .ref()
        .child("Ride Requests")
        .child(rideRequestId!);

    DatabaseEvent event = await reference.once();
    DataSnapshot snap = event.snapshot;

    if (snap.exists) {
      print(
          'snap exists ........................................................................................');
      rideDetails = await RideDetails.fromSnapshot(snap);
    }
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

  // Future<void> sendNotificationToUser({required String token});

  static sendNotificationToDriver(
      String token, context, String ride_request_id) async {
    var destination =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': serverToken,
    };

    Map notificationMap = {
      'body': 'DropOff Address, ${destination!.placeName}',
      'title': 'New Ride Request',
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': ride_request_id,
    };

    Map sendNotificationMap = {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "token": token,
    };

    if (token == null) {
      print("Token Is Null --------------------------------");
    }

    try {
      print("Token is This ::");
      print(token);

      await http
          .post(Uri.parse('https://api.rnfirebase.io/messaging/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(sendNotificationMap))
          .catchError((onError) {
        print(onError);
      });

      print("FCM request for device sent=================");
    } catch (e) {
      print(e);
    }
  }

  static void obtainTripRequestsHistoryData(BuildContext context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      newRequestRef.child(key).once().then((DatabaseEvent event) {
        DataSnapshot snap = event.snapshot;
        if (snap.exists) {
          print(snap);
          var history = History.fromSnapshot(snap);
          Provider.of<AppData>(context, listen: false)
              .updateTripHistoryData(history);
        }
      });
    }
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        '${DateFormat.MMMd().format(dateTime)},${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}';

    return formattedDate;
  }
}
