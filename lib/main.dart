import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'tracking_service.dart'; // Create this in /lib
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
  
  await TrackingService.logAppOpened();
  
  runApp(ColorfulTrashGameApp());
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  bool _isRewardsUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkProgress();

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _handAnimation = Tween<double>(begin: 0, end: 0.18).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkProgress() async {
    final unlocked = await ProgressTracker.isAllCategoriesCompleted();
    if (mounted) {
      setState(() {
        _isRewardsUnlocked = unlocked;
      });
    }
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  Widget buildRainbowLetters(String text, double fontSize) {
    final List<Color> rainbowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow[700]!,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    List<TextSpan> spans = [];
    for (int i = 0; i < text.length; i++) {
      if (text[i] == ' ') {
        spans.add(const TextSpan(text: ' '));
      } else {
        spans.add(
          TextSpan(
            text: text[i],
            style: GoogleFonts.fredoka(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: rainbowColors[i % rainbowColors.length],
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black.withAlpha((0.18 * 255).round()),
                  offset: const Offset(1, 2),
                )
              ],
            ),
          ),
        );
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkProgress();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF58CFFB), Color(0xFF28E0AE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
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
                            child: Image.asset(
                              'assets/images/mascot.png',
                              height: 88,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Mascot not found!',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
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
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildRainbowLetters('Colorful Trash Game', 34.0),
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
                            TrackingService.logFeedback('❌ Locked');
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

// Add this HomeButton class BELOW everything else in main.dart:

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
                child: Text(
                  widget.text,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
