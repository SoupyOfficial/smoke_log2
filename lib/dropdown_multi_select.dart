import 'package:flutter/material.dart';

class DropdownMultiSelect extends StatefulWidget {
  final List<String> initialValues;
  final ValueChanged<List<String>> onValueChanged;

  const DropdownMultiSelect({
    super.key,
    required this.initialValues,
    required this.onValueChanged,
  });

  @override
  _DropdownMultiSelectState createState() => _DropdownMultiSelectState();
}

class _DropdownMultiSelectState extends State<DropdownMultiSelect> {
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: DropdownButtonFormField<String>(
        value: _selectedOptions.isNotEmpty ? _selectedOptions.first : null,
        items: ['Elevated Pleasure', 'Boredom']
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
