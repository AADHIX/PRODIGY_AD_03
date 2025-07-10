import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

/// Root of the App
class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stopwatch App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFFFA07A),
          secondary: Colors.white,
        ),
      ),
      home: const StopwatchScreen(),
    );
  }
}

/// Home Screen StatefulWidget
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

/// Stopwatch State & UI
class _StopwatchScreenState extends State<StopwatchScreen>
    with TickerProviderStateMixin {
  int _milliseconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  final List<Duration> _laps = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Duration get _currentTime => Duration(milliseconds: _milliseconds);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final ms = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds.$ms'
        : '$minutes:$seconds.$ms';
  }

  void _start() {
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _milliseconds += 10;
      });
    });
    setState(() => _isRunning = true);
  }

  void _stop() {
    _pulseController.stop();
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _pulseController.reset();
    _timer?.cancel();
    setState(() {
      _milliseconds = 0;
      _laps.clear();
      _isRunning = false;
    });
  }

  void _addLap() {
    if (_isRunning) {
      setState(() => _laps.add(_currentTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFFFFA07A);
    final Color secondary = Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// Title
              Text(
                "Stopwatch",
                style: TextStyle(
                  fontSize: 32,
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              /// Timer Display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDuration(_currentTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: secondary,
                        letterSpacing: 2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Laps Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _laps.isEmpty
                      ? Center(
                          child: Text(
                            "No laps recorded",
                            style: TextStyle(color: primary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _laps.length,
                          itemBuilder: (_, index) {
                            final lap = _laps[index];
                            final diff = index == 0
                                ? lap
                                : lap - _laps[index - 1];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Lap ${index + 1}",
                                    style: TextStyle(
                                        color: primary, fontSize: 16),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatDuration(lap),
                                        style: TextStyle(color: secondary),
                                      ),
                                      if (index > 0)
                                        Text(
                                          "+${_formatDuration(diff)}",
                                          style: TextStyle(
                                            color: primary.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 20),

              /// Buttons: Start/Pause - Lap - Reset
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? _stop : _start,
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(_isRunning ? "Pause" : "Start"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isRunning ? Colors.red : Colors.green,
                        foregroundColor: secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isRunning ? _addLap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: secondary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.flag),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
