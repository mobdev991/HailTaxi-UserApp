import 'package:flutter/material.dart';
import 'package:grab_carride/config.dart';
import 'package:grab_carride/screens/authentications/mapscreen.dart';
import 'package:provider/provider.dart';

import '../../Assistance/requestAssistant.dart';
import '../../Models/address.dart';
import '../../Models/placePredictions.dart';
import '../../main.dart';
import '../../providers/appData.dart';
import '../main/main_screen.dart';

class SetDestination extends StatefulWidget {
  const SetDestination({Key? key}) : super(key: key);

  @override
  _SetDestinationState createState() => _SetDestinationState();
}

class _SetDestinationState extends State<SetDestination> {
  TextEditingController _currentLocationEditingController =
      TextEditingController();
  TextEditingController _destinationEditTextControler = TextEditingController();

  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ??
            "Getting Your Current Location";
    _currentLocationEditingController.text = placeAddress;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: Colors.green,
                    ),
                    label: Text(
                      'BACK',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    onPressed: () {
                      // print(placeAddress);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Select Destination',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.share_location,
                          color: Colors.green,
                        ),
                        Expanded(
                          child: ChangeNotifierProvider<AppData>(
                            create: (context) => AppData(),
                            child: Consumer<AppData>(
                              builder: (ctx, provider, child) {
                                return Column(
                                  // decoration: BoxDecoration(
                                  //     // color: Colors.grey,
                                  //     borderRadius:
                                  //         BorderRadius.circular(16)),
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 14),
                                      child: TextFormField(
                                        controller:
                                            _currentLocationEditingController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: ('Pickup Locaion'),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                      height: 10,
                      thickness: 0.5,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                        // SizedBox(
                        //   width: 15,
                        // ),
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  // color: Colors.grey,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: TextFormField(
                                  onChanged: (val) {
                                    findPlace(val);
                                  },
                                  controller: _destinationEditTextControler,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Destination',
                                  ),
                                ),
                              )),
                        ),
                        Icon(
                          Icons.mic,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (placePredictionList.length > 0)
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return PredictionTile(
                            placePredictions: placePredictionList[index]);
                      },
                      separatorBuilder: (BuildContext ctx, int index) =>
                          const Divider(
                        thickness: 1, // thickness of the line
                        indent:
                            20, // empty space to the leading edge of divider.
                        endIndent:
                            20, // empty space to the trailing edge of the divider.
                        color: Colors
                            .black26, // The color to use when painting the line.
                        height: 20, // The divider's height extent.
                      ),
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Text('No Suggestions'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Favourite Locations',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.grey,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Icon(
                      Icons.work,
                      color: Colors.grey,
                    ),
                    Text(
                      'work',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Recent Locations',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteurl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=establishment&location=37.76999%2C-122.44696&radius=500&key=AIzaSyCmWajWpkwewN2uRPUxU5Z21UZUzJ02fV4&components=country:pak';

      var res = await RequestAssistant.getRequest(autoCompleteurl);
      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJason(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  var placePredictions;

  PredictionTile({Key? key, required this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_location,
                  color: Colors.grey,
                  size: 40,
                ),
                SizedBox(
                  width: 14,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0, color: Colors.green)),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      placePredictions.secondary_text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    String st1, st2, st3, st4, st5, st6, st7, st8, placeAddress;
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyCmWajWpkwewN2uRPUxU5Z21UZUzJ02fV4';
    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      st1 = res["result"]["name"];
      st2 = res["result"]["address_components"][1]["long_name"];
      st3 = res["result"]["address_components"][2]["short_name"];
      st4 = res["result"]["address_components"][5]["short_name"];

      placeAddress = st1 + ', ' + st2 + ', ' + st3 + ', ' + st4;
      dropOffShort = st1;
      dropOffRest = st2 + ', ' + st3 + ', ' + st4;
      print('printing address yoyo st1 :: $st1');
      print('printing address yoyo st2 :: $st2');
      print('printing address yoyo st3 :: $st3');
      print('printing address yoyo st6 :: $st4');

      Address address = Address(
          placeAddress,
          placeId,
          res["result"]["geometry"]["location"]["lat"],
          res["result"]["geometry"]["location"]["lng"]);

      if (settingUpAddress == 'normal') {
        Provider.of<AppData>(context, listen: false)
            .updateDropOffLocationAddress(address);
      } else if (settingUpAddress == 'home') {
        homeAddress = address;
      } else if (settingUpAddress == 'work') {
        workAddress = address;
      } else if (settingUpAddress == 'dummy') {
        print('setting up address is dummy .......');
        Provider.of<AppData>(context, listen: false)
            .updateDropOffLocationAddress(address);
      } else {
        print('setting up address error.............');
      }

      print("This is Drop Off Location :: ");
      print(address.placeName);
      print("This is Drop Off Short :: ");
      print("${dropOffShort}");
      print("This is Drop Off Rest :: ");
      print("${dropOffRest}");

      Map addressMap = {
        "plance_name": placeAddress,
        "place_id": placeId,
        "place_lng": res["result"]["geometry"]["location"]["lat"].toString(),
        "place_long": res["result"]["geometry"]["location"]["lng"].toString(),
      };

      // userRef
      //     .child(currentFirebaseUser!.uid)
      //     .child('home_address')
      //     .set(addressMap);

      if (settingUpAddress == 'normal') {
        print('setting-up-address   $settingUpAddress');
        //normal
        Navigator.pop(context, "normal");
      } else if (settingUpAddress == 'home') {
        print('setting-up-address   $settingUpAddress');
        userRef
            .child(userCurrentInfo!.id!)
            .child('home_address')
            .set(addressMap);
        // setting up home
        Navigator.pop(context, "home");
      } else if (settingUpAddress == 'work') {
        print('setting-up-address   $settingUpAddress');
        userRef
            .child(userCurrentInfo!.id!)
            .child('work_address')
            .set(addressMap);
        // setting up office
        Navigator.pop(context, "work");
      } else if (settingUpAddress == 'dummy') {
        print('setting-up-address   $settingUpAddress');
        // before login
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (
              context,
            ) =>
                    MapScreen()),
            (route) => false);
      } else {
        print('setting-up-address   $settingUpAddress');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false);
      }
    }
  }
}
