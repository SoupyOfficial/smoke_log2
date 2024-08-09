// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'app_config.dart';
import 'segmented_input.dart';
import 'dropdown_multi_select.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  _ManualEntryPageState createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  int currentMood = -1;
  int physicalComfort = -1;
  List<String> reasons = [];
  double length = 0.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final TextEditingController _lengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lengthController.text = length.toString();
  }

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitData() async {
    String collectionName = await AppConfig.getCollectionName();

    DateTime timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      await FirebaseFirestore.instance.collection(collectionName).add({
        'moodRating': currentMood,
        'physicalRating': physicalComfort,
        'reason': reasons,
        'length': length,
        'timestamp': Timestamp.fromDate(timestamp),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data submitted successfully')),
      );

      Navigator.of(context).pop(); // Return to previous page after submission
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Data Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                  'Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time: ${selectedTime.format(context)}'),
            ),
            const SizedBox(height: 16),
            const Text('Current Mood'),
            SegmentedInput(
              initialValue: currentMood,
              onValueChanged: (value) {
                setState(() {
                  currentMood = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Physical Comfort'),
            SegmentedInput(
              initialValue: physicalComfort,
              onValueChanged: (value) {
                setState(() {
                  physicalComfort = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Reason(s)'),
            DropdownMultiSelect(
              initialValues: reasons,
              onValueChanged: (value) {
                setState(() {
                  reasons = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lengthController,
              decoration: const InputDecoration(
                labelText: 'Length (in seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  length = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
