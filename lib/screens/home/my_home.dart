import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grab_carride/screens/home/widgets/btn_main_menus.dart';

import '../../config.dart';
import '../authentications/mapscreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        toolbarHeight: screenHeight / 10,
        backgroundColor: Colors.green.shade500,
        flexibleSpace: SafeArea(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/hailMini.png",
                    height: 80,
                    width: 80,
                  ),
                  Text(
                    'Hail A Taxi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  )
                ],
              )),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BtnMainMenus(),
              SizedBox(
                height: screenHeight / 40,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenHeight / 20),
                child: Container(
                    height: screenHeight / 6,
                    padding: EdgeInsets.only(left: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade500,
                            blurRadius: 2,
                            //spreadRadius: 0.5,
                            //  offset: Offset(0.7, 0.7),
                          ),
                        ],
                        color: Colors.white54,
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: screenHeight / 15,
                              ),
                              Text(
                                'Where you want to go?',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    wordSpacing: 4),
                              ),
                              SizedBox(
                                height: screenHeight / 200,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      rideType = 'Taxi';
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MapScreen()));
                                    },
                                    child: Text(
                                      'Enter destionation',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth / 30,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight / 100,
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          height: screenHeight / 6,
                          child: Image.asset(
                            "images/travelBack.png",
                          ),
                        )
                      ],
                    )),
              ),
              SizedBox(
                height: screenHeight / 40,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenHeight / 20),
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10, left: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade500,
                          blurRadius: 2,
                          //spreadRadius: 0.5,
                          //  offset: Offset(0.7, 0.7),
                        ),
                      ],
                      color: Colors.white54,
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn to use the app',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            wordSpacing: 4),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.help,
                        color: Colors.black54,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
