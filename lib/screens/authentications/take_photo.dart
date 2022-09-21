import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grab_carride/config.dart';
import 'package:grab_carride/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main/loading_screen.dart';

class Takephoto extends StatefulWidget {
  const Takephoto({Key? key}) : super(key: key);

  @override
  State<Takephoto> createState() => _TakephotoState();
}

class _TakephotoState extends State<Takephoto> {
  UploadTask? task;
  File? image;
  String? picURL;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                height: 18,
              ),
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/addpic.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Text(
                    'Adding photos Ease\nPickups',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Drivers often use picture to confirm\n that you are the correct ride",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Colors.green,
                        size: 30,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        "Take Photo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.green,
                        size: 30,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        "Chose from Library",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => LoadingScreen()));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoadingScreen()));
        },
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 29,
        ),
        backgroundColor: Colors.green,
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future pickImage() async {
    checkStoragePermission();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);

    String destination = 'profilepictures/$imageTemporary';
    this.image = imageTemporary;

    task = uploadFile(
      destination,
      this.image!,
    );

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      picURL = urlDownload;
    });
    print('Download-Link: $urlDownload');

    userRef.child(currentFirebaseUser!.uid).child('pic').set(urlDownload);
  }

  static firebase_storage.UploadTask? uploadFile(
      String destination, File file) {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on firebase_storage.FirebaseException catch (e) {
      return null;
    }
  }

  void checkStoragePermission() async {
    var status = await Permission.storage.status;

    if (status.isDenied) {
      print('location permission is denied..............................');
    } else {
      print('location permission is NOT denied..............................');
    }

    if (status.isRestricted) {
      print('location permission is Restricted..............................');
    } else {
      print(
          'location permission is NOT Restricted..............................');
    }

    if (status.isPermanentlyDenied) {
      print(
          'location permission is PermanentlyDenied..............................');
    } else {
      print(
          'location permission is NOT PermanentalyDenied..............................');
    }
    if (status.isGranted) {
      print('location permission is Granted..............................');
    } else {
      showRequestPermissionDialog();
    }
  }

  void showRequestPermissionDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Storage Permission',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              content: Text(
                'This APP Need Storage permission to access your Gallary and upload a photo',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Allow',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  onPressed: () {
                    Permission.storage.request();
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }
}
