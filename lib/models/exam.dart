import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Exam {
  final String id;
  final String subjectName;
  final DateTime date;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final LatLng location;
  final String address;

  Exam(
      {required this.id,
      required this.subjectName,
      required this.date,
      required this.timeStart,
      required this.timeEnd,
      required this.location,
      required this.address});
}
