import 'dart:async';
import 'package:flutter/material.dart';
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
  int _remainingTime = 10; // ✅ 10-second timer
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
    _remainingTime = 10; // ✅ reset to 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _startTimer(); // ✅ Start timer for each item
  }

  void _handleDrop(WasteItem item, WasteType binType) {
    bool isCorrect = item.type == binType;
    TrackingService.logDragAttempt(item.name, isCorrect);

    if (isCorrect) {
      setState(() {
        _score++;
        _remainingItems.remove(item);
      });
      _timer?.cancel();
      _showFeedback("✅ Good!", Colors.green);
      Future.delayed(const Duration(milliseconds: 600), _loadNextItem);
    } else {
      _showFeedback("❌ Wrong bin! Try again.", Colors.red);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w500)),
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

  Widget _buildBin(WasteType binType, Color color, String label) {
    return DragTarget<WasteItem>(
      onAcceptWithDetails: (details) => _handleDrop(details.data, binType),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 110,
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Score: $_score',
                  style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Text(
                  'Time: $_remainingTime s',
                  style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_currentItem != null) ...[
              Draggable<WasteItem>(
                data: _currentItem!,
                feedback: Image.asset(_currentItem!.imagePath, height: 90),
                childWhenDragging: Opacity(opacity: 0.3, child: Image.asset(_currentItem!.imagePath, height: 90)),
                child: Image.asset(_currentItem!.imagePath, height: 90),
              ),
              const SizedBox(height: 20),
              Text(
                _currentItem!.name,
                style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ] else ...[
              const Spacer(),
              Text(
                "Great job! You finished the game! 🎉",
                style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBin(WasteType.hazardous, Colors.red[700]!, "Domestic\nhazardous\nwaste"),
                  _buildBin(WasteType.organic, Colors.green[700]!, "Wet/organic\nwaste"),
                  _buildBin(WasteType.dry, Colors.blue[700]!, "Dry/recyclable\nwaste"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
