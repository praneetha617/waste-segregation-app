import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'waste_category_selection_page.dart';
import 'rewards_page.dart';
import 'utils/progress_tracker.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
    name: 'debug_test_event',
    parameters: {'platform': 'android', 'status': 'success'},
  );

  await TrackingService.logAppOpened();

  runApp(const ColorfulTrashGameApp());
}

class ColorfulTrashGameApp extends StatelessWidget {
  const ColorfulTrashGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorful Trash Game',
      theme: ThemeData(
        fontFamily: GoogleFonts.fredoka().fontFamily,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/category': (context) => const WasteCategorySelectionPage(),
        '/rewards': (context) => const RewardsPage(
              rewardTitle: "🎉 Sorting Star!",
              rewardMessage: "You’ve completed Level 1 in all categories!",
              rewardImageAsset: 'assets/images/reward_trophy.png',
              funFact: "Worms love composted food scraps — it’s their favorite treat!",
            ),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

// BALLOON MODEL
class _Balloon {
  double x, y;
  double size;
  bool popped;

  _Balloon({
    required this.x,
    required this.y,
    required this.size,
  }) : popped = false; // Default initialized
}

// ANIMATED BACKGROUND WITH BUBBLES AND BALLOONS
class AnimatedBackgroundWithBubbles extends StatefulWidget {
  final Widget child;
  const AnimatedBackgroundWithBubbles({super.key, required this.child});

  @override
  State<AnimatedBackgroundWithBubbles> createState() =>
      _AnimatedBackgroundWithBubblesState();
}

class _AnimatedBackgroundWithBubblesState extends State<AnimatedBackgroundWithBubbles>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _bubbleController;
  final Random _random = Random();
  List<_Bubble> _bubbles = [];
  final List<_Balloon> _balloons = [];
  bool _showImageBackground = true;

  @override
  void initState() {
    super.initState();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

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
      if (_balloons.length < 4) {
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

  void _moveBalloons() {
    setState(() {
      for (var balloon in _balloons) {
        if (!balloon.popped) balloon.y -= 0.002;
      }
      _balloons.removeWhere((b) => b.y < -0.2 || b.popped);
    });
  }

  void _popBalloon(_Balloon balloon) {
    setState(() {
      balloon.popped = true;
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _moveBalloons();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showImageBackground)
          Image.asset('assets/images/background_city.png', fit: BoxFit.cover),

        // Gradient Overlay
        AnimatedBuilder(
          animation: _colorController,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(const Color(0xFF58CFFB), const Color(0xFF28E0AE), _colorController.value)!.withValues(alpha: 0.25),
                    Color.lerp(const Color(0xFF28E0AE), const Color(0xFF58CFFB), _colorController.value)!.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),

        // Floating Bubbles
        AnimatedBuilder(
          animation: Listenable.merge([_colorController, _bubbleController]),
          builder: (context, child) {
            for (var bubble in _bubbles) {
              bubble.y -= bubble.speed * 30;
              bubble.x += bubble.drift;
              if (bubble.y < -0.05) {
                bubble.y = 1.2;
                bubble.x = _random.nextDouble();
              }
              if (bubble.x < -0.05 || bubble.x > 1.05) bubble.drift = -bubble.drift;
            }
            return CustomPaint(painter: _BubblesPainter(_bubbles));
          },
        ),

        // Balloons (Clickable)
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
                  child: Image.asset('assets/images/balloon.png', width: balloon.size, height: balloon.size),
                ),
              ),
            ),
          );
        }),

        // Main Content
        widget.child,

        // Toggle Background Button
        Positioned(
          top: 30,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: () => setState(() => _showImageBackground = !_showImageBackground),
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
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: bubble.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        bubble.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  bool _isRewardsUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkProgress();
    _handController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _handAnimation = Tween<double>(begin: 0, end: 0.18).animate(CurvedAnimation(parent: _handController, curve: Curves.easeInOut));
  }

  Future<void> _checkProgress() async {
    final unlocked = await ProgressTracker.isAllCategoriesCompleted();
    if (mounted) setState(() => _isRewardsUnlocked = unlocked);
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  Widget buildRainbowLetters(String text, double fontSize) {
    final colors = [Colors.red, Colors.orange, Colors.yellow[700]!, Colors.green, Colors.blue, Colors.indigo, Colors.purple];
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: List.generate(text.length, (i) {
          return TextSpan(
            text: text[i],
            style: GoogleFonts.fredoka(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: text[i] == ' ' ? Colors.transparent : colors[i % colors.length],
              shadows: [Shadow(blurRadius: 3, color: Colors.black.withValues(alpha: 0.18), offset: const Offset(1, 2))],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkProgress();
    return Scaffold(
      body: AnimatedBackgroundWithBubbles(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(36)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset('assets/images/mascot.png', height: 88,
                              errorBuilder: (context, error, stackTrace) => const Text('Mascot not found!', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          RotationTransition(
                            turns: _handAnimation,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text("👋", style: TextStyle(fontSize: 36)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.lightBlue, width: 1.8),
                        ),
                        child: Text(
                          "Hey! Ready for some colorful recycling fun? 🎉",
                          style: GoogleFonts.fredoka(fontSize: 16, color: Colors.blueGrey[700], fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title Highlighted
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: buildRainbowLetters('Colorful Trash Game', 34.0),
                      ),
                      const SizedBox(height: 30),
                      HomeButton(
                        icon: Icons.school,
                        text: 'Learn to Sort Waste',
                        color: const Color(0xFFB4E2FF),
                        textColor: Colors.blue[900]!,
                        onPressed: () {
                          TrackingService.logCategorySelected('home_entry');
                          Navigator.pushNamed(context, '/category');
                        },
                      ),
                      HomeButton(
                        icon: Icons.emoji_events,
                        text: 'My Rewards',
                        color: const Color(0xFFFFF7C5),
                        textColor: Colors.orange[900]!,
                        onPressed: () {
                          if (_isRewardsUnlocked) {
                            TrackingService.logReplayTriggered('reward_page', 'home_screen');
                            Navigator.pushNamed(context, '/rewards');
                          } else {
                            TrackingService.logFeedback('Locked');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Complete all 3 levels to unlock your reward!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.orange[700],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// HomeButton Class
class HomeButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 80),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(widget.icon, color: widget.textColor, size: 28),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(widget.text,
                    style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold, color: widget.textColor)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
