import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'waste_category_selection_page.dart';
import 'rewards_page.dart';
import 'utils/progress_tracker.dart';
import 'firebase_options.dart';
import 'mixed_sorting_game_page.dart';
import 'widgets/animated_background_with_bubbles.dart';

// Add global RouteObserver
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final startupWatch = Stopwatch()..start();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
    name: 'debug_test_event',
    parameters: {'platform': 'android', 'status': 'success'},
  );

  await TrackingService.logAppOpened();

  runApp(const ColorfulTrashGameApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    startupWatch.stop();
    final trace = FirebasePerformance.instance
        .newTrace('app_start_to_first_frame');
    await trace.start();
    trace.incrementMetric('elapsed_ms', startupWatch.elapsedMilliseconds);
    await trace.stop();
  });
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
      navigatorObservers: [routeObserver], // added observer
      routes: {
        '/': (context) => const HomePage(),
        '/category': (context) => const WasteCategorySelectionPage(),
        '/rewards': (context) => const RewardsPage(
              rewardTitle: "🎉 Sorting Star!",
              rewardMessage:
                  "You’ve completed Level 1 in all categories!",
              rewardImageAsset: 'assets/images/reward_trophy.png',
              funFact:
                  "Worms love composted food scraps — it’s their favorite treat!",
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

// ---------------- Home Page ------------------
class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, RouteAware {
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  bool _isRewardsUnlocked = false;
  bool _isFunGameUnlocked = false;

  Trace? _homeFirstBuildTrace;

  @override
  void initState() {
    super.initState();
    _homeFirstBuildTrace =
        FirebasePerformance.instance.newTrace('home_initial_build')
          ..start();

    _refreshLocks();
    _handController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _handAnimation = Tween<double>(begin: 0, end: 0.18).animate(
        CurvedAnimation(parent: _handController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _homeFirstBuildTrace?.stop();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route); 
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); 
    _handController.dispose();
    super.dispose();
  }

  // This fires when you return from Quiz or Mixed game
  @override
  void didPopNext() {
    _refreshLocks();
  }

  Future<void> _refreshLocks() async {
    final allDone = await ProgressTracker.isAllCategoriesCompleted();
    if (!mounted) return;
    setState(() {
      _isRewardsUnlocked = allDone;
      _isFunGameUnlocked = allDone;
    });
  }

  Widget buildRainbowLetters(String text, double fontSize) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow[700]!,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple
    ];
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: List.generate(text.length, (i) {
          return TextSpan(
            text: text[i],
            style: GoogleFonts.fredoka(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: text[i] == ' '
                  ? Colors.transparent
                  : colors[i % colors.length],
              shadows: [
                Shadow(
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.18),
                    offset: const Offset(1, 2))
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackgroundWithBubbles(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(36)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 28),
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
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('Mascot not found!',
                                      style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          RotationTransition(
                            turns: _handAnimation,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child:
                                  Text("👋", style: TextStyle(fontSize: 36)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
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
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: buildRainbowLetters('Colorful Trash Game', 34.0),
                      ),
                      const SizedBox(height: 30),

                      // Learn to Sort
                      HomeButton(
                        icon: Icons.school,
                        text: 'Learn to Sort Waste',
                        color: const Color(0xFFB4E2FF),
                        textColor: Colors.blue[900]!,
                        onPressed: () {
                          TrackingService.logCategorySelected('home_entry');
                          final t = FirebasePerformance.instance
                              .newTrace('tap_learn_to_sort');
                          t.start();
                          Navigator.pushNamed(context, '/category')
                              .then((_) => t.stop());
                        },
                      ),

                      // My Rewards
                      HomeButton(
                        icon: Icons.emoji_events,
                        text: 'My Rewards',
                        color: const Color(0xFFFFF7C5),
                        textColor: Colors.orange[900]!,
                        onPressed: () {
                          if (_isRewardsUnlocked) {
                            TrackingService.logReplayTriggered(
                                'reward_page', 'home_screen');
                            final t = FirebasePerformance.instance
                                .newTrace('tap_rewards');
                            t.start();
                            Navigator.pushNamed(context, '/rewards')
                                .then((_) => t.stop());
                          } else {
                            TrackingService.logFeedback('Locked');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    "Complete all 3 levels to unlock your reward!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.orange[700],
                              ),
                            );
                          }
                        },
                      ),

                      // Play Another Fun Game
                      HomeButton(
                        icon: Icons.videogame_asset,
                        text: 'Play Another Fun Game',
                        color: const Color(0xFFD1C4E9),
                        textColor: Colors.deepPurple[900]!,
                        onPressed: () {
                          if (_isFunGameUnlocked) {
                            final t = FirebasePerformance.instance
                                .newTrace('tap_fun_game');
                            t.start();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MixedSortingGamePage()),
                            ).then((_) => t.stop());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    "Unlock this bonus by finishing all 3 categories!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.deepPurple,
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

// ---------------- HomeButton ------------------
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
                    borderRadius: BorderRadius.circular(32)),
              ),
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
