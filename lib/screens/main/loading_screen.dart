import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grab_carride/Models/address.dart';
import 'package:grab_carride/Models/personalAddress.dart';
import 'package:grab_carride/config.dart';
import 'package:grab_carride/main.dart';

import '../../Assistance/assistanceMethods.dart';
import '../../Models/referralCodeDetails.dart';
import 'main_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SpinKitFadingCube(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }

  void waitBeforeMove() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    print(
        'in wait before move .................................Get Current User Info');
    AssistantMethods.getCurrentOnLineUserInfo(context);
    print(
        'in wait before move .................................Read Work and Home');
    readHomeAdd();
    readWorkAdd();
    print('yo1');
    await Future.delayed(const Duration(seconds: 4));
    //assign that data to homeaddress veriable
    print('wait one over nibba');
    if (homeAd != null) {
      print(
          'homeT address................................................................');
      print(homeAd!.placeName);
      homeAddress = Address(
        homeAd!.placeName,
        homeAd!.placeID,
        double.parse(homeAd!.latitude),
        double.parse(homeAd!.longitude),
      );
    }
    //assign that data to workaddress veriable
    if (workAd != null) {
      print(
          'workT address ................................................................');
      print(workAd!.placeName);

      workAddress = Address(
        workAd!.placeName,
        workAd!.placeID,
        double.parse(workAd!.latitude),
        double.parse(workAd!.longitude),
      );
    }
    await Future.delayed(const Duration(seconds: 4));
    print('yo2');
    // setDate();
    if (userCurrentInfo != null) {
      print('usercurrent info is no null .................................');
      await getReferralInfo();
      if (referralInformation != null) {
        print(
            'referral information is no null .................................');
        //continue
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false);
      } else {
        print('referral information is null .................................');
        //refresh
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoadingScreen()),
            (route) => false);
      }
    } else {
      print('user current info is null .................................');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoadingScreen()),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    print('in wait before move .................................');
    waitBeforeMove();
    print('out wait before move ..................................');
  }

  // read data in home_address
  void readHomeAdd() {
    userRef
        .child(currentFirebaseUser!.uid)
        .child('home_address')
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot snap = event.snapshot;
      if (snap.exists) {
        homeAd = PersonalAddress.fromSnapshot(snap);
      } else {
        return;
      }
    });
  }

//read data in work_address
  void readWorkAdd() {
    userRef
        .child(currentFirebaseUser!.uid)
        .child('work_address')
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot snap = event.snapshot;
      if (snap.exists) {
        workAd = PersonalAddress.fromSnapshot(snap);
      } else {
        return;
      }
    });
  }

  // get Referral info
  Future<void> getReferralInfo() async {
    print('Driver Information ${userCurrentInfo!.referralCode}');
    if (userCurrentInfo != null) {
      referralCodeRef
          .child(userCurrentInfo!.referralCode!)
          .once()
          .then((DatabaseEvent event) {
        print("datasnap value in makedriver online..........................");
        DataSnapshot snap = event.snapshot;
        print(snap.value);
        if (snap.exists) {
          print(
              'driverInformation assigned!!.................................');
          referralInformation = ReferralDetails.fromSnapshot(snap);
        } else {
          return;
        }
      });
    } else {
      return;
    }
    print('out of assign referral code information.........................');
  }
}
