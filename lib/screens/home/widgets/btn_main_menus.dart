import 'package:flutter/material.dart';
import 'package:grab_carride/config.dart';
import 'package:grab_carride/screens/authentications/mapscreen.dart';

class BtnMainMenus extends StatefulWidget {
  const BtnMainMenus({Key? key}) : super(key: key);

  @override
  _BtnMainMenusState createState() => _BtnMainMenusState();
}

class _BtnMainMenusState extends State<BtnMainMenus> {
  @override
  Widget build(BuildContext context) {
    return //  main menu
        Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  rideType = 'Taxi';
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapScreen()));
                },
                child: Container(
                  padding: EdgeInsets.all(0),
                  width: 120,
                  height: 115,
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
                  child: Column(
                    children: [
                      Image.asset(
                        "images/mainIconTaxi.png",
                        height: 80,
                        width: 80,
                      ),
                      Text(
                        'Taxi',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  rideType = 'Package';
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapScreen()));
                },
                child: Container(
                  padding: EdgeInsets.only(top: 5),
                  width: 120,
                  height: 115,
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
                  child: Column(
                    children: [
                      Image.asset(
                        "images/mediumBox.png",
                        height: 70,
                        width: 70,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Package',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            //  ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  rideType = 'Pet';
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapScreen()));
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  width: 120,
                  height: 115,
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
                  child: Column(
                    children: [
                      Image.asset(
                        "images/petIcon.png",
                        height: 80,
                        width: 80,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Pet Care',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: 120,
                height: 115,
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
                child: Column(
                  children: [
                    Image.asset(
                      "images/supporIcon.png",
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      'Support',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
            //  ),
          ),
        ],
      ),
    );
  }
}
