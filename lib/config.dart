import 'package:firebase_auth/firebase_auth.dart';
import 'package:grab_carride/Models/address.dart';
import 'package:grab_carride/Models/personalAddress.dart';
import 'package:grab_carride/Models/rideDetails.dart';

import 'Models/allUsers.dart';
import 'Models/referralCodeDetails.dart';

String apiKey = 'AIzaSyCmWajWpkwewN2uRPUxU5Z21UZUzJ02fV4';

//Firebase Variables
User? currentFirebaseUser;

// User? firebaseUser;

Users? userCurrentInfo;
RideDetails? rideDetails;

String serverToken =
    'key=AAAA_XTK3yU:APA91bFWm-dd5YWtENXCJsnbaQeHG_tDKn2ty7ukYlFGB4b9Ko6tC2Uj0Xg_u8ercgmCHjRXrc8_j2dkGVgwf4i4BUaWfB4vxKd9WM3blcJvhA2BIy4qYlSoOdqQtJ5h1ynsNRx2bs9F';

String statusRide = " ";

String? rideRequestId;

String rideType = 'Nil';
String rideSubType = 'Nil';

String pickUpShort = 'Nil';
String pickUpRest = 'Nil';
String dropOffShort = 'Nil';
String dropOffRest = 'Nil';

String settingUpAddress = 'NA';

ReferralDetails? referralInformation;

PersonalAddress? homeAd;
PersonalAddress? workAd;

Address? homeAddress;
Address? workAddress;
