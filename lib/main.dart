import 'package:flutter/material.dart';
import 'package:myapp/screens/profile_form_page.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'screens/home_screen.dart'; // Assuming you have this file
import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() {
  _initializeFirebase();
  runApp(MusicalMelodiesApp());
}

class MusicalMelodiesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musical Melodies',
      theme: ThemeData(
        primarySwatch:
            Colors.deepPurple, // Updated the theme color to match your branding
      ),
      home: SplashScreen(), // Navigates to the LoginPage
    );
  }
}

_initializeFirebase() async {

await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
}