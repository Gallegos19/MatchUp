// lib/core/constants/app_colors.dart - UPDATED
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7ED8);
  static const Color primaryDark = Color(0xFF5A4FCF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF8DB4);
  static const Color secondaryDark = Color(0xFFE55A8A);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF1F3F4);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE17055);
  static const Color warning = Color(0xFFFDBE2E);
  static const Color info = Color(0xFF00B4D8);
  
  // Discovery Action Colors
  static const Color like = Color(0xFF00B894);
  static const Color dislike = Color(0xFFE17055);
  static const Color superLike = Color(0xFF00B4D8);
  static const Color rewind = Color(0xFFFDBE2E);
  static const Color boost = Color(0xFF6C5CE7);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C5CE7),
      Color(0xFF8B7ED8),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B9D),
      Color(0xFFFF8DB4),
    ],
  );

  static const LinearGradient likeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00B894),
      Color(0xFF26D0CE),
    ],
  );

  static const LinearGradient dislikeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE17055),
      Color(0xFFFF7675),
    ],
  );
  
  // Border Colors
  static const Color borderLight = Color(0xFFE1E8ED);
  static const Color borderMedium = Color(0xFFDDD6FE);
  static const Color borderDark = Color(0xFF6C5CE7);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x26000000);
}