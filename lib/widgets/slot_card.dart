import 'package:flutter/material.dart';
class SlotCard extends StatelessWidget {
  final String slot;

  const SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        width: 150, // Set a fixed width for the cards
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 32, 248, 61),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            slot,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
