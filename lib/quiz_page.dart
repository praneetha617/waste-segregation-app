import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/quiz_question.dart';
import 'utils/progress_tracker.dart';

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;
  final VoidCallback onQuizComplete;
  final String categoryKey;

  const QuizPage({
    super.key,
    required this.questions,
    required this.onQuizComplete,
    required this.categoryKey,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int _attempts = 0;
  int _mistakes = 0;
  int? _selectedIndex;
  bool _showExplanation = false;
  bool _questionAnswered = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz", style: GoogleFonts.fredoka()),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Question ${_currentQuestion + 1} of ${widget.questions.length}",
                style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              Text(
                question.question,
                style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ...List.generate(question.options.length, (index) {
                Color backgroundColor = Colors.white;
                Color textColor = Colors.black87;

                if (_questionAnswered) {
                  if (index == question.correctIndex) {
                    textColor = Colors.green;
                  } else if (_selectedIndex == index) {
                    textColor = Colors.red;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      elevation: _questionAnswered &&
                              (_selectedIndex == index || index == question.correctIndex)
                          ? 4
                          : 1,
                    ),
                    onPressed: _questionAnswered ? null : () => _handleAnswer(index),
                    child: Text(
                      question.options[index],
                      style: GoogleFonts.fredoka(fontSize: 18, color: textColor),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              if (_showExplanation)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _selectedIndex != null
                        ? question.explanations[_selectedIndex!]
                        : "",
                    style: GoogleFonts.fredoka(fontSize: 16, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_questionAnswered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(180, 45),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestion < widget.questions.length - 1
                        ? "Next"
                        : "See Result",
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(int selected) {
    setState(() {
      _selectedIndex = selected;
      _attempts++;

      if (selected == widget.questions[_currentQuestion].correctIndex) {
        _questionAnswered = true;
        _showExplanation = true;
      } else {
        _showExplanation = true;
        if (_attempts >= 3) {
          _mistakes++;
          _questionAnswered = true;
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _attempts = 0;
      _selectedIndex = null;
      _showExplanation = false;
      _questionAnswered = false;
      if (_currentQuestion < widget.questions.length - 1) {
        _currentQuestion++;
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() async {
    int stars = _mistakes == 0 ? 5 : 4;

    // Mark current category as completed
    await ProgressTracker.markCategoryCompleted(widget.categoryKey);

    // Check if all categories are completed
    bool allCategoriesDone = await ProgressTracker.isAllCategoriesCompleted();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Quiz Complete!", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You’ve finished the quiz!", style: GoogleFonts.fredoka(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(stars, (index) => Icon(Icons.star, color: Colors.amber, size: 36)),
            ),
            if (stars < 5)
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  "Try to get all correct next time for 5 stars!",
                  style: GoogleFonts.fredoka(fontSize: 15, color: Colors.orange[700]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actions: [
          // "Category" button (always visible)
          TextButton(
            child: Text("Category", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/category');
              // Or, to clear the stack: 
              // Navigator.of(context).pushNamedAndRemoveUntil('/category', (route) => false);
            },
          ),
          // "Return to Home" button, only visible if all categories completed
          if (allCategoriesDone)
            TextButton(
              child: Text("Return to Home", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
    );
  }
}
