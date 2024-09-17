import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/login_page.dart';

class HomeScreen extends StatelessWidget {
  final String studentName;

  const HomeScreen({required this.studentName, Key? key}) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Musical Melodies'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active_outlined),
            onPressed: () {
              // Add notification functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () async {
              // Handle logout functionality
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              AnimatedText(studentName: studentName),
              SizedBox(height: 10),
              Text(
                currentDate,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),
              AnimatedContainerBox(),
              SizedBox(height: 40),
              SectionHeader(title: 'Announcements'),
              SizedBox(height: 10),
              Text(
                'No new announcements at the moment.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              SectionHeader(title: 'Class Time from Sir'),
              SizedBox(height: 10),
              Text(
                'Next class: Monday at 5 PM',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add functionality for booking class
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Book Your Class',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigation(),
    );
  }
}

class AnimatedText extends StatelessWidget {
  final String studentName;
  const AnimatedText({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double opacity, Widget? child) {
        return Opacity(
          opacity: opacity,
          child: Text(
            'Welcome, $studentName!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedContainerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.music_note,
                    size: 100, color: Colors.deepPurpleAccent),
                SizedBox(height: 10),
                Text(
                  'Let’s make some beautiful music today!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent,
      ),
    );
  }
}

class AnimatedBottomNavigation extends StatefulWidget {
  @override
  _AnimatedBottomNavigationState createState() =>
      _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation functionality if needed
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurpleAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          label: 'Lessons',
        ),
        BottomNavigationBarItem(
          icon: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/rupee.png', // Ensure this path is correct
                width: 20,
                height: 20,
              ),
            ),
            label: 'Fees',
          ),
      ],
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}