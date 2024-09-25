import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/profile_page.dart';
import 'package:myapp/widgets/slot_card.dart';
import 'package:myapp/screens/book_class_screen.dart';

class HomeScreen extends StatefulWidget {
  final String studentName;
  const HomeScreen({required this.studentName, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String studentName = 'Loading...'; // Default value
  List<String> todaySlots = []; // To store today's slots
  String announcements = 'No new announcements at the moment.'; // Default announcement
  List<String> bookedClasses = []; // To store booked classes for today

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
    _fetchTodaySlots();
    _fetchAnnouncements(); // Fetch announcements on init
    _fetchBookedClasses(); // Fetch booked classes by the student
  }

  Future<void> _fetchStudentName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = FirebaseFirestore.instance.collection('student_details').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          setState(() {
            studentName = data['name'] ?? 'Name not available';
          });
        } else {
          setState(() {
            studentName = 'Name not available';
          });
        }
      } catch (e) {
        setState(() {
          studentName = 'Error fetching name';
        });
        print('Error fetching student name: $e');
      }
    } else {
      setState(() {
        studentName = 'User not logged in';
      });
    }
  }

  Future<void> _fetchTodaySlots() async {
    String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('class_timings')
        .doc(dayOfWeek)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot;
      List<String>? updatedSlots = List<String>.from(data['updated_slots'] ?? []);
      List<String> defaultSlots = List<String>.from(data['default_slots'] ?? []);

      // Use updated_slots if available, otherwise fallback to default_slots
      setState(() {
        todaySlots = updatedSlots.isNotEmpty ? updatedSlots : defaultSlots;
      });
    } else {
      setState(() {
        todaySlots = [];
      });
    }
  }

  Future<void> _fetchAnnouncements() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('announcements')
        .doc('latest') // Adjust the document ID as needed
        .get();

    if (docSnapshot.exists) {
      setState(() {
        announcements = docSnapshot['message'] ?? 'No new announcements at the moment.';
      });
    }
  }

Future<void> _fetchBookedClasses() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Fetch the document with the user's UID
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('students_class_selections')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      // Extract the slot, mode, and timestamp from the document
      final data = docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> slots = data['slot'] ?? 'No Slot';
      String mode = data['mode'] ?? 'Unknown Mode';
      Timestamp timestamp = data['timestamp']; // Firestore Timestamp

      // Convert Firestore timestamp to DateTime
      DateTime classDate = timestamp.toDate();

      // Get the current date (ignoring the time part)
      DateTime currentDate = DateTime.now();

      // Compare only the date components
      if (classDate.isBefore(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
        // Class date is before today, so delete the document
        await FirebaseFirestore.instance
            .collection('students_class_selections')
            .doc(user.uid)
            .delete();

        setState(() {
          bookedClasses = []; // Clear the booked classes
        });

        // Show a Snackbar or message if needed
      } else {
        // Class is still valid, show it
        setState(() {
          bookedClasses = ['$slots ($mode)'];
        });
      }
    } else {
      // If no document exists for the user
      setState(() {
        bookedClasses = [];
      });
    }
  }
}



void _showCancelDialog(String classInfo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Cancellation'),
        content: Text('Are you sure you want to cancel this class?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              _cancelClass(classInfo); // Call method to cancel the class
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}
Future<void> _cancelClass(String classInfo) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Use the document with user.uid to cancel the class
    await FirebaseFirestore.instance
        .collection('students_class_selections')
        .doc(user.uid)
        .delete(); // Remove the class document

    // Optionally refresh the booked classes
    _fetchBookedClasses();
    
    // Show a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Class canceled successfully!')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Color.fromARGB(255, 255, 255, 255),
  title: Padding(
    padding: EdgeInsets.symmetric(horizontal: 0), // Adjust padding as needed
    child: Container(
      height: 60, // Adjust height as needed
      width: 90, // Adjust width as needed
      child: Image.asset('assets/logo.png',fit:BoxFit.fill),
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.person, size: 35), // Increased size for enhancement
      onPressed: () {
        // Navigate to ProfilePage without logging out
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfilePage()),
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
              AnimatedContainerBox(announcements: announcements),
              SizedBox(height: 20),

              // Book Your Class Button
              Center(
  child: ElevatedButton(
    onPressed: () async {
      // Navigate to BookClassScreen and wait for the result
      bool? classBooked = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookClassScreen(availableSlots: todaySlots),
        ),
      );

      // If the class was booked, refresh booked classes
      if (classBooked == true) {
        _fetchBookedClasses();
      }
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
              SizedBox(height: 30),

              // Section Header for Booked Classes
              SectionHeader(title: 'Your Classes Today'),
              SizedBox(height: 10),
              if (bookedClasses.isNotEmpty)
  Wrap(
    spacing: 10, // Space between cards
    runSpacing: 10, // Space between rows
    children: bookedClasses.map((classInfo) {
      return Row(
        children: [
          SlotCard(slot: classInfo), // Assuming classInfo contains slot and mode
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _showCancelDialog(classInfo),
          ),
        ],
      );
    }).toList(),
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
  final String announcements;
  const AnimatedContainerBox({required this.announcements});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
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
                Icon(Icons.music_note, size: 40, color: Colors.deepPurpleAccent),
                SizedBox(height: 4),
                Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.deepPurple[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  announcements,
                  style: TextStyle(
                    fontSize: 19,
                    color: const Color.fromARGB(255, 0, 0, 0),
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
  _AnimatedBottomNavigationState createState() => _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          label: 'Modules',
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
