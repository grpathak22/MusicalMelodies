import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final String slot;

  const SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        width: 140, // Compact width for minimal look
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 73, 255, 143), // Blue shade to match a clean, modern theme
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            slot,
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
