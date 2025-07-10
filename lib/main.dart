import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeApp(),
    );
  }
}

// Custom Clipper for Bézier curve header
class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7);
    
    // Creating smooth Bézier curves
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height * 0.9, 
      size.width * 0.5, 
      size.height * 0.8
    );
    
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height * 0.7, 
      size.width, 
      size.height * 0.85
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for card waves
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.3);
    
    // Creating wave pattern
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height * 0.1, 
      size.width * 0.5, 
      size.height * 0.3
    );
    
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height * 0.5, 
      size.width, 
      size.height * 0.3
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Floating Action Button with Bézier animation
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final bool isActive;

  const AnimatedFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.color,
    this.isActive = false,
  }) : super(key: key);

  @override
  _AnimatedFABState createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isActive 
                        ? [widget.color, widget.color.withOpacity(0.7)]
                        : [widget.color.withOpacity(0.3), widget.color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isActive ? Colors.white : widget.color,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> with TickerProviderStateMixin {
  // Timer variables
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List<String> laps = [];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void stop() {
    timer?.cancel();
    setState(() {
      started = false;
    });
  }

  void reset() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;
      digitSeconds = "00";
      digitMinutes = "00";
      digitHours = "00";
      started = false;
      laps.clear();
    });
  }

  void start() {
    started = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if (localSeconds > 59) {
        localSeconds = 0;
        localMinutes++;
        if (localMinutes > 59) {
          localMinutes = 0;
          localHours++;
        }
      }

      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
      });
    });
  }

  void addLaps() {
    String lap = "$digitHours:$digitMinutes:$digitSeconds";
    setState(() {
      laps.add(lap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;
    
    final isTablet = screenWidth > 600;
    final isLandscape = orientation == Orientation.landscape;
    
    final titleFontSize = isTablet ? 28.0 : screenWidth * 0.06;
    final timerFontSize = isTablet ? 80.0 : screenWidth * 0.16;
    final lapFontSize = isTablet ? 16.0 : screenWidth * 0.035;
    
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Curved Header with Bézier curves
              ClipPath(
                clipper: BezierClipper(),
                child: Container(
                  height: screenHeight * 0.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF357ABD),
                        Color(0xFF1E3A8A),
                      ],
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated title
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: started ? _pulseAnimation.value : 1.0,
                              child: Text(
                                "STOPWATCH",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Timer display with glow effect
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "$digitHours:$digitMinutes:$digitSeconds",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: timerFontSize,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3.0,
                              fontFamily: 'monospace',
                              shadows: started ? [
                                Shadow(
                                  color: Colors.blue,
                                  blurRadius: 20,
                                ),
                              ] : [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Laps section with wave background
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(horizontalPadding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Animated wave background
                        AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(double.infinity, double.infinity),
                              painter: WavePainter(_waveAnimation.value),
                            );
                          },
                        ),
                        
                        // Laps content
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1E2B47).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              // Laps header
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Laps",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: lapFontSize + 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    if (laps.isNotEmpty)
                                      Text(
                                        "${laps.length} recorded",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: lapFontSize - 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Laps list
                              Expanded(
                                child: laps.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              color: Colors.white30,
                                              size: 48,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              "No laps recorded yet",
                                              style: TextStyle(
                                                color: Colors.white30,
                                                fontSize: lapFontSize,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        itemCount: laps.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.white.withOpacity(0.05),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.1),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${index + 1}",
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    "Lap ${index + 1}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: lapFontSize,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${laps[index]}",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: lapFontSize,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
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
              
              // Control buttons with modern design
              Container(
                padding: EdgeInsets.all(horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Start/Stop button
                    AnimatedFAB(
                      onPressed: () {
                        (!started) ? start() : stop();
                      },
                      icon: started ? Icons.pause : Icons.play_arrow,
                      color: started ? Colors.red : Colors.green,
                      isActive: true,
                    ),
                    
                    // Lap button
                    AnimatedFAB(
                      onPressed: started ? addLaps : () {},
                      icon: Icons.flag,
                      color: Colors.blue,
                      isActive: started,
                    ),
                    
                    // Reset button
                    AnimatedFAB(
                      onPressed: reset,
                      icon: Icons.refresh,
                      color: Colors.orange,
                      isActive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for wave animation
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFF4A90E2).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    Path path = Path();
    
    for (int i = 0; i < 3; i++) {
      path.reset();
      
      double waveHeight = size.height * 0.1;
      double waveLength = size.width;
      double offset = animationValue * 2 * math.pi + (i * math.pi / 3);
      
      path.moveTo(0, size.height * 0.3 + (i * 20));
      
      for (double x = 0; x <= waveLength; x += 1) {
        double y = size.height * 0.3 + (i * 20) + 
                   waveHeight * math.sin((x / waveLength * 2 * math.pi) + offset);
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      paint.color = Color(0xFF4A90E2).withOpacity(0.05 - (i * 0.01));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}