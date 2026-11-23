import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors inspired by News18 & NewsTamil.in
  static const Color primaryRed = Color(0xFFEC2027); // News Urgency Red
  static const Color primaryNavy = Color(0xFF0B3B60); // Authoritative Navy
  static const Color accentRed = Color(0xFFB91C1C);
  static const Color whatsAppGreen = Color(0xFF25D366); // Viral WhatsApp Share
  
  // Light Theme Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme Neutrals (AMOLED Battery Saver)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkCard = Color(0xFF161E2E);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  // Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: primaryNavy,
        surface: lightCard,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.notoSansTamilTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineMedium: GoogleFonts.notoSansTamil(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          height: 1.45,
        ),
        headlineSmall: GoogleFonts.notoSansTamil(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          height: 1.42,
        ),
        bodyLarge: GoogleFonts.notoSansTamil(
          fontSize: 15,
          color: lightTextPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.notoSansTamil(
          fontSize: 13,
          color: lightTextSecondary,
          height: 1.45,
        ),
        labelSmall: GoogleFonts.notoSansTamil(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: lightTextPrimary,
        elevation: 0.5,
        centerTitle: false,
      ),
      dividerColor: lightBorder,
    );
  }

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: primaryNavy,
        surface: darkCard,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.notoSansTamilTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        headlineMedium: GoogleFonts.notoSansTamil(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: 1.45,
        ),
        headlineSmall: GoogleFonts.notoSansTamil(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: 1.42,
        ),
        bodyLarge: GoogleFonts.notoSansTamil(
          fontSize: 15,
          color: darkTextPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.notoSansTamil(
          fontSize: 13,
          color: darkTextSecondary,
          height: 1.45,
        ),
        labelSmall: GoogleFonts.notoSansTamil(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: darkBorder,
    );
  }
}
