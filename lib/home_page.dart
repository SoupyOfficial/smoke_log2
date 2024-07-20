import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'input_section.dart';
import 'segmented_input.dart';
import 'dropdown_multi_select.dart';
import 'timer_input.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentMood = -1;
  int physicalComfort = -1;
  List<String> reasons = [];
  Duration timerDuration = const Duration(seconds: 0);
  String submissionMessage = '';
  Duration totalLengthForDay = const Duration(seconds: 0);
  Duration timeSinceLastUse = const Duration(seconds: 0);
  Timer? _timer;
  var collectionName = kReleaseMode ? 'JacobLogsTest' : 'JacobLogsTest';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeSinceLastUse();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    DateTime now = DateTime.now();
    // DateTime date = DateTime(now.year, now.month, now.day);
    DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    // Query to get the total length for the last 24 hours
    QuerySnapshot lengthSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('timestamp', isGreaterThanOrEqualTo: twentyFourHoursAgo)
        .get();

    double totalLengthInSeconds = 0;

    for (var doc in lengthSnapshot.docs) {
      totalLengthInSeconds += (doc['length'] as num).toDouble();
    }

    // Query to get the most recent record
    QuerySnapshot recentSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    DateTime? lastUse;
    if (recentSnapshot.docs.isNotEmpty) {
      lastUse = (recentSnapshot.docs.first['timestamp'] as Timestamp).toDate();
    }

    setState(() {
      totalLengthForDay = Duration(
        seconds: totalLengthInSeconds.floor(),
        milliseconds: getDecimalPart(totalLengthInSeconds),
      );
      timeSinceLastUse = lastUse != null
          ? DateTime.now().difference(lastUse)
          : const Duration(seconds: 0);
    });
  }

  int getDecimalPart(double value) {
    return ((value - value.truncateToDouble()) * 1000).toInt();
  }

  void _updateTimeSinceLastUse() {
    setState(() {
      timeSinceLastUse += const Duration(seconds: 1);
    });
  }

  Future<void> _submitData() async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).add({
        'moodRating': currentMood,
        'physicalRating': physicalComfort,
        'reason': reasons,
        'length': timerDuration.inSeconds +
            (timerDuration.inMilliseconds % 1000) / 1000,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _fetchData();
      setState(() {
        submissionMessage = 'Submission successful!';
      });
    } catch (error) {
      setState(() {
        submissionMessage = 'Submission failed: $error';
      });
    }

    // Clear the message and reset input fields after 5 seconds
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        submissionMessage = '';
        currentMood = -1;
        physicalComfort = -1;
        reasons = [];
        timerDuration = const Duration(seconds: 0);
      });
    });
  }

  String _formatDuration(Duration duration) {
    int totalSeconds = duration.inSeconds;
    int milliseconds = duration.inMilliseconds % 1000;
    double seconds = totalSeconds + milliseconds / 1000.0;
    return seconds.toStringAsFixed(1);
  }

  String _formatTimeSince(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:'
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Jacob'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Total Length for Today: ${_formatDuration(totalLengthForDay)}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time Since Last Use: ${_formatTimeSince(timeSinceLastUse)}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 16),
                          InputSection(
                            title: 'Current Mood',
                            child: SegmentedInput(
                              initialValue: currentMood,
                              onValueChanged: (value) {
                                setState(() {
                                  currentMood = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          InputSection(
                            title: 'Physical Comfort',
                            child: SegmentedInput(
                              initialValue: physicalComfort,
                              onValueChanged: (value) {
                                setState(() {
                                  physicalComfort = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          InputSection(
                            title: 'Reason(s)',
                            child: DropdownMultiSelect(
                              initialValues: reasons,
                              onValueChanged: (value) {
                                setState(() {
                                  reasons = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          InputSection(
                            title: 'Timer Input',
                            child: TimerInput(
                              initialDuration: timerDuration,
                              onTimerEnd: (duration) {
                                setState(() {
                                  timerDuration = duration;
                                  _submitData();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (submissionMessage.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  submissionMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
