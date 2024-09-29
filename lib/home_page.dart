import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Inhalation.dart';
import 'THCConcentration.dart';
import 'input_section.dart';
import 'segmented_input.dart';
import 'dropdown_multi_select.dart';
import 'timer_input.dart';
import 'custom_app_bar.dart';
import 'manual_entry_page.dart';
import 'app_config.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final Function onReload;

  const HomePage({required this.onReload, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentMood = -1;
  int physicalComfort = -1;
  List<String> reasons = [];
  Duration timerDuration = const Duration(seconds: 0);
  String submissionMessage = '';
  Duration totalLengthFor24H = const Duration(seconds: 0);
  Duration totalLengthForToday = const Duration(seconds: 0);
  Duration timeSinceLastUse = const Duration(seconds: 0);
  Timer? _timer;
  String _currentUser = 'Jacob';

  // New Variables for THC concentration
  THCConcentration _thcConcentration = THCConcentration(inhalations: []);
  double _currentTHC = 0.0;
  StreamSubscription? _inhalationSubscription;
  Timer? _THCtimer;

  @override
  void initState() {
    super.initState();
    _updateCurrentUser();
    _fetchData();
    _fetchRealTimeInhalations();
    // _startTHCTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeSinceLastUse();
    });
  }

  Future<void> _updateCurrentUser() async {
    String collectionName = await AppConfig.getCollectionName();
    setState(() {
      _currentUser = collectionName.startsWith('Jacob') ? 'Jacob' : 'Ashley';
    });
  }

  Future<void> _swapUser() async {
    await AppConfig.swapUser(widget.onReload);
    await _updateCurrentUser();
    await _fetchData(); // Refresh the data for the new user
  }

  void _navigateToManualEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ManualEntryPage()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _THCtimer?.cancel();
    _inhalationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    String collectionName = await AppConfig.getCollectionName();

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    // Query to get the total length for the last 24 hours
    QuerySnapshot lengthDaySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('timestamp', isGreaterThanOrEqualTo: date)
        .get();

    double totalDayLengthInSeconds = 0;

    for (var doc in lengthDaySnapshot.docs) {
      totalDayLengthInSeconds += (doc['length'] as num).toDouble();
    }

    // Query to get the total length for the last 24 hours
    QuerySnapshot length24HSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('timestamp', isGreaterThanOrEqualTo: twentyFourHoursAgo)
        .get();

    double total24HLengthInSeconds = 0;

    for (var doc in length24HSnapshot.docs) {
      total24HLengthInSeconds += (doc['length'] as num).toDouble();
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
      totalLengthForToday = Duration(
        seconds: totalDayLengthInSeconds.floor(),
        milliseconds: getDecimalPart(totalDayLengthInSeconds),
      );
      totalLengthFor24H = Duration(
        seconds: total24HLengthInSeconds.floor(),
        milliseconds: getDecimalPart(total24HLengthInSeconds),
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
    String collectionName = await AppConfig.getCollectionName();

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

    // Clear the message and reset input fields after 2 seconds
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

  // Function to start a timer for real-time THC updates
  void _startTHCTimer() {
    _THCtimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentTHC = _thcConcentration.calculateTHCAtTime(
                DateTime.now().millisecondsSinceEpoch.toDouble()) *
            1000000.0;
        print(_currentTHC);
      });
    });
  }

  // Fetch real-time inhalation data from Firestore
  Future<void> _fetchRealTimeInhalations() async {
    String collectionName = await AppConfig.getCollectionName();

    _inhalationSubscription = await FirebaseFirestore.instance
        .collection(collectionName)
        .snapshots()
        .listen((snapshot) {
      List<Inhalation> inhalations = snapshot.docs
          .map((doc) {
            final data = doc.data();
            // Check for null values before converting to double
            final time = data['timestamp'].millisecondsSinceEpoch;
            final duration = data['length'];

            // Only add valid inhalations
            if (time != null && duration != null) {
              return Inhalation(
                time: time.toDouble(),
                duration: duration.toDouble(),
              );
            }
            return null; // Return null for invalid entries
          })
          .where((inhalation) => inhalation != null)
          .cast<Inhalation>()
          .toList();
      setState(() {
        _thcConcentration.inhalations = inhalations;
        if (_THCtimer == null) {
          _startTHCTimer(); // Start timer only after data is available
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Welcome $_currentUser',
        onSwapUser: _swapUser,
        onReload: widget.onReload,
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
                            'Total Length for Today: ${_formatDuration(totalLengthForToday)}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Length for Last 24 Hours: ${_formatDuration(totalLengthFor24H)}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current THC Concentration: ${_currentTHC.toStringAsFixed(4)}',
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToManualEntry,
        tooltip: 'Manual Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
