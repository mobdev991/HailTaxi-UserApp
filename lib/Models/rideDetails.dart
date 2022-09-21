import 'package:firebase_database/firebase_database.dart';

class RideDetails {
  String? idRideRequest;
  String? nameRider;
  String? phoneRider;
  String? pickUpShort;
  String? dropOfShort;
  String? pickUpRest;
  String? dropOfRest;
  int? fareRide;
  String? picDriver;
  String? nameDriver;
  String? phoneDriver;
  String? carName;
  String? carNumber;
  String? carColor;
  String? referralCode;

  RideDetails(
      {this.idRideRequest,
      this.nameRider,
      this.phoneRider,
      this.pickUpShort,
      this.pickUpRest,
      this.dropOfShort,
      this.dropOfRest,
      this.fareRide,
      this.picDriver,
      this.nameDriver,
      this.phoneDriver,
      this.carName,
      this.carNumber,
      this.carColor,
      this.referralCode});

  RideDetails.fromSnapshot(DataSnapshot dataSnapshot) {
    idRideRequest = dataSnapshot.key!;

    var data = dataSnapshot.value as Map?;

    if (data != null) {
      nameRider = data["rider_name"];
      phoneRider = data["ride_phone"];
      // pickup
      pickUpShort = data["pickup_short"];
      pickUpRest = data["pickup_rest"];
      // dropoff
      dropOfShort = data["dropoff_short"];
      dropOfRest = data["dropoff_rest"];
      // fare
      fareRide = data["fare"];
      // driver details
      picDriver = data["driver_pic"];
      nameDriver = data["driver_name"];
      phoneDriver = data["driver_phone"];
      // car details
      carName = data["car_details"]["car_name"];
      carNumber = data["car_details"]["car_number"];
      carColor = data["car_details"]["car_color"];
      // referralcode
      referralCode = data["referral_code"];
    }
  }
}
