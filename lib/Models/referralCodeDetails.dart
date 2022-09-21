import 'package:firebase_database/firebase_database.dart';

class ReferralDetails {
  String userID = ' ';
  String? totalTokensEarned;
  String userSignedUp = ' ';

  ReferralDetails({
    required this.userID,
    required this.totalTokensEarned,
    required this.userSignedUp,
  });

  ReferralDetails.fromSnapshot(DataSnapshot dataSnapshot) {
    var data = dataSnapshot.value as Map?;
    print(' datasnapshot of driverss ::');
    print(dataSnapshot.value);

    if (data != null) {
      userID = data["userID"];
      totalTokensEarned = data["totalTokensEarned"];
      userSignedUp = data["userSignedUp"];
    }
  }
}
