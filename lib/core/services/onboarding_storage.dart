import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local offline persistence service for onboarding state
class OnboardingStorage {
  static const String _onboardingKey = 'ty_onboarding_completed_v1';

  /// Check whether the user has previously completed the onboarding flow
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('[OnboardingStorage] Error reading onboarding state: $e');
      return false;
    }
  }

  /// Mark onboarding as completed (stored locally on disk)
  static Future<bool> setOnboardingCompleted({bool completed = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_onboardingKey, completed);
    } catch (e) {
      debugPrint('[OnboardingStorage] Error saving onboarding state: $e');
      return false;
    }
  }

  /// Reset onboarding state (for development/testing purposes)
  static Future<bool> resetOnboardingForDev() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_onboardingKey);
    } catch (e) {
      debugPrint('[OnboardingStorage] Error resetting onboarding state: $e');
      return false;
    }
  }
}
