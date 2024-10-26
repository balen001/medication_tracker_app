import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBOsNWeag3TquER9VEDENFGSncR0yOibGI",
        authDomain: "medication-tracker-app-90f3e.firebaseapp.com",
        projectId: "medication-tracker-app-90f3e",
        storageBucket: "medication-tracker-app-90f3e.appspot.com",
        messagingSenderId: "913016815421",
        appId: "1:913016815421:web:1db73e2e7c03df96390f54"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
