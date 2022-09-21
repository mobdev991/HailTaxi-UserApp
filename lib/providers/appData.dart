import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import '../Models/address.dart';
import '../Models/address.dart';
import '../Models/history.dart';

class AppData with ChangeNotifier {
  Address? pickUpLocation, dropOffLocation;
  Position? myPosition;
  String userName = "N/D";
  String userEmail = "N/D";
  String userPhone = "N/D";

  int numberOfTrips = 0;

  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];


  void updateMyLocation(Position updatePosition) {
    myPosition = updatePosition;
    notifyListeners();
  }

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  // profiled Data // functions for that.

  void updateName(String updatedName) {
    print('Name in AppData');
    userName = updatedName;
    print(userName);
    notifyListeners();
  }
  void updateEmail(String updatedEmail) {
    print('Email in AppData');
    userEmail = updatedEmail;
    print(userEmail);
    notifyListeners();
  }

  void updatePhone(String updatedPhone) {
    print('Name in AppData');
    userPhone = updatedPhone;
    print(userPhone);
    notifyListeners();
  }
  // late Address pickUpLocation;
  //
  // void updatePickUpLocationAddress(Address pickUpAddress) {
  //   pickUpLocation = pickUpAddress;
  //   notifyListeners();
  // }

  void updateNumberOfTrips(int updatedNumberOfTrips) {
    print('earnings in AppData');
    numberOfTrips = updatedNumberOfTrips;
    print('Number Of Trips in Appdata');
    print(numberOfTrips);
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistoryData(History eachHistory) {
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }
}
