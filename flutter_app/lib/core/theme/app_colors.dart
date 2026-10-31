import 'package:flutter/material.dart';

class AppColors {
  // Emerald Theme Colors
  static const Color primaryEmerald = Color(0xFF032B1F);
  static const Color darkEmerald = Color(0xFF011912);
  static const Color deepEmerald = Color(0xFF073B2C);
  static const Color surfaceEmerald = Color(0xFF0D251D);
  static const Color cardEmerald = Color(0xFF12352A);
  static const Color borderEmerald = Color(0xFF1E4B3D);

  // Sacred Gold Accents
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF7E7A9);
  static const Color brightGold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFF997D20);

  // Neutral Colors (Dark Mode)
  static const Color darkBackground = Color(0xFF061511);
  static const Color darkSurface = Color(0xFF0C211B);
  static const Color darkCard = Color(0xFF122C23);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0B3AA);
  static const Color darkTextMuted = Color(0xFF6B8277);

  // Neutral Colors (Light Mode)
  static const Color lightBackground = Color(0xFFF6F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0B2019);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextMuted = Color(0xFF718096);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color liveRed = Color(0xFFFF2A2A);
  static const Color whatsApp = Color(0xFF25D366);
  static const Color youTube = Color(0xFFFF0000);

  // Gold Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF7E7A9), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Emerald Gradient
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF032B1F), Color(0xFF084B38)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gold Border Gradient
  static const LinearGradient borderGoldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0x33D4AF37), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
