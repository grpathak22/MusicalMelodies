import 'package:flutter/material.dart';

class SlotSelectionWidget extends StatefulWidget {
  final List<String> slots;
  final List<String> selectedSlots;
  final ValueChanged<List<String>> onSlotsSelected;

  const SlotSelectionWidget({
    required this.slots,
    required this.selectedSlots,
    required this.onSlotsSelected,
    Key? key,
  }) : super(key: key);

  @override
  _SlotSelectionWidgetState createState() => _SlotSelectionWidgetState();
}

class _SlotSelectionWidgetState extends State<SlotSelectionWidget> {
  late List<String> selectedSlots;

  @override
  void initState() {
    super.initState();
    selectedSlots = widget.selectedSlots; // Initial slots passed
  }

  void _onSlotSelected(bool selected, String slot) {
    setState(() {
      if (selected) {
        selectedSlots.add(slot);
      } else {
        selectedSlots.remove(slot);
      }
      widget.onSlotsSelected(selectedSlots); // Callback for parent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Slots',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: widget.slots.map((slot) {
            return FilterChip(
              label: Text(slot),
              selected: selectedSlots.contains(slot),
              onSelected: (isSelected) {
                _onSlotSelected(isSelected, slot);
              },
              selectedColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(
                color: selectedSlots.contains(slot) ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
