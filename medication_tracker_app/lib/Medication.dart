import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String time;
  final String medicationName;
  final String dose;
  final String freq;

  Medication(
      {required this.id,
      required this.time,
      required this.medicationName,
      required this.dose,
      required this.freq});
}
