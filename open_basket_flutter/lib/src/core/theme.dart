import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The palette from the published screen set, with the contrast ratios it
/// measured. Do not add a colour here without measuring it too.
///
/// [signal] is a fill only. It is 1.08:1 on [paper], so it must never be text
/// or a hairline icon on a light surface. It has three jobs and no more: the
/// primary button, the running countdown, and the timer bar.
abstract final class OpenBasketColors {
  static const paper = Color(0xFFF7F7F5);
  static const tonal = Color(0xFFEFEFEC);
  static const chip = Color(0xFFE6E6E3);
  static const signal = Color(0xFFE2FB33);
  static const ink = Color(0xFF0F0F0E);

  /// 6.0:1 on paper.
  static const meta = Color(0xFF5F5F5A);

  /// 6.8:1 on ink.
  static const metaDark = Color(0xFF9A9A94);

  /// Frosted layers float over content: the add-item bar, the checkout bar,
  /// bottom sheets, lock-screen notifications. Anything you read a number off
  /// stays on a solid surface, so no ratio depends on what happens to be
  /// behind it.
  static const glassLight = Color(0xBDF7F7F5);
  static const glassDark = Color(0x940F0F0E);
  static const glassBorderLight = Color(0xCCFFFFFF);
  static const glassBorderDark = Color(0x24F7F7F5);
}

/// Per-member tones. One per person, for life — a member's colour never
/// changes, because people learn it.
abstract final class MemberTones {
  static const light = <Color>[
    Color(0xFF3A5A40),
    Color(0xFF6B4E71),
    Color(0xFF9C6644),
    Color(0xFF335C81),
    Color(0xFF7D4F50),
  ];

  static const dark = <Color>[
    Color(0xFF8FBF9F),
    Color(0xFFC3A1C9),
    Color(0xFFDBA97C),
    Color(0xFF8FB8DE),
    Color(0xFFD49FA0),
  ];

  /// Stable across sessions and devices: the same member id always lands on
  /// the same tone, so two phones never disagree about who is green.
  static Color forMember(int memberId, Brightness brightness) {
    final palette = brightness == Brightness.dark ? dark : light;
    return palette[memberId.abs() % palette.length];
  }
}

/// The type scale. Archivo carries everything except numbers you read under
/// time pressure; those are mono so the digits do not jitter as they tick.
abstract final class OpenBasketText {
  static TextStyle countdown(Color color) => GoogleFonts.robotoMono(
    fontSize: 60,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: color,
  );

  static TextStyle display(Color color) => GoogleFonts.archivo(
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle item(Color color) => GoogleFonts.archivo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle body(Color color) =>
      GoogleFonts.archivo(fontSize: 15, height: 1.4, color: color);

  static TextStyle meta(Color color) =>
      GoogleFonts.archivo(fontSize: 13, height: 1.35, color: color);

  static TextStyle label(Color color) => GoogleFonts.archivo(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: color,
  );

  /// Tabular so a column of prices lines up and does not reflow as it changes.
  static TextStyle money(Color color) => GoogleFonts.robotoMono(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

/// Every control clears 44px. A 32px glyph sits in a 44px hit box.
const double kMinTapTarget = 44;

ThemeData buildOpenBasketTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final ground = isDark ? OpenBasketColors.ink : OpenBasketColors.paper;
  final onGround = isDark ? OpenBasketColors.paper : OpenBasketColors.ink;
  final muted = isDark ? OpenBasketColors.metaDark : OpenBasketColors.meta;

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: ground,
    colorScheme: ColorScheme(
      brightness: brightness,
      // Ink on signal is 16.6:1 either way, which is why the primary button
      // keeps its colours in both themes.
      primary: OpenBasketColors.signal,
      onPrimary: OpenBasketColors.ink,
      secondary: onGround,
      onSecondary: ground,
      surface: ground,
      onSurface: onGround,
      error: const Color(0xFFB3261E),
      onError: OpenBasketColors.paper,
    ),
    textTheme: TextTheme(
      displayLarge: OpenBasketText.display(onGround),
      titleMedium: OpenBasketText.item(onGround),
      bodyMedium: OpenBasketText.body(onGround),
      bodySmall: OpenBasketText.meta(muted),
      labelSmall: OpenBasketText.label(muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: OpenBasketColors.signal,
        foregroundColor: OpenBasketColors.ink,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: OpenBasketText.item(OpenBasketColors.ink),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1C1C1A) : OpenBasketColors.tonal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: OpenBasketText.body(muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
