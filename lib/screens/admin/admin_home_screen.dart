import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for formatting dates and times
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
void main() => runApp(MaterialApp(home: AdminPage()));

class AdminPage extends StatefulWidget {
  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  String currentUserName = "Admin"; // Default name
  int _selectedIndex = 0;
  List<String> selectedTimeSlots = []; // To store selected time slots
  List<Map<String, dynamic>> studentsDetails = []; // Store student details
  Timer? _timer; // Timer to refresh the data

  @override
  void initState() {
    super.initState();
    _fetchStudentsAttendingToday(); // Initial fetch
    _startTimer(); // Start the timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchStudentsAttendingToday(); // Refresh the data every 3 seconds
    });
  }

  Future<void> _fetchStudentsAttendingToday() async {
    DateTime today = DateTime.now();
    String startDate = DateFormat('yyyy-MM-dd 00:00:00').format(today);
    String endDate = DateFormat('yyyy-MM-dd 23:59:59').format(today);

    // Fetch bookings for today
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('students_class_selections')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.parse(startDate)))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.parse(endDate)))
        .get();

    List<Map<String, dynamic>> tempStudents = [];

    for (var doc in bookingSnapshot.docs) {
      String userId = doc.id; // Document ID is the user ID (uid)

      // Fetch user details
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('student_details')
          .doc(userId)
          .get();
      DocumentSnapshot linkDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
        
      if (userDoc.exists) {
        // Check if booking timestamp is today
        DateTime bookingTime = (doc['timestamp'] as Timestamp).toDate();
        if (bookingTime.isAfter(DateTime(today.year, today.month, today.day)) &&
            bookingTime.isBefore(DateTime(today.year, today.month, today.day + 1))) {
          // If the booking is for today, add to the list
          tempStudents.add({
            'name': userDoc['name'],
            'mode': doc['mode'] ?? 'N/A', // Use 'N/A' if mode is not available
            'time': (doc['slot'] as List).isNotEmpty ? doc['slot'] : ['N/A'],
            'pfp_link': linkDoc['pfp_link'], // Use 'N/A' if slot is not available
          });
        } else {
          // Truncate the document if the booking is not for today
          await FirebaseFirestore.instance
              .collection('students_class_selections')
              .doc(userId)
              .update({
                'mode': [],
                'slot': [],
                'timestamp': null,
              });
        }
      }
    }

    setState(() {
      studentsDetails = tempStudents; // Update the state with the fetched students
    });
  }

  Widget _buildStudentList() {
    print(studentsDetails); // Debugging line to check the content
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Students Attending Today\'s Class:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          if (studentsDetails.isNotEmpty)
            ...studentsDetails.map((student) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: student['pfp_link'] != null && student['pfp_link'].isNotEmpty
                        ? NetworkImage(student['pfp_link']) 
                        : null, // Fallback to a placeholder if empty
                      child: (student['pfp_link'] == null || student['pfp_link'].isEmpty)
                        ? Icon(Icons.person, color: Colors.white) // Placeholder icon
                        : null,
                    ),
                    title: Text(
                      student['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Mode: ${student['mode']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Time: ${student['time'].join(', ')}', // Join times if there are multiple
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList()
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'No students attending',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Future<bool?> _showDeleteDialog(String timeSlot) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $timeSlot?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}

// Method to remove the time slot from Firestore
Future<void> _removeTimeSlotFromFirestore(String timeSlot) async {
  String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('class_timings')
      .doc(dayOfWeek);

  // Fetch existing document
  DocumentSnapshot docSnapshot = await docRef.get();
  List<String> defaultSlots = List<String>.from(docSnapshot['default_slots'] ?? []);
  List<String> existingUpdatedSlots = List<String>.from(docSnapshot['updated_slots'] ?? []);

  // Remove the time slot if it exists
  if (existingUpdatedSlots.contains(timeSlot)) {
    existingUpdatedSlots.remove(timeSlot);
    
    // Update Firestore with the modified slots
    await docRef.set({
      'default_slots': defaultSlots,
      'updated_slots': existingUpdatedSlots,
      'last_update': Timestamp.now(), // Update the last_update timestamp
    });
  }
}

  Future<void> _navigateAndSelectTimeSlots() async {
    final selectedSlots = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSlotSelectionScreen()),
    );

    if (selectedSlots != null) {
      setState(() {
        selectedTimeSlots = selectedSlots;
      });
    }
  }

Future<void> _fetchUserName() async {
    // Replace 'your_user_uid' with the actual user UID
    String userUid = 'Admin';
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null){
      String userUid = user.uid;
    }
     // Get this from your authentication logic
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('students') // or your users collection
        .doc(userUid)
        .get();
        
    if (doc.exists) {
      setState(() {
        currentUserName = doc['name']; // Replace 'name' with the actual field name
      });
    }
  }
// Announcement form widget


 @override
Widget build(BuildContext context) {
  // Get today's date and day
  String currentDate =
      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Musical Melodies',
        
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 255, 255, 255), Colors.yellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
          IconButton(
            icon: Icon(Icons.person),
    onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePage(adminPageState: this),
      ),
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
            // Welcome message
            Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),

            // Display current date and day
            Text(
              currentDate,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),

            // Button to navigate to time slot selection screen
            Center(
              child: ElevatedButton(
                onPressed: _navigateAndSelectTimeSlots,
                child: Text('Select Time Slots'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  textStyle: TextStyle(fontSize: 18),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
  child: ElevatedButton(
    onPressed: () {
      // Navigate to AnnouncementUploadPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnnouncementUploadPage()),
      );
    },
    child: Text('Announcements'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 30, 202, 255),  // You can change the color as needed
      textStyle: TextStyle(fontSize: 18),
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    ),
  ),
),
SizedBox(height: 20),

            // Display selected class times
            if (selectedTimeSlots.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Class Times:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...selectedTimeSlots.map((timeSlot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {}, // You can add any action here if needed
                          child: Text(timeSlot),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            bool? confirmDelete = await _showDeleteDialog(timeSlot);
                            if (confirmDelete == true) {
                              setState(() {
                                selectedTimeSlots.remove(timeSlot);
                              });
                              // Call Firestore update to remove the time slot
                              await _removeTimeSlotFromFirestore(timeSlot);
                            }
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            SizedBox(height: 20),

            // Display students attending today's class
            _buildStudentList(), 
            // Call the method to build the student list
          ],
        ),
      ),
    ),
    // Bottom navigation bar
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_module),
          label: 'Modules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Fees',
        ),
      ],
    ),
  );
}

}
class AnnouncementUploadPage extends StatefulWidget {
  @override
  _AnnouncementUploadPageState createState() => _AnnouncementUploadPageState();
}

class _AnnouncementUploadPageState extends State<AnnouncementUploadPage> {
  File? _imageFile;
  bool _isUploading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _announcementController = TextEditingController();
  String? _currentAnnouncement;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchCurrentAnnouncement(); // Fetch current announcement when the page loads
  }

  // Fetch the current announcement from Firestore
  Future<void> _fetchCurrentAnnouncement() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('announcements').doc('latest').get();

      if (snapshot.exists) {
        setState(() {
          _currentAnnouncement = snapshot['announcement'];
          _currentImageUrl = snapshot['imageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching current announcement: $e');
    }
  }

  // Pick Image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  // Upload Image
  Future<String?> _uploadImage(String docId) async {
    if (_imageFile == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      // Define a unique file name
      String fileName = 'announcements/latest/${DateTime.now()}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      // Upload file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Return the download URL
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Return null in case of error
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Upload Announcement and Call Image Upload
  Future<void> _uploadAnnouncement() async {
    DocumentReference docRef = _firestore.collection('announcements').doc();

    // Upload announcement text or other details
    await docRef.set({
      'announcement': _announcementController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Upload image if it exists and get the image URL
    String? imageUrl = await _uploadImage(docRef.id);

    // Update the "latest" document with the new announcement details
    await _firestore.collection('announcements').doc('latest').set({
      'announcement': _announcementController.text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Schedule deletion in 2 days
    Future.delayed(Duration(days: 2), () async {
      await _deleteAnnouncement(docRef.id);
    });

    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload Successful'), backgroundColor: Colors.green),
    );

    // Fetch current announcement again to refresh the display
    _fetchCurrentAnnouncement();
  }

  // Delete Announcement (and Image)
  Future<void> _deleteAnnouncement(String docId) async {
    try {
      // Get the announcement doc
      DocumentSnapshot snapshot = await _firestore.collection('announcements').doc(docId).get();
      String? imageUrl = snapshot['imageUrl'];

      // Delete from Firestore
      await _firestore.collection('announcements').doc(docId).delete();

      // Delete image from Storage
      if (imageUrl != null) {
        await _storage.refFromURL(imageUrl).delete();
      }

      // Clear current announcement
      setState(() {
        _currentAnnouncement = null;
        _currentImageUrl = null;
      });
    } catch (e) {
      print('Error deleting announcement: $e');
    }
  }

  // Delete current announcement
  Future<void> _deleteCurrentAnnouncement() async {
    if (_currentAnnouncement != null) {
      await _deleteAnnouncement('latest');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current announcement deleted'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display current announcement if it exists
            if (_currentAnnouncement != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Announcement:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(_currentAnnouncement!),
                  if (_currentImageUrl != null) ...[
                    SizedBox(height: 8),
                    Image.network(_currentImageUrl!, height: 100, width: 100),
                  ],
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteCurrentAnnouncement,
                    tooltip: 'Delete Current Announcement',
                  ),
                  SizedBox(height: 16),
                ],
              ),
            // Announcement Text Input
            TextField(
              controller: _announcementController,
              decoration: InputDecoration(
                labelText: 'Announcement Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image', style: TextStyle(color: Colors.black)), // Button text color changed to black
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            _imageFile != null
                ? Image.file(_imageFile!, height: 100, width: 100)
                : Text('No image selected', style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _uploadAnnouncement,
                    child: Text('Upload Announcement', style: TextStyle(color: Colors.black)), // Button text color changed to black
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
// Separate screen for selecting time slots
class TimeSlotSelectionScreen extends StatefulWidget {
  @override
  _TimeSlotSelectionScreenState createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  List<String> timeSlots = [];
  List<bool> selectedTimeSlots = [];

  TimeOfDay? _customTime; // Custom time slot variable

  @override
  void initState() {
    super.initState();
    _fetchDefaultSlots();
  }

  Future<void> _fetchDefaultSlots() async {
    String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('class_timings')
        .doc(dayOfWeek)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        timeSlots = List<String>.from(docSnapshot['default_slots'] ?? []);
        selectedTimeSlots = List<bool>.filled(timeSlots.length, false);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: Colors.black)
                .copyWith(secondary: Colors.yellow),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _customTime = time;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Slots'),
        
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Available Time Slots:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            SizedBox(height: 10),

            // List of checkboxes
            Column(
              children: List<Widget>.generate(timeSlots.length, (index) {
                return CheckboxListTile(
                  title: Text(timeSlots[index]),
                  value: selectedTimeSlots[index],
                  activeColor: Colors.yellow,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedTimeSlots[index] = value!;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),

            // Button to add custom time slot
            Center(
              child: ElevatedButton(
                onPressed: _pickTime,
                child: Text('Add Custom Time Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  textStyle: TextStyle(fontSize: 18),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
            if (_customTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Custom Time Slot: ${_customTime!.format(context)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.yellow[700],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Button to return selected time slots
            // Button to confirm selected time slots
Center(
  child: ElevatedButton(
    onPressed: () async {
      // Gather all selected time slots
      List<String> selectedTimes = [];
      for (int i = 0; i < timeSlots.length; i++) {
        if (selectedTimeSlots[i]) {
          selectedTimes.add(timeSlots[i]);
        }
      }
      if (_customTime != null) {
        String customTimeString = _customTime!.format(context);
        if (!selectedTimes.contains(customTimeString)) {
          selectedTimes.add(customTimeString);
        }
      }

      // Update Firestore document for the specific day
      String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('class_timings')
          .doc(dayOfWeek);

      // Fetch existing document
      DocumentSnapshot docSnapshot = await docRef.get();
      List<String> existingUpdatedSlots = List<String>.from(docSnapshot['updated_slots'] ?? []);
      Timestamp lastUpdate = docSnapshot['last_update'] ?? Timestamp.now();
      DateTime lastUpdateDate = lastUpdate.toDate();

      // Check if the last update date is before today
      if (lastUpdateDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
        // Truncate the updated slots
        existingUpdatedSlots = [];
      }

      // Combine existing and new selected times, ensuring uniqueness
      Set<String> combinedSlots = Set.from(existingUpdatedSlots)..addAll(selectedTimes);

      // Update Firestore with the combined slots and the current timestamp
      await docRef.set({
        'default_slots': timeSlots,
        'updated_slots': combinedSlots.toList(),
        'last_update': Timestamp.now(), // Update the last_update timestamp
      });

      Navigator.pop(context, combinedSlots.toList());
    },
    child: Text('Confirm Selection'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      textStyle: TextStyle(fontSize: 18),
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    ),
  ),
),


          ],
        ),
      ),
    );
  }
}
