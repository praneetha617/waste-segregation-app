
import 'dart:async';
import 'package:flutter/material.dart';
// precise dragging
import 'package:google_fonts/google_fonts.dart';

import 'tracking_service.dart';
import 'models/quiz_question.dart';
import 'quiz_page.dart';
import 'data/quiz_data.dart';
import 'utils/progress_tracker.dart';
import 'waste_category_selection_page.dart';
import 'main.dart'; // for HomePage

enum WasteType { organic, dry, hazardous }

class WasteItem {
  final String name;
  final String imagePath;
  final WasteType type;

  WasteItem({
    required this.name,
    required this.imagePath,
    required this.type,
  });
}

class SortingGamePage extends StatefulWidget {
  final WasteType selectedType;
  const SortingGamePage({super.key, required this.selectedType});

  @override
  State<SortingGamePage> createState() => _SortingGamePageState();
}

class _SortingGamePageState extends State<SortingGamePage> {
  int _score = 0;
  WasteItem? _currentItem;
  int _remainingTime = 10; // 10-second timer
  Timer? _timer;

  final List<WasteItem> _allItems = [
    WasteItem(name: 'Banana Peel', imagePath: 'assets/images/banana.png', type: WasteType.organic),
    WasteItem(name: 'Vegetable Skin', imagePath: 'assets/images/vegetable.png', type: WasteType.organic),
    WasteItem(name: 'Apple Core', imagePath: 'assets/images/apple_core.png', type: WasteType.organic),
    WasteItem(name: 'Plastic Bottle', imagePath: 'assets/images/bottle.png', type: WasteType.dry),
    WasteItem(name: 'Tissue Paper', imagePath: 'assets/images/tissue.png', type: WasteType.dry),
    WasteItem(name: 'Newspaper', imagePath: 'assets/images/newspaper.png', type: WasteType.dry),
    WasteItem(name: 'Battery', imagePath: 'assets/images/battery.png', type: WasteType.hazardous),
    WasteItem(name: 'Paint Can', imagePath: 'assets/images/paint_can.png', type: WasteType.hazardous),
    WasteItem(name: 'Nail Polish Bottle', imagePath: 'assets/images/nail_polish.png', type: WasteType.hazardous),
  ];

  late List<WasteItem> _remainingItems;

  @override
  void initState() {
    super.initState();
    _remainingItems = _allItems.where((item) => item.type == widget.selectedType).toList();
    _loadNextItem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 10; // Reset to 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        _showFeedback("⏳ Time's up! Moving to next item.", Colors.orange);
        _loadNextItem();
      }
    });
  }

  void _loadNextItem() {
    _timer?.cancel();
    if (_remainingItems.isEmpty) {
      setState(() => _currentItem = null);
      _goToQuizPage();
      return;
    }
    _remainingItems.shuffle();
    setState(() {
      _currentItem = _remainingItems.first;
    });
    _startTimer(); // Start timer for each item
  }

  void _handleDrop(WasteItem item, WasteType binType) {
    final isCorrect = item.type == binType;
    TrackingService.logDragAttempt(item.name, isCorrect);

    if (isCorrect) {
      setState(() {
        _score++;
        _remainingItems.remove(item);
      });
      _timer?.cancel();
      _showFeedback("Good!", Colors.green);
      Future.delayed(const Duration(milliseconds: 600), _loadNextItem);
    } else {
      _showFeedback(" Wrong bin! Try Smart.", Colors.red);
    }
  }

  void _showFeedback(String message, Color color) {
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
        duration: const Duration(milliseconds: 1000),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _goToQuizPage() {
    List<QuizQuestion> quizQuestions;
    String categoryKey;
    bool goHomeAfterQuiz = false;

    if (widget.selectedType == WasteType.organic) {
      quizQuestions = wetWasteQuestions;
      categoryKey = 'completed_organic';
    } else if (widget.selectedType == WasteType.dry) {
      quizQuestions = dryWasteQuestions;
      categoryKey = 'completed_dry';
    } else {
      quizQuestions = hazardousWasteQuestions;
      categoryKey = 'completed_hazardous';
      goHomeAfterQuiz = true;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          questions: quizQuestions,
          categoryKey: categoryKey,
          onQuizComplete: () async {
            if (!mounted) return;

            await ProgressTracker.markCategoryCompleted(categoryKey);
            if (!mounted) return;

            Navigator.of(context).pop();

            if (!mounted) return;

            if (goHomeAfterQuiz) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WasteCategorySelectionPage()),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }

  /// Responsive bin with dynamic [size]. Used FittedBox so long labels scale down.
  Widget _buildBin(WasteType binType, Color color, String label, double size) {
    return DragTarget<WasteItem>(
      onAcceptWithDetails: (details) => _handleDrop(details.data, binType),
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: size,
          height: size, // square target for consistent hit-testing
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Builds a bins layout that adapts to narrow phones:
  // Picks 3/2/1 columns based on width
  // Ensures each bin is at least kMinBin for touch usability
  Widget _buildAdaptiveBins(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const double kMinBin = 54.0; // touch-safe minimum 
        const double kMaxBin = 100.0;

        final double w = constraints.maxWidth;

        int pickColumns(double width) {
          for (int cols = 3; cols >= 1; cols--) {
            final size = (width - (cols - 1) * spacing) / cols;
            if (size >= kMinBin) return cols;
          }
          return 1;
        }

        final cols = pickColumns(w);
        final binSize = ((w - (cols - 1) * spacing) / cols).clamp(kMinBin, kMaxBin);

        // Calculate the total width for centering
        // This ensures the bins are centered in the available space
        final contentMaxWidth = cols * binSize + (cols - 1) * spacing;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _buildBin(WasteType.hazardous, Colors.red[700]!, "Domestic\nhazardous\nwaste", binSize),
                _buildBin(WasteType.organic, Colors.green[700]!, "Wet/organic\nwaste", binSize),
                _buildBin(WasteType.dry, Colors.blue[700]!, "Dry/recyclable\nwaste", binSize),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFACE7FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Score / Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Score: $_score',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time: $_remainingTime s',
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current item
            if (_currentItem != null) ...[
              Draggable<WasteItem>(
                data: _currentItem!,
                
                // This allows the item to be dragged from anywhere within its bounds
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Image.asset(_currentItem!.imagePath, height: 68),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Image.asset(_currentItem!.imagePath, height: 68),
                ),
                child: Image.asset(_currentItem!.imagePath, height: 68),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  _currentItem!.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ] else ...[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Great job! You finished the game! 🎉",
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

            // Bins
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
