import 'package:flutter/material.dart';

class SegmentedInput extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const SegmentedInput({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  _SegmentedInputState createState() => _SegmentedInputState();
}

class _SegmentedInputState extends State<SegmentedInput> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialValue - 1;
  }

  @override
  void didUpdateWidget(SegmentedInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue - 1 != oldWidget.initialValue - 1) {
      setState(() {
        _selectedIndex = widget.initialValue - 1;
      });
    }
  }

  void _handleButtonPress(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
        widget.onValueChanged(0); // Indicate deselection
      } else {
        _selectedIndex = index;
        widget.onValueChanged(index + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth / 10 - 4;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: List.generate(10, (index) {
              bool isSelected = index == _selectedIndex;
              return SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default padding
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    textStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  onPressed: () => _handleButtonPress(index),
                  child: Text('${index + 1}'),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
