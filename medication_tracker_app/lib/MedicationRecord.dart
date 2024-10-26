import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationRecord {
  final String id;
  final Timestamp takenTime;
  final String medicationName;
  final String dose;
  final String freq;
  final String status;
  final String medicationId;

  MedicationRecord({
    required this.id,
    required this.dose,
    required this.freq,
    required this.medicationName,
    required this.status,
    required this.medicationId,
    required this.takenTime,
  });

  factory MedicationRecord.fromMap(Map<String, dynamic> map) {
    return MedicationRecord(
      medicationName: map['medicationName'],
      medicationId: map['medicationId'],
      dose: map['dose'],
      freq: map['freq'],
      takenTime: map['takenTime'],
      status: map['status'],
      id: map['id'],
    );
  }

  //check if the records takenTime is today
  bool isTakenToday() {
    DateTime now = DateTime.now();
    DateTime takenDate = takenTime.toDate();
    return takenDate.year == now.year &&
        takenDate.month == now.month &&
        takenDate.day == now.day;
  }
}
