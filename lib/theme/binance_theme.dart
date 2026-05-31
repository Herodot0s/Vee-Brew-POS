import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BinanceTheme {
  static const Color canvasDark = Color(0xFF0B0E11);
  static const Color surfaceCardDark = Color(0xFF1E2329);
  static const Color surfaceElevatedDark = Color(0xFF2B3139);
  static const Color primary = Color(0xFFFCD535);
  static const Color primaryActive = Color(0xFFF0B90B);
  static const Color body = Color(0xFFEAECEF);
  static const Color muted = Color(0xFF707A8A);
  static const Color tradingUp = Color(0xFF0ECB81);
  static const Color tradingDown = Color(0xFFF6465D);
  static const Color onPrimary = Color(0xFF181A20);
  static const Color onDark = Color(0xFFFFFFFF);

  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);

  static const double spaceXxs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  static TextStyle titleStyle({double size = 14, FontWeight weight = FontWeight.w600, Color color = body}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle numberStyle({double size = 14, FontWeight weight = FontWeight.w500, Color color = primary}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
