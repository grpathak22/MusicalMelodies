import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: HomeScreen(studentName: 'Student Name'), // Replace with actual name
    );
  }
}
