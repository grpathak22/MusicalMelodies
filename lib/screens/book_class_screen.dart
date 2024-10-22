import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/widgets/slot_selection.dart'; // Import your SlotSelectionWidget
import 'package:myapp/widgets/mode_selection.dart'; // Import your ModeSelectionWidget
import 'dart:async';

class BookClassScreen extends StatefulWidget {
  @override
  _BookClassScreenState createState() => _BookClassScreenState();
}

class _BookClassScreenState extends State<BookClassScreen> {
  List<String> selectedSlots = [];
  List<String> todaySlots = [];
  String selectedMode = 'Online'; // Default mode
  Timer? _classTimer;
  List<String> updatedAvailableSlots = []; // To store refreshed available slots
  List<String> bookedClasses = []; // To store booked classes

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots(); // Fetch available slots when the screen initializes
    _startClassTimer(); // Start the timer for refreshing class timings
    _fetchBookedClasses(); // Fetch booked classes when the screen initializes
  }

  Future<void> _fetchAvailableSlots() async {
    String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('class_timings')
      .doc(dayOfWeek)
      .get();

  if (docSnapshot.exists) {
    final data = docSnapshot; // Get the data from the snapshot
    List<String>? updatedSlots = List<String>.from(data['updated_slots'] ?? []);
    List<String> defaultSlots = List<String>.from(data['default_slots'] ?? []);
    Timestamp lastUpdateTimestamp = data['last_update'] as Timestamp; // Get the last_update timestamp

    DateTime lastUpdateDate = lastUpdateTimestamp.toDate(); // Convert it to DateTime
    DateTime today = DateTime.now();

    // Compare dates: If last update is older than today, show default slots
    if (lastUpdateDate.year == today.year &&
        lastUpdateDate.month == today.month &&
        lastUpdateDate.day == today.day) {
      // Updated today
      setState(() {
        todaySlots = updatedSlots.isNotEmpty ? updatedSlots : defaultSlots;
      });
    } else {
      // Older than today
      setState(() {
        todaySlots = defaultSlots;
      });
    }
  } else {
    setState(() {
      todaySlots = [];
    });
  }
  }

  void _startClassTimer() {
    _classTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchAvailableSlots(); // Refresh available slots every 3 seconds
    });
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
        List<dynamic> slots = data['slot'] ?? ['No Slot'];
        String mode = data['mode'] ?? 'Unknown Mode';
        Timestamp? timestamp = data['timestamp']; // Firestore Timestamp

        if (timestamp != null) {
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

            // Optionally, show a Snackbar or message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Your past booking has been deleted.')),
            );
          } else {
            // Class is still valid, show it
            setState(() {
              bookedClasses = ['$slots ($mode)'];
            });
          }
        }
      } else {
        // If no document exists for the user
        setState(() {
          bookedClasses = [];
        });
      }
    }
  }

  void _confirmBooking() async {
    if (selectedSlots.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Set the booking data in Firestore with the user's UID as document ID
        await FirebaseFirestore.instance
            .collection('students_class_selections')
            .doc(user.uid)  // Use user.uid as the document ID
            .set({
          'slot': selectedSlots, // Storing multiple slots
          'mode': selectedMode,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));  // Merge to prevent overwriting the document

        // Show a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class booked successfully!')),
        );

        // Optionally pop the screen to go back
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one slot.')),
      );
    }
  }

  @override
  void dispose() {
    _classTimer?.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Class'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display booked classes if any
            if (bookedClasses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Booked Classes:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...bookedClasses.map((bookedClass) => Text(bookedClass)).toList(),
                  SizedBox(height: 20),
                ],
              ),
            // Slot Selection Widget with multiple selection
            SlotSelectionWidget(
              slots: todaySlots, // Use the updated available slots
              selectedSlots: selectedSlots,
              onSlotsSelected: (slots) {
                setState(() {
                  selectedSlots = slots;
                });
              },
            ),
            SizedBox(height: 20),
            // Mode Selection Widget
            ModeSelectionWidget(
              selectedMode: selectedMode,
              onModeSelected: (value) {
                setState(() {
                  selectedMode = value;
                });
              },
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
