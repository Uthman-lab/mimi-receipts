import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // Secondary colors
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Category colors
  static const Color categoryFood = Color(0xFFF59E0B);
  static const Color categoryElectronics = Color(0xFF3B82F6);
  static const Color categoryClothing = Color(0xFFEC4899);
  static const Color categoryHousehold = Color(0xFF10B981);
  static const Color categoryPersonalCare = Color(0xFF8B5CF6);
  static const Color categoryOther = Color(0xFF6B7280);

  /// Get color for a category
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return categoryFood;
      case 'Electronics':
        return categoryElectronics;
      case 'Clothing':
        return categoryClothing;
      case 'Household':
        return categoryHousehold;
      case 'Personal Care':
        return categoryPersonalCare;
      default:
        return categoryOther;
    }
  }
}


