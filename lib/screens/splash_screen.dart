import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/admin_home_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:myapp/screens/admin/admin_home_screen.dart'; // Import your Admin Page
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Check user authentication status after the splash screen
    _checkUser();
  }

  Future<void> _checkUser() async {
    // Wait for the animation to finish
    await Future.delayed(const Duration(seconds: 4));

    // Check if the user is already signed in
    final User? user = FirebaseAuth.instance.currentUser;

    // Navigate to the appropriate screen based on user type
    if (user != null) {
      // Assuming you have a way to get the user type, e.g., from Firestore
      String userType = await _getUserType(user.uid); // Replace with your method to get user type

      if (userType == 'student') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(studentName: user.displayName ?? ""),
          ),
        );
      } else if (userType == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminPage(),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  Future<String> _getUserType(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc['type'] ?? 'student'; // Adjust according to your structure// Replace this with actual logic
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in animation
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/png/logo-white.png', // Path to your logo
                width: 400,
                height: 400,
              ),
            ),
            SizedBox(height: 35),
            // Title with fade-in animation (if needed)
            // Text(
            //   'Your App Title',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
