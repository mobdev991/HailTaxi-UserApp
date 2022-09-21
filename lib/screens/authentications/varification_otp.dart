import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grab_carride/screens/authentications/signup.dart';
import 'package:grab_carride/screens/main/main_screen.dart';

import '../../config.dart';

class Otp extends StatefulWidget {
  String phoneNumber;
  Otp(this.phoneNumber);

  @override
  _OtpState createState() => _OtpState(this.phoneNumber);
}

class _OtpState extends State<Otp> {
  bool signinError = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String statusCode = '';

  TextEditingController phoneController =
      TextEditingController(text: "+923XXAAAAAAA");
  TextEditingController otpController = TextEditingController();

  bool otpVisibility = false;
  bool isButtonActive = true;
  String verificationID = "";
  String jazz = "";
  String numberPhone;
  _OtpState(this.numberPhone);

  @override
  void initState() {
    loginWithPhone(numberPhone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Verification Page :: ${numberPhone}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfff7f6fb),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(
                height: 18,
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                'Verification',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter your OTP code number",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 28,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 200,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: TextField(
                          autofocus: true,
                          controller: otpController,
                          showCursor: false,
                          readOnly: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            counter: Offstage(),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.green),
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 2, color: Colors.green),
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print(otpController.text);
                          verifyOTP(otpController.text);
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Verify',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Didn't you receive any code?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Resend New Code",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldOTP({bool? first, last}) {
    return Container(
      height: 55,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.green),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void loginWithPhone(String phoneNumber) async {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (context) => HomePage()),
          //         (route) => false);
          print(
              "you are in then :: signInWithCredential in Function :: in Verify OTP");
          print('value :: $value');

          if (value.user != null) {
            currentFirebaseUser = value.user;
            print('user is not null');
            print(currentFirebaseUser);

            if (value.additionalUserInfo!.isNewUser) {
              print('new user :: ${value.additionalUserInfo!.isNewUser}');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => signuppage()),
                  (route) => false);
            } else {
              print('this user is not new :: should go to home page');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false);
            }
          } else {
            print('user is null.. no user created  or exists');
          }

          Fluttertoast.showToast(
              msg: "You are logged in successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.indigo,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verification is faild :: below is the reason why it failed ::');
        print(e.message);
        setState(() {
          isButtonActive = true;
          statusCode = ' Verification Failed :: Please Try Later :: $e';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;

        verificationID = verificationId;
        print('value :: ${phoneController.text}');
        print('code sent --- verificationID :: $verificationId :: yo');
        setState(() {
          statusCode = ' Code Sent ';
          isButtonActive = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP(String verifyCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: verifyCode);

    await auth.signInWithCredential(credential).then((value) {
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => HomePage()),
      //         (route) => false);
      print(
          "you are in then :: signInWithCredential in Function :: in Verify OTP");
      print('value :: $value');

      if (value.user != null) {
        currentFirebaseUser = value.user;
        print('user is not null');
        print(currentFirebaseUser);

        if (value.additionalUserInfo!.isNewUser) {
          print('new user :: ${value.additionalUserInfo!.isNewUser}');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => signuppage()),
              (route) => false);
        } else {
          print('this user is not new :: should go to home page');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (route) => false);
        }
      } else {
        print('user is null.. no user created  or exists');
      }

      Fluttertoast.showToast(
          msg: "You are logged in successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.indigo,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
