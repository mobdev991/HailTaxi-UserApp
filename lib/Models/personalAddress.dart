import 'package:firebase_database/firebase_database.dart';

class PersonalAddress {
  String placeName = ' ';
  String placeID = ' ';
  String latitude = ' ';
  String longitude = ' ';

  PersonalAddress(
      {required this.placeName,
      required this.placeID,
      required this.latitude,
      required this.longitude});

  PersonalAddress.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map?;

    if (data != null) {
      placeName = data["plance_name"];
      placeID = data["place_id"];
      latitude = data["place_lng"];
      longitude = data["place_long"];
    } else {
      return;
    }
  }
}
