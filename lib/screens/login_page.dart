import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/screens/admin/admin_home_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/profile_form_page.dart'; // Import ProfileFormPage for new users
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Size mq;
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    // Start animation after a slight delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  // Handle Google login button click
  void _handleGoogleBtnClick() async {
    final userCredential = await _signInWithGoogle();
    if (userCredential != null) {
      final user = userCredential.user!;
      final additionalUserInfo = userCredential.additionalUserInfo!;

      // Check if the user is new
      if (additionalUserInfo.isNewUser) {
        // If new, add the user to Firestore and navigate to ProfileFormPage
        await _addUserToFirestore(user, additionalUserInfo);
        _showSnackBar('Welcome, ${user.displayName}!', Colors.green);

        // Navigate to ProfileFormPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileFormPage(),
          ),
        );
      } else {
        // If the user already exists, check user type
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // Check user type and navigate accordingly
          if (userDoc['type'] == 'admin') {
            _showSnackBar('Welcome back, ${user.displayName}!', Colors.green);
            await Future.delayed(Duration(seconds: 1));
            // Navigate to AdminHomeScreen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminPage(),
              ),
            );
          } else {
            // Navigate to HomeScreen for students
            _showSnackBar('Welcome back, ${user.displayName}!', Colors.green);
            await Future.delayed(Duration(seconds: 1));

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(studentName: ""),
              ),
            );
          }
        }
      }
    }
  }

  // Sign in with Google
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Check for internet connectivity
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _showSnackBar('Something went wrong (Check Internet)', Colors.red);
      return null;
    }
  }

  // Add the new user to Firestore
  Future<void> _addUserToFirestore(User user, AdditionalUserInfo additionalUserInfo) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Check if user exists in Firestore
    final docSnapshot = await docUser.get();
    if (!docSnapshot.exists) {
      // If not, add the user to Firestore
      await docUser.set({
        'pfp_link': additionalUserInfo.profile?['picture'] ?? '',
        'type': 'student', // Set the type as 'student'
      });
    }
  }

  // Show a SnackBar with custom message and color
  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .25,
            right: _isAnimate ? mq.width * 0.1 : mq.width * .15,
            width: mq.width * 0.8,
            duration: const Duration(milliseconds: 600),
            child: Image.asset('assets/png/logo-no-background.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              onPressed: _handleGoogleBtnClick,
              style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 2),
                shape: const StadiumBorder(),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              icon: Transform.scale(
                scale: 0.55,
                child: Image.asset('assets/google.png'), // Google icon
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 18, fontFamily: 'abz', color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
