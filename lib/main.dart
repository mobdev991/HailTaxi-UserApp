import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grab_carride/providers/appData.dart';
import 'package:grab_carride/screens/authentications/home.dart';
import 'package:grab_carride/screens/main/loading_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GrabCloneUI());
}

DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
DatabaseReference referralCodeRef =
    FirebaseDatabase.instance.ref().child("Referral Code");

DatabaseReference newRequestRef =
    FirebaseDatabase.instance.ref().child("Ride Requests");

class GrabCloneUI extends StatelessWidget {
  const GrabCloneUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Your title app",
          home: FirebaseAuth.instance.currentUser == null
              ? home()
              : LoadingScreen()
          // home(),
          //MainScreen(),
          ),
    );
  }
}
