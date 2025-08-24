import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/progress_tracker.dart';
import 'quiz_page.dart';
import 'data/quiz_data.dart'; 

// Mixed Sorting Game Page
enum WasteType { organic, dry, hazardous }

class WasteItem {
  final String name;
  final String imagePath;
  final WasteType type;
  const WasteItem({
    required this.name,
    required this.imagePath,
    required this.type,
  });
}

class MixedSortingGamePage extends StatefulWidget {
  const MixedSortingGamePage({super.key});

  @override
  State<MixedSortingGamePage> createState() => _MixedSortingGamePageState();
}

class _MixedSortingGamePageState extends State<MixedSortingGamePage> {
  // ⏱️ slightly harder than category mode
  static const int _secondsPerItem = 7;

  int _score = 0;
  WasteItem? _currentItem;
  int _remainingTime = _secondsPerItem;
  Timer? _timer;

  // All items for mixed sorting
  final List<WasteItem> _allItems = const [
    WasteItem(name: 'Banana Peel',        imagePath: 'assets/images/banana.png',        type: WasteType.organic),
    WasteItem(name: 'Vegetable Skin',     imagePath: 'assets/images/vegetable.png',     type: WasteType.organic),
    WasteItem(name: 'Apple Core',         imagePath: 'assets/images/apple_core.png',    type: WasteType.organic),
    WasteItem(name: 'Plastic Bottle',     imagePath: 'assets/images/bottle.png',        type: WasteType.dry),
    WasteItem(name: 'Tissue Paper',       imagePath: 'assets/images/tissue.png',        type: WasteType.dry),
    WasteItem(name: 'Newspaper',          imagePath: 'assets/images/newspaper.png',     type: WasteType.dry),
    WasteItem(name: 'Battery',            imagePath: 'assets/images/battery.png',       type: WasteType.hazardous),
    WasteItem(name: 'Paint Can',          imagePath: 'assets/images/paint_can.png',     type: WasteType.hazardous),
    WasteItem(name: 'Nail Polish Bottle', imagePath: 'assets/images/nail_polish.png',   type: WasteType.hazardous),
  ];

  late List<WasteItem> _remainingItems;

  @override
  void initState() {
    super.initState();
    _remainingItems = List.of(_allItems)..shuffle();
    _loadNextItem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = _secondsPerItem;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        t.cancel();
        _showSnack("⏳ Time's up! Moving on.", Colors.orange);
        _loadNextItem();
      }
    });
  }

  void _loadNextItem() {
    _timer?.cancel();
    if (_remainingItems.isEmpty) {
      setState(() => _currentItem = null);
      _goToMixedQuiz();
      return;
    }
    _remainingItems.shuffle();
    setState(() => _currentItem = _remainingItems.first);
    _startTimer();
  }

  void _handleDrop(WasteItem item, WasteType binType) {
    final correct = item.type == binType;
    if (correct) {
      setState(() {
        _score++;
        _remainingItems.remove(item);
      });
      _timer?.cancel();
      _showSnack("Good!", Colors.green);
      Future.delayed(const Duration(milliseconds: 500), _loadNextItem);
    } else {
      _showSnack("Wrong bin! Try again.", Colors.red);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // After mixed game: go to a quiz built from your existing question pools
  void _goToMixedQuiz() {
    if (!mounted) return;

    final all = [
      ...wetWasteQuestions,
      ...dryWasteQuestions,
      ...hazardousWasteQuestions,
    ]..shuffle();
    final mixedQuestions = all.take(9).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          questions: mixedQuestions,
          categoryKey: 'completed_mixed',
          onQuizComplete: () async {
            await ProgressTracker.setMixedCompleted(true);
            if (!mounted) return;
            Navigator.of(context).pop(); // close QuizPage
            Navigator.of(context).pop(); // back to Home
          },
        ),
      ),
    );
  }

  /// Responsive bin with dynamic [size]. Adds hover highlight & subtle scale.
  Widget _buildBin(WasteType binType, Color color, String label, double size) {
    return DragTarget<WasteItem>(
      onAcceptWithDetails: (details) => _handleDrop(details.data, binType),
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;
        return AnimatedScale(
          scale: isHover ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: isHover ? color.withOpacity(0.9) : color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  )
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: GoogleFonts.fredoka(
                      fontSize: (size * 0.18).clamp(11.0, 16.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Builds adaptive bins based on screen size
  Widget _buildAdaptiveBins(BuildContext context) {
    final mq = MediaQuery.of(context);
    final shortest = mq.size.shortestSide;
    final isPhone = shortest < 600;

    // Define min/max sizes for bins based on device type
    const double phoneMin = 64.0;
    const double phoneMax = 104.0;
    const double tabMin = 72.0;
    const double tabMax = 128.0;

    final double kMinBin = isPhone ? phoneMin : tabMin;
    final double kMaxBin = isPhone ? phoneMax : tabMax;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = isPhone ? 10.0 : 12.0;
        final double w = constraints.maxWidth;

        int pickColumns(double width) {
          for (int cols = 3; cols >= 1; cols--) {
            final size = (width - (cols - 1) * spacing) / cols;
            if (size >= kMinBin) return cols;
          }
          return 1;
        }

        final cols = pickColumns(w);
        final double rawSize = (w - (cols - 1) * spacing) / cols;
        final double binSize = rawSize.clamp(kMinBin, kMaxBin).toDouble();
        final double contentMaxWidth = cols * binSize + (cols - 1) * spacing;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _buildBin(WasteType.hazardous, Colors.red[700]!, "Domestic\nhazardous\nwaste", binSize),
                _buildBin(WasteType.organic,  Colors.green[700]!, "Wet/organic\nwaste", binSize),
                _buildBin(WasteType.dry,      Colors.blue[700]!,  "Dry/recyclable\nwaste", binSize),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _allItems.length;

    // Determine item size based on device type
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    // This keeps the item comfortably smaller than phone binMax (104)
    final double itemImageSize = isPhone ? 72.0 : 96.0;

    return Scaffold(
      backgroundColor: const Color(0xFFACE7FF),
      appBar: AppBar(
        title: Text(
          "Mixed Sorting (All Bins)",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Score / Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Score: $_score/$total',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time: $_remainingTime s',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Current item
            if (_currentItem != null) ...[
              Draggable<WasteItem>(
                data: _currentItem!,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Material(
                  type: MaterialType.transparency,
                  child: Image.asset(_currentItem!.imagePath, height: itemImageSize),
                ),
                childWhenDragging:
                    Opacity(opacity: 0.3, child: Image.asset(_currentItem!.imagePath, height: itemImageSize)),
                child: Image.asset(_currentItem!.imagePath, height: itemImageSize),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  _currentItem!.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ] else ...[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Great job! Quiz coming up… ✨",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Spacer(),
            ],

            const Spacer(),

            // Adaptive bins
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              child: _buildAdaptiveBins(context),
            ),
          ],
        ),
      ),
    );
  }
}

