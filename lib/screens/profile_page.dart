import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/screens/login_page.dart';
class ProfilePage extends StatefulWidget {
final dynamic homeScreenState; // Accepts HomeScreen state
  final dynamic adminPageState;  // Accepts AdminPageState

  const ProfilePage({this.homeScreenState, this.adminPageState, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _age = '';
  String _phoneNumber = '';
  String _experience = '';
  String _profilePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('student_details').doc(user.uid);
      final profDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      final profDocSnapshot = await profDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final profData = profDocSnapshot.data()!;
        setState(() {
          _name = data['name'] ?? '';
          _age = data['age'] ?? '';
          _phoneNumber = data['phone_number'] ?? '';
          _experience = data['experience'] ?? '';
          _profilePhotoUrl = profData['pfp_link'] ?? ''; // Fetch profile photo URL
        });
      } else {
        // Handle the case when the document does not exist
        setState(() {
          _name = 'Not available';
          _age = 'Not available';
          _phoneNumber = 'Not available';
          _experience = 'Not available';
          _profilePhotoUrl = ''; // Default to empty if no photo link
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Text('Profile'),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: _profilePhotoUrl.isNotEmpty
                    ? ClipOval(
                        child: _buildProfileImage(),
                      )
                    : Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.grey[700],
                      ),
              ),
            ),
            SizedBox(height: 30),
            // Profile Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileRow('Name', _name),
                    _buildDivider(),
                    _buildProfileRow('Age', _age),
                    _buildDivider(),
                    _buildProfileRow('Phone Number', _phoneNumber),
                    _buildDivider(),
                    _buildProfileRow('Experience', _experience),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                   if (widget.adminPageState != null) {
                
                widget.adminPageState.dispose(); // Clean up resources
              } else if (widget.homeScreenState != null) {
                widget.homeScreenState.dispose(); // Clean up resources
              }
                  if (kIsWeb) {
                  // Sign out logic for web
                   await FirebaseAuth.instance.signOut();
                } else {
                  // Sign out logic for mobile
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                }
                  // Show success Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout successful'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Delay navigation to allow Snackbar to be shown
                  await Future.delayed(Duration(seconds: 1));

                  // Navigate to LoginPage after successful logout
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Logout', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the profile image widget based on the platform
  Widget _buildProfileImage() {
    if (kIsWeb) {
      // For web, use CachedNetworkImage with CORS fallback handling
      return CachedNetworkImage(
        imageUrl: _profilePhotoUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(
          Icons.person_outline,
          size: 60,
          color: Colors.grey[700],
        ),
      );
    } else {
      // For mobile, use standard Image.network
      return Image.network(
        _profilePhotoUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person_outline,
            size: 60,
            color: Colors.grey[700],
          );
        },
      );
    }
  }

  // Helper method to build each profile row with label and value
  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Divider with spacing to separate profile fields
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Divider(
        color: Colors.grey[300],
        thickness: 1,
      ),
    );
  }
}
