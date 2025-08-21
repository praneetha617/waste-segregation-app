  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'models/quiz_question.dart';
  import 'utils/progress_tracker.dart';
  import 'tracking_service.dart';

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
        backgroundColor: Colors.black, // For dark background
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Question ${_currentQuestion + 1} of ${widget.questions.length}",
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[300]),
                ),
                const SizedBox(height: 20),
                Text(
                  question.question,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[400], // Question text in green
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ...List.generate(question.options.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  bool isCorrect = index == question.correctIndex;
                  bool isWrongSelected = isSelected && !isCorrect;

                  Color textColor = Colors.white;
                  if (_questionAnswered) {
                    if (isCorrect) {
                      textColor = Colors.green;
                    } else if (isWrongSelected) {
                      textColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        elevation: _questionAnswered && (isSelected || isCorrect) ? 4 : 1,
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
                      color: const Color(0xFFFFF8E1), // Light yellow background
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
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(160, 45),
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
                  ),
              ],
            ),
          ),
        ),
      );
    }

    void _handleAnswer(int selected) {
      final currentQ = widget.questions[_currentQuestion];
      final isCorrect = selected == currentQ.correctIndex;

      setState(() {
        _selectedIndex = selected;
        _attempts++;
        _showExplanation = true;

        // Immediately show Next button if correct, or after 3 tries
        if (isCorrect || _attempts >= 3) {
          if (!isCorrect) _mistakes++;
          _questionAnswered = true;
        }
      });

      // Log attempt (non-blocking)
      TrackingService.logQuizAttempt(
        questionId: currentQ.id,
        attemptNumber: _attempts,
        correct: isCorrect,
      );
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

      await ProgressTracker.markCategoryCompleted(widget.categoryKey);
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
              Text("You’ve finished the quiz in 1 attempt!", style: GoogleFonts.fredoka(fontSize: 18)),
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
            TextButton(
              child: Text("Go back Category page", style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/category');
              },
            ),
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
