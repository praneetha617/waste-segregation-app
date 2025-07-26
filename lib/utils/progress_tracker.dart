import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static Future<void> markCategoryCompleted(String categoryKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(categoryKey, true);
  }

  static Future<bool> isCategoryCompleted(String categoryKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(categoryKey) ?? false;
  }

  static Future<bool> isAllCategoriesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('completed_organic') ?? false) &&
           (prefs.getBool('completed_dry') ?? false) &&
           (prefs.getBool('completed_hazardous') ?? false);
  }
}
