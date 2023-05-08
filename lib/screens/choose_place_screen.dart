import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseOnMap extends StatefulWidget {
  final Function(LatLng loc) onMapTap;
  LatLng? initExamLoc;
  ChooseOnMap({super.key, required this.onMapTap, this.initExamLoc});

  @override
  State<ChooseOnMap> createState() => _ChooseOnMapState();
}

class _ChooseOnMapState extends State<ChooseOnMap> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _examLoc;

  @override
  void initState() {
    setState(() {
      _examLoc = widget.initExamLoc;
    });
    super.initState();
  }

  Future<void> setInitCameraPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
    }
    Position currentPosition = await Geolocator.getCurrentPosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15,
        target: LatLng(currentPosition.latitude, currentPosition.longitude))));
  }

  void _handleTap(LatLng loc) {
    setState(() {
      _examLoc = loc;
    });
    widget.onMapTap(loc);
  }

  @override
  Widget build(BuildContext context) {
    setInitCameraPosition();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exam Location'),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition:
            const CameraPosition(target: LatLng(0, 0), zoom: 10),
        onMapCreated: (controller) => {_controller.complete(controller)},
        markers: _examLoc == null
            ? {}
            : {
                Marker(
                    markerId: const MarkerId('exam-location'),
                    position: _examLoc!)
              },
        onTap: _handleTap,
      ),
    );
  }
}
