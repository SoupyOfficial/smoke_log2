import 'package:flutter/material.dart';

class THCCountdownTimer extends StatefulWidget {
  final DateTime lastHitTime;
  final double thcLevel;
  final double declineRate;

  THCCountdownTimer({
    required this.lastHitTime,
    required this.thcLevel,
    this.declineRate = 0.5,
  });

  @override
  _THCCountdownTimerState createState() => _THCCountdownTimerState();
}

class _THCCountdownTimerState extends State<THCCountdownTimer> {
  late String countdownText;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
  }

  void _updateCountdown() {
    setState(() {
      Duration timeElapsed = DateTime.now().difference(widget.lastHitTime);
      double estimatedCurrentTHC = widget.thcLevel - (widget.declineRate * timeElapsed.inHours);
      double timeToReachPreviousLevel = (widget.thcLevel - estimatedCurrentTHC) / widget.declineRate;
      countdownText = 'Time until previous level: ${timeToReachPreviousLevel.toStringAsFixed(2)} hours';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(countdownText),
        ElevatedButton(
          onPressed: _updateCountdown,
          child: Text('Refresh Countdown'),
        ),
      ],
    );
  }
}