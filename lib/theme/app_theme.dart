import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F4C81);
  static const Color secondary = Color(0xFF1A7C5C);
  static const Color accent = Color(0xFFF5C842);
  static const Color red = Color(0xFFE05A4E);
  static const Color bgDark = Color(0xFF0D1117);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgTertiary = Color(0xFF1C2128);
  static const Color border = Color(0xFF30363D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF848D97);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        error: red,
        surface: bgCard,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w800,
            ),
            displayMedium: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            headlineLarge: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: GoogleFonts.syne(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: secondary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
