import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DropdownMultiSelect extends StatefulWidget {
  final List<String> initialValues;
  final ValueChanged<List<String>> onValueChanged;

  const DropdownMultiSelect({
    super.key,
    required this.initialValues,
    required this.onValueChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DropdownMultiSelectState createState() => _DropdownMultiSelectState();
}

class _DropdownMultiSelectState extends State<DropdownMultiSelect> {
  List<String> _selectedOptions = [];
  List<String> _dropdownOptions = [
    'Elevated Pleasure',
    'Boredom',
    'Sleep',
    'Home from Work',
    'Physical Discomfort',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions();
    _selectedOptions = widget.initialValues;
  }

  @override
  void didUpdateWidget(DropdownMultiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      setState(() {
        _selectedOptions = widget.initialValues;
      });
    }
  }

  Future<void> _fetchDropdownOptions() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dropdown_options')
          .orderBy('display_order')
          .get();
      List<String> options =
          querySnapshot.docs.map((doc) => doc['option'] as String).toList();
      setState(() {
        _dropdownOptions = options;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching dropdown options: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: DropdownButtonFormField<String>(
        value: _selectedOptions.isNotEmpty ? _selectedOptions.first : null,
        items: _dropdownOptions
            .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (_selectedOptions.contains(value)) {
                _selectedOptions.remove(value);
              } else {
                _selectedOptions.add(value);
              }
              widget.onValueChanged(_selectedOptions);
            });
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[800],
          labelText: 'Select Reason(s)',
        ),
        isExpanded: true,
      ),
    );
  }
}
