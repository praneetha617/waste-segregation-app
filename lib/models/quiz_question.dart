class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final List<String> explanations; // Custom explanations for each option

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanations,
  });
}
