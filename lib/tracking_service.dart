import 'package:firebase_analytics/firebase_analytics.dart';

class TrackingService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAppOpened() async {
    await _analytics.logAppOpen();
  }

  static Future<void> logCategorySelected(String categoryColor) async {
    await _analytics.logEvent(
      name: 'category_selected',
      parameters: {'category_color': categoryColor},
    );
  }

  static Future<void> logVideoCompleted(String language, int durationSeconds) async {
    await _analytics.logEvent(
      name: 'video_completed',
      parameters: {
        'language': language,
        'duration_watched': durationSeconds,
      },
    );
  }

  static Future<void> logDragAttempt(String itemName, bool correct) async {
    await _analytics.logEvent(
      name: 'drag_attempt',
      parameters: {
        'item_name': itemName,
        'correct': correct,
      },
    );
  }

  static Future<void> logQuizAttempt({
    required String questionId,
    required int attemptNumber,
    required bool correct,
    String? category,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_attempt',
      parameters: {
        'question_id': questionId,
        'attempt_number': attemptNumber,
        'correct': correct,
        if (category != null) 'category': category,
      },
    );
  }

  static Future<void> logFeedback(String emojiRating) async {
    await _analytics.logEvent(
      name: 'feedback_response',
      parameters: {'emoji_rating': emojiRating},
    );
  }

  static Future<void> logReplayTriggered(String category, String source) async {
    await _analytics.logEvent(
      name: 'replay_triggered',
      parameters: {
        'category': category,
        'source': source,
      },
    );
  }
}
