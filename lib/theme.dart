import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colours sampled from the ZANY Figma export.
class Z {
  static const teal = Color(0xFF239D9B); // app bars, drawer, "In stock"
  static const orange = Color(0xFFFF4802); // buttons, bottom nav, links
  static const orangeSoft = Color(0xFFFFC9B3); // calendar event days, badges
  static const grey = Color(0xFFEFEFEF); // section bands
  static const greyBtn = Color(0xFFAEAEAE); // inactive toggle button
  static const divider = Color(0xFFF4F4F4); // thick list separators
  static const beige = Color(0xFFF5EEE1); // training band on Home
  static const border = Color(0xFF9E9E9E); // input outlines
  static const text = Color(0xFF111111);
  static const sub = Color(0xFF5A5A5A);
  static const star = Color(0xFFFFC107);
}

/// Poppins throughout, as in the design.
TextStyle p(double size, {FontWeight w = FontWeight.w400, Color c = Z.text, double? h, TextDecoration? d}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c, height: h, decoration: d, decorationColor: c);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Z.teal, primary: Z.orange, secondary: Z.teal, surface: Colors.white),
    scaffoldBackgroundColor: Colors.white,
  );
  OutlineInputBorder b(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: c, width: w));
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Z.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 4,
      titleTextStyle: p(16, c: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: p(13, c: const Color(0xFF9A9A9A)),
      border: b(Z.border),
      enabledBorder: b(Z.border),
      focusedBorder: b(Z.teal, 1.6),
      errorBorder: b(Colors.red),
      focusedErrorBorder: b(Colors.red, 1.6),
      errorStyle: p(11, c: Colors.red),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: Z.text, width: 1.4),
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Z.orange : Colors.transparent),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Z.orange : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Z.orangeSoft : Z.grey),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Z.text,
      contentTextStyle: p(13, c: Colors.white),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFDADADA), thickness: 1, space: 1),
    radioTheme: const RadioThemeData(fillColor: WidgetStatePropertyAll(Z.orange)),
  );
}
