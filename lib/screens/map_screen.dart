import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/app_drawer.dart';
import '/models/exam.dart';
import '/providers/exams_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

const GOOGLE_DIRECTIONS_API_URL =
    "https://maps.googleapis.com/maps/api/directions/json";
const GOOGLE_API_KEY = 'AIzaSyCibZY3Jqz1eDnZGybBLegEw4OXnzhgeAQ';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition = null;
  Set<Marker> _markers = {};
  Polyline? _polyline = null;

  @override
  void initState() {
    setInitCameraPosition();
    super.initState();
  }

  void setCameraPosition(CameraPosition position,
      [Map<String, dynamic>? boundsSw, Map<String, dynamic>? boundsNe]) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));

    if (boundsSw == null || boundsNe == null) return;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
  }

  void setUpMarkers() {
    final exams = Provider.of<Exams>(context).items;
    final markers = exams
        .map((exam) => Marker(
            markerId: MarkerId(exam.id),
            position: exam.location,
            infoWindow: InfoWindow(
              title: "Exam: ${exam.subjectName}",
              snippet: "Click for directions!",
              onTap: () => onMarkerTap(exam.location),
            )))
        .toSet();
    setState(() {
      _markers = markers;
    });
  }

  Future<void> onMarkerTap(LatLng examLocation) async {
    if (_currentPosition == null) return;
    LatLng from =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    final Map<String, dynamic> directions =
        await getDirections(from, examLocation);

    _setPolyline(directions['polyline_decoded']);

    setCameraPosition(CameraPosition(target: examLocation, zoom: 15),
        directions['bounds_sw'], directions['bounds_ne']);
  }

  void _setPolyline(List<PointLatLng> points) {
    Polyline polyline = Polyline(
        polylineId: const PolylineId('1'),
        width: 2,
        color: Colors.blue,
        points: points.map((p) => LatLng(p.latitude, p.longitude)).toList());

    setState(() {
      _polyline = polyline;
    });
  }

  Future<Map<String, dynamic>> getDirections(LatLng from, LatLng to) async {
    final res = await http.get(Uri.parse(
        "$GOOGLE_DIRECTIONS_API_URL?origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&key=$GOOGLE_API_KEY"));
    final resJson = jsonDecode(res.body);

    return {
      'bounds_ne': resJson['routes'][0]['bounds']['northeast'],
      'bounds_sw': resJson['routes'][0]['bounds']['southwest'],
      'start_location': resJson['routes'][0]['legs'][0]['start_location'],
      'end_location': resJson['routes'][0]['legs'][0]['end_location'],
      'polyline': resJson['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(resJson['routes'][0]['overview_polyline']['points'])
    };
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
    setState(() {
      _currentPosition = currentPosition;
    });
    setCameraPosition(CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 10));
  }

  @override
  Widget build(BuildContext context) {
    setUpMarkers();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Exam Planner'),
        ),
        drawer: AppDrawer(),
        body: GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 10),
          onMapCreated: (controller) => {_controller.complete(controller)},
          markers: _markers,
          polylines: _polyline == null ? {} : {_polyline as Polyline},
        ));
  }
}
