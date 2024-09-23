import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/widgets/slot_selection.dart'; // Import your SlotSelectionWidget
import 'package:myapp/widgets/mode_selection.dart'; // Import your ModeSelectionWidget

class BookClassScreen extends StatefulWidget {
  final List<String> availableSlots;

  const BookClassScreen({required this.availableSlots, Key? key}) : super(key: key);

  @override
  _BookClassScreenState createState() => _BookClassScreenState();
}

class _BookClassScreenState extends State<BookClassScreen> {
  List<String> selectedSlots = [];
  String selectedMode = 'Online'; // Default mode

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
        Navigator.pop(context,true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one slot.')),
      );
    }
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
            // Slot Selection Widget with multiple selection
            SlotSelectionWidget(
              slots: widget.availableSlots,
              selectedSlots: selectedSlots, // Updated to multiple selected slots
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
