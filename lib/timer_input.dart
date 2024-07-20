import 'package:flutter/material.dart';

class TimerInput extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onTimerEnd;

  const TimerInput({
    super.key,
    required this.initialDuration,
    required this.onTimerEnd,
  });

  @override
  _TimerInputState createState() => _TimerInputState();
}

class _TimerInputState extends State<TimerInput> {
  bool _isPressed = false;
  Duration _duration = const Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration;
  }

  @override
  void didUpdateWidget(TimerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDuration != oldWidget.initialDuration) {
      setState(() {
        _duration = widget.initialDuration;
      });
    }
  }

  void _startTimer() {
    setState(() {
      _isPressed = true;
      _duration = const Duration(seconds: 0);
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isPressed) {
        setState(() {
          _duration += const Duration(milliseconds: 100);
        });
        return true;
      }
      return false;
    });
  }

  void _stopTimer() {
    setState(() {
      _isPressed = false;
      widget.onTimerEnd(_duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '${_duration.inSeconds}.${(_duration.inMilliseconds % 1000) ~/ 100}s',
          style: TextStyle(
              fontSize: 24, color: Theme.of(context).colorScheme.onPrimary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: GestureDetector(
            onLongPressStart: (_) => _startTimer(),
            onLongPressEnd: (_) => _stopTimer(),
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Text(
                  'Timer Button',
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
