import 'package:flutter/material.dart';
// ignore: unused_import
import 'screens/home_screen.dart';
import 'screens/login_page.dart';

void main() {
  runApp(MusicalMelodiesApp());
}

class MusicalMelodiesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musical Melodies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Replace with actual name
    );
  }
}
