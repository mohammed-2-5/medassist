import 'package:flutter/material.dart';

/// Midnight palette for the splash screen.
class SplashPalette {
  SplashPalette._();

  // Deep midnight-blue background stops (darkest -> mid navy).
  static const Color bgDeep = Color(0xFF030A1F);
  static const Color bgMid = Color(0xFF071A3A);
  static const Color bgEdge = Color(0xFF0B2A5C);

  // Aurora / glow accents — all blue family.
  static const Color nebulaViolet = Color(0xFF1E3A8A); // deep royal blue
  static const Color nebulaIndigo = Color(0xFF2563EB); // electric blue
  static const Color nebulaPink = Color(0xFF1E88E5);   // ocean blue glow

  // Crisp highlights for rings, sparkles, dots.
  static const Color accentCyan = Color(0xFF38BDF8);     // sky blue
  static const Color accentLavender = Color(0xFF93C5FD); // ice blue

  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDeep, bgMid, bgEdge],
    stops: [0.0, 0.55, 1.0],
  );
}
