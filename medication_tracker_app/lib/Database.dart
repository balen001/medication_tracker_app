import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //fetching medicationsRecord from database

  Future<List<Map<String, dynamic>>> fetchMedicationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDocRef = firestore.collection('users').doc(userId);

    QuerySnapshot medicationsRecordSnapshot =
        await userDocRef.collection('medications').get();

    List<Map<String, dynamic>> medicationsRecord =
        medicationsRecordSnapshot.docs.map((doc) {
      // Include the document ID in the returned map
      Map<String, dynamic> medicationData = doc.data() as Map<String, dynamic>;
      medicationData['id'] = doc.id; // Add the document ID with key 'id'
      return medicationData;
    }).toList();

    return medicationsRecord;
  }

  Future<void> deleteMedicationForUser(
      String userId, String medicationId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDocRef = firestore.collection('users').doc(userId);

    //delete medication by id
    await userDocRef.collection('medications').doc(medicationId).delete();
  }

  Future<void> recordTakenTimeIntoDatabase(String userId, String medicationId,
      Map<String, dynamic> medicationRecordData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDocRef = firestore.collection('users').doc(userId);

    await userDocRef.collection('medicationsRecord').add(medicationRecordData);

    if (medicationRecordData['freq'] == 'one-time') {
      await userDocRef.collection('medications').doc(medicationId).delete();
    }
  }

  Future<void> addMedicationForUser(
      String userId, Map<String, dynamic> medicationData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDocRef = firestore.collection('users').doc(userId);

    await userDocRef.collection('medications').add(medicationData);
  }

  //update medication
  Future<void> updateMedicationForUser(String userId, String medicationId,
      Map<String, dynamic> updatedData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDocRef = firestore.collection('users').doc(userId);

    await userDocRef
        .collection('medications')
        .doc(medicationId)
        .update(updatedData);
  }

  //fetching medicationRecords from database
  Future<List<Map<String, dynamic>>> fetchMedicationsRecord(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userDocRef = firestore.collection('users').doc(userId);
    QuerySnapshot medicationsRecordSnapshot =
        await userDocRef.collection('medicationsRecord').get();

    List<Map<String, dynamic>> medicationsRecord =
        medicationsRecordSnapshot.docs.map((doc) {
      Map<String, dynamic> medicationData = doc.data() as Map<String, dynamic>;
      medicationData['id'] = doc.id;
      return medicationData;
    }).toList();

    return medicationsRecord;
  }
}
