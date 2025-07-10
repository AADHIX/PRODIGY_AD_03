import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> with TickerProviderStateMixin {
  // Timer variables
  int _milliseconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  final List<Duration> _laps = [];
  
  // Animation controller for smooth transitions
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // Convert milliseconds to Duration
  Duration get _currentTime => Duration(milliseconds: _milliseconds);

  // Format duration to string
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds.$milliseconds';
    } else {
      return '$minutes:$seconds.$milliseconds';
    }
  }

  // Start timer function
  void _start() {
    setState(() {
      _isRunning = true;
    });
    
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _milliseconds += 10;
      });
    });
  }

  // Stop timer function
  void _stop() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  // Reset function
  void _reset() {
    _timer?.cancel();
    _pulseController.reset();
    setState(() {
      _milliseconds = 0;
      _isRunning = false;
      _laps.clear();
    });
  }

  // Add lap function
  void _addLap() {
    if (_isRunning) {
      setState(() {
        _laps.add(_currentTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2757),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            
            final isTablet = screenWidth > 600;
            final isLandscape = screenWidth > screenHeight;
            
            // Responsive dimensions
            final titleFontSize = isTablet ? 36.0 : (screenWidth * 0.07);
            final timerFontSize = isTablet ? 80.0 : (screenWidth * 0.15);
            final lapFontSize = isTablet ? 18.0 : (screenWidth * 0.04);
            
            final horizontalPadding = screenWidth * 0.04;
            final verticalSpacing = screenHeight * 0.02;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing,
              ),
              child: Column(
                children: [
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blue, Colors.cyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: Text(
                      "Stopwatch",
                      style: TextStyle(
                        color: const Color.fromARGB(242, 241, 116, 14),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: verticalSpacing * 2),
                  
                  // Timer display with animation
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRunning ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF323F68).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatDuration(_currentTime),
                              style: TextStyle(
                                color: const Color.fromARGB(242, 241, 116, 14),
                                fontSize: timerFontSize,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2.0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: verticalSpacing * 2),
                  
                  // Laps section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF323F68).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Laps header
                          Container(
                            padding: EdgeInsets.all(isTablet ? 20.0 : 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Laps (${_laps.length})",
                                  style: TextStyle(
                                    color: const Color.fromARGB(242, 241, 116, 14),
                                    fontSize: lapFontSize * 1.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_laps.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _laps.clear();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.clear_all,
                                      color: const Color.fromARGB(242, 241, 116, 14),
                                    ),
                                    tooltip: "Clear all laps",
                                  ),
                              ],
                            ),
                          ),
                          
                          // Laps list
                          Expanded(
                            child: _laps.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          color: Colors.white54,
                                          size: isTablet ? 48.0 : 36.0,
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          "No laps recorded",
                                          style: TextStyle(
                                            color: const Color.fromARGB(242, 241, 116, 14),
                                            fontSize: lapFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 20.0 : 15.0,
                                    ),
                                    itemCount: _laps.length,
                                    itemBuilder: (context, index) {
                                      final lapTime = _laps[index];
                                      final lapDiff = index > 0 
                                          ? Duration(milliseconds: 
                                              lapTime.inMilliseconds - _laps[index - 1].inMilliseconds)
                                          : lapTime;
                                      
                                      return Card(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isTablet ? 12.0 : 8.0,
                                            horizontal: isTablet ? 16.0 : 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.2),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Lap ${index + 1}",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(242, 241, 116, 14),
                                                  fontSize: lapFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatDuration(lapTime),
                                                    style: TextStyle(
                                                      color: const Color.fromARGB(242, 241, 116, 14),
                                                      fontSize: lapFontSize,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  if (index > 0)
                                                    Text(
                                                      "+${_formatDuration(lapDiff)}",
                                                      style: TextStyle(
                                                        color: Colors.blue.withOpacity(0.7),
                                                        fontSize: lapFontSize * 0.8,
                                                        fontWeight: FontWeight.w300,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: verticalSpacing * 2),
                  
                  // Control buttons
                  Row(
                    children: [
                      // Start/Stop button
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: isTablet ? 60.0 : 50.0,
                          child: ElevatedButton(
                            onPressed: _isRunning ? _stop : _start,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRunning ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              elevation: 5.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow,
                                  size: isTablet ? 24.0 : 20.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  _isRunning ? "Pause" : "Start",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18.0 : 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: screenWidth * 0.03),
                      
                      // Lap button
                      Container(
                        height: isTablet ? 60.0 : 50.0,
                        width: isTablet ? 60.0 : 50.0,
                        child: ElevatedButton(
                          onPressed: _isRunning ? _addLap : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 5.0,
                          ),
                          child: Icon(
                            Icons.flag,
                            size: isTablet ? 28.0 : 24.0,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: screenWidth * 0.03),
                      
                      // Reset button
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: isTablet ? 60.0 : 50.0,
                          child: ElevatedButton(
                            onPressed: _reset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              elevation: 5.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: isTablet ? 24.0 : 20.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18.0 : 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}