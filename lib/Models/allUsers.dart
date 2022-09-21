import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? phone;
  String? name;
  String? pic;
  String? apoints;
  String? invitationCode;
  String? referralCode;
  String? accountStatus;

  Users({this.id, this.email, this.phone, this.name});

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;

    var data = dataSnapshot.value as Map?;

    if (data != null) {
      email = data["email"];
      name = data["name"];
      phone = data["phone"];
      pic = data["pic"];
      apoints = data["activity_points"];
      invitationCode = data["invitationCode"];
      referralCode = data["referralCode"];
      accountStatus = data["pstatus"];
    }
  }
}
