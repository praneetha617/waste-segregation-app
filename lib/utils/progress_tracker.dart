

import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  // Keys
  static const String organicKey = 'completed_organic';
  static const String dryKey = 'completed_dry';
  static const String hazardousKey = 'completed_hazardous';
  static const String mixedKey = 'completed_mixed';

  // Mark any category as completed 
  static Future<void> markCategoryCompleted(String categoryKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(categoryKey, true);
  }

  // Read completion for any category 
  static Future<bool> isCategoryCompleted(String categoryKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(categoryKey) ?? false;
  }

  // Are the 3 base categories finished? 
  static Future<bool> isAllCategoriesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(organicKey) ?? false) &&
           (prefs.getBool(dryKey) ?? false) &&
           (prefs.getBool(hazardousKey) ?? false);
  }

  

  // Has the mixed game been completed?
  static Future<bool> mixedCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(mixedKey) ?? false;
  }

  // Set completion for the mixed game.
  static Future<void> setMixedCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(mixedKey, value);
  }
}
