import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OnRideScreen extends StatefulWidget {
  const OnRideScreen({Key? key}) : super(key: key);

  @override
  State<OnRideScreen> createState() => _OnRideScreenState();
}

class _OnRideScreenState extends State<OnRideScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-33.873652, 151.204629),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              myLocationEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              initialCameraPosition: _kGooglePlex,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
            ),
            // Driver and vehicle details
          ],
        ),
      ),
    );
  }
}
