

import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackgroundWithBubbles extends StatefulWidget {
  final Widget child;
  const AnimatedBackgroundWithBubbles({super.key, required this.child});

  @override
  State<AnimatedBackgroundWithBubbles> createState() =>
      _AnimatedBackgroundWithBubblesState();
}

class _AnimatedBackgroundWithBubblesState
    extends State<AnimatedBackgroundWithBubbles>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _tickController; // drives both bubbles & balloons
  final Random _random = Random();

  List<_Bubble> _bubbles = [];
  final List<_Balloon> _balloons = [];

  bool _showImageBackground = true;
  bool _spawnerActive = true;

  @override
  void initState() {
    super.initState();

    _colorController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);

    // controller that ticks every 60fps
    _tickController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();

    _tickController.addListener(_tickWorld);

    _generateBubbles();
    _spawnBalloonsPeriodically();
  }

  void _generateBubbles() {
    _bubbles = List.generate(15, (index) {
      return _Bubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 20 + 10,
        speed: _random.nextDouble() * 0.0005 + 0.0002,
        drift: _random.nextDouble() * 0.001 - 0.0005,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      );
    });
  }

  void _spawnBalloonsPeriodically() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || !_spawnerActive) return false;
      if (_balloons.length < 5) {
        setState(() {
          _balloons.add(_Balloon(
            x: _random.nextDouble() * 0.8 + 0.1,
            y: 1.2,
            size: _random.nextDouble() * 40 + 60,
          ));
        });
      }
      return true;
    });
  }

  void _tickWorld() {
    if (!mounted) return;

    // move bubbles
    for (var bubble in _bubbles) {
      bubble.y -= bubble.speed * 30;
      bubble.x += bubble.drift;
      if (bubble.y < -0.05) {
        bubble.y = 1.2;
        bubble.x = _random.nextDouble();
      }
      if (bubble.x < -0.05 || bubble.x > 1.05) bubble.drift = -bubble.drift;
    }

    // move balloons upward
    for (var b in _balloons) {
      if (!b.popped) b.y -= 0.002;
    }
    _balloons.removeWhere((b) => b.y < -0.2 || b.popped);

    setState(() {}); // repaint
  }

  void _popBalloon(_Balloon balloon) {
    setState(() => balloon.popped = true);
  }

  @override
  void dispose() {
    _spawnerActive = false;
    _colorController.dispose();
    _tickController.removeListener(_tickWorld);
    _tickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showImageBackground)
          Image.asset('assets/images/background_city.png', fit: BoxFit.cover),

        // Gradient overlay
        AnimatedBuilder(
          animation: _colorController,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(const Color(0xFF58CFFB), const Color(0xFF28E0AE),
                            _colorController.value)!
                        // ignore: deprecated_member_use
                        .withOpacity(0.25),
                    Color.lerp(const Color(0xFF28E0AE), const Color(0xFF58CFFB),
                            _colorController.value)!
                        // ignore: deprecated_member_use
                        .withOpacity(0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),

        // Draw bubbles
        CustomPaint(painter: _BubblesPainter(_bubbles)),

        // Balloons (tap to pop)
        ..._balloons.map((balloon) {
          return Positioned(
            left: balloon.x * MediaQuery.of(context).size.width,
            top: balloon.y * MediaQuery.of(context).size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _popBalloon(balloon),
              child: AnimatedOpacity(
                opacity: balloon.popped ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: balloon.popped ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    'assets/images/balloon.png',
                    width: balloon.size,
                    height: balloon.size,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          );
        }),

        // Foreground child content
        widget.child,

        // Toggle button
        Positioned(
          top: 30,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: () =>
                setState(() => _showImageBackground = !_showImageBackground),
            child: Icon(_showImageBackground ? Icons.image : Icons.gradient),
          ),
        ),
      ],
    );
  }
}

class _Bubble {
  double x, y, radius, speed, drift, opacity;
  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  });
}

class _BubblesPainter extends CustomPainter {
  final List<_Bubble> bubbles;
  _BubblesPainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var b in bubbles) {
      final paint = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.white.withOpacity(b.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(b.x * size.width, b.y * size.height),
        b.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _Balloon {
  double x, y;
  double size;
  bool popped;
  _Balloon({
    required this.x,
    required this.y,
    required this.size,
  }) : popped = false;
}
