import 'package:flutter/material.dart';

class ModeSelectionWidget extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeSelected;

  const ModeSelectionWidget({
    required this.selectedMode,
    required this.onModeSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Mode',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text('Online'),
          leading: Radio<String>(
            value: 'Online',
            groupValue: selectedMode,
            onChanged: (value) {
              if (value != null) {
                onModeSelected(value);
              }
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ),
        ListTile(
          title: Text('Offline'),
          leading: Radio<String>(
            value: 'Offline',
            groupValue: selectedMode,
            onChanged: (value) {
              if (value != null) {
                onModeSelected(value);
              }
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ),
      ],
    );
  }
}
