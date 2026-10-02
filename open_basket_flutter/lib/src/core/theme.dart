import 'package:flutter/cupertino.dart';
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

  /// Hairlines between rows and around quiet controls.
  static const rule = Color(0xFFE0E0DC);
  static const ruleDark = Color(0xFF262623);

  /// 6.0:1 on paper.
  static const meta = Color(0xFF5F5F5A);

  /// 6.8:1 on ink.
  static const metaDark = Color(0xFF9A9A94);

  /// Destructive text ("Leave household"). 6.1:1 on paper; the same red on
  /// ink was 3.4:1, so dark mode gets its own (8.3:1).
  static const danger = Color(0xFFB3261E);
  static const dangerDark = Color(0xFFFF8A80);

  /// Frosted layers float over content: the add-item bar, the checkout bar,
  /// bottom sheets, lock-screen notifications. Anything you read a number off
  /// stays on a solid surface, so no ratio depends on what happens to be
  /// behind it.
  static const glassLight = Color(0xBDF7F7F5);
  static const glassDark = Color(0x940F0F0E);
  static const glassBorderLight = Color(0xCCFFFFFF);
  static const glassBorderDark = Color(0x24F7F7F5);
}

/// One member's tone: the fill of their avatar and the letter on it, or an
/// outline when the house has more people than greys.
class MemberTone {
  const MemberTone(this.fill, this.onFill, {this.outlined = false});

  final Color fill;
  final Color onFill;
  final bool outlined;
}

/// Per-member tones, from the design's person chip: greys from ink to chip,
/// then an outline. One per person, for life — a member's tone never changes,
/// because people learn it. Colour is kept for time (Signal); people are told
/// apart by their initial and their grey.
///
/// The index is the member's place in the household, longest-standing first,
/// former members included (`memberToneProvider`), so the first five people
/// never share a tone and nobody's tone moves when someone leaves.
abstract final class MemberTones {
  static const light = <MemberTone>[
    MemberTone(Color(0xFF4A4A46), OpenBasketColors.paper),
    MemberTone(OpenBasketColors.ink, OpenBasketColors.paper),
    MemberTone(Color(0xFF8E8E88), OpenBasketColors.paper),
    MemberTone(Color(0xFFC9C9C4), OpenBasketColors.ink),
    MemberTone(
      Colors.transparent,
      OpenBasketColors.ink,
      outlined: true,
    ),
  ];

  static const dark = <MemberTone>[
    MemberTone(Color(0xFF9A9A94), OpenBasketColors.ink),
    MemberTone(OpenBasketColors.paper, OpenBasketColors.ink),
    MemberTone(Color(0xFF5F5F5A), OpenBasketColors.paper),
    MemberTone(Color(0xFF3A3A36), OpenBasketColors.paper),
    MemberTone(
      Colors.transparent,
      OpenBasketColors.paper,
      outlined: true,
    ),
  ];

  static MemberTone of(int index, Brightness brightness) {
    final palette = brightness == Brightness.dark ? dark : light;
    return palette[index.abs() % palette.length];
  }
}

/// The type scale. Archivo carries words; JetBrains Mono carries numbers you
/// read under time pressure (so the digits do not jitter as they tick), money,
/// codes and the small uppercase labels.
abstract final class OpenBasketText {
  static TextStyle mono({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  static TextStyle countdown(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 60,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: color,
  );

  /// Screen titles: "Kaya household", "Check your email". 32/700, tight.
  static TextStyle display(Color color) => GoogleFonts.archivo(
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.12,
    color: color,
  );

  /// Card titles: "No basket open", "Ayşe owes Kaan". 17/700.
  static TextStyle title(Color color, {double fontSize = 17}) =>
      GoogleFonts.archivo(
        fontSize: fontSize,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * fontSize,
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

  /// "IN THE HOUSE", "RECENT RUNS": mono, 11/500, tracked 0.12em. The
  /// string is uppercased by the widget, not the copy.
  static TextStyle label(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32,
    color: color,
  );

  /// Tabular so a column of prices lines up and does not reflow as it changes.
  static TextStyle money(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

/// Every control clears 44px. A 32px glyph sits in a 44px hit box.
const double kMinTapTarget = 44;

/// The big full-width button: 58px tall, 17px corners.
const double kPrimaryButtonHeight = 58;
const double kButtonRadius = 17;

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
      // Tonal: the quiet panel a code or a total sits on. Named here rather
      // than hardcoded in a screen, so a widget that asks Material for a
      // raised surface gets the palette's answer instead of Material's.
      surfaceContainerHighest: isDark
          ? const Color(0xFF1C1C1A)
          : OpenBasketColors.tonal,
      error: isDark ? OpenBasketColors.dangerDark : OpenBasketColors.danger,
      onError: OpenBasketColors.paper,
    ),
    textTheme: TextTheme(
      displayLarge: OpenBasketText.display(onGround),
      titleMedium: OpenBasketText.item(onGround),
      bodyMedium: OpenBasketText.body(onGround),
      bodySmall: OpenBasketText.meta(muted),
      labelSmall: OpenBasketText.label(muted),
    ),
    // Material falls back to colorScheme.primary for the foreground of
    // anything it has no theme for -- outlined and text buttons, progress
    // indicators, text selection. Primary here is Signal, so without these
    // every one of them came out lime on paper: about 1.6:1, and against the
    // one rule the palette has, which is that Signal is a fill and never a
    // text colour. Found on screen 04, where "I have a code" was unreadable.
    dividerColor: isDark ? OpenBasketColors.ruleDark : OpenBasketColors.rule,
    appBarTheme: AppBarTheme(
      backgroundColor: ground,
      foregroundColor: onGround,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: onGround),
    // The same fallback, one level down. Cupertino widgets take their tint
    // from Material's primary when nothing overrides it, so the iOS action
    // sheet for marking an item came out with lime "Got it" on frosted white.
    // Ink is what iOS itself would use for a neutral sheet.
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: onGround,
      primaryContrastingColor: ground,
    ),
    // The design is drawn iPhone-first on both platforms: no ink ripples,
    // and pages slide in from the side rather than fading up.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const CupertinoPageTransitionsBuilder(),
      },
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onGround,
        minimumSize: const Size.fromHeight(kPrimaryButtonHeight),
        side: BorderSide(color: onGround, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
        textStyle: OpenBasketText.title(onGround),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: muted,
        minimumSize: const Size.fromHeight(kMinTapTarget),
        textStyle: OpenBasketText.body(muted),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: OpenBasketColors.signal,
        foregroundColor: OpenBasketColors.ink,
        disabledBackgroundColor: isDark
            ? const Color(0xFF1C1C1A)
            : OpenBasketColors.tonal,
        disabledForegroundColor: const Color(0xFF8E8E88),
        minimumSize: const Size.fromHeight(kPrimaryButtonHeight),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
        textStyle: OpenBasketText.title(OpenBasketColors.ink),
      ),
    ),
    // Fields sit on frosted paper with an ink edge (screens 01, 07).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? OpenBasketColors.glassDark
          : OpenBasketColors.glassLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
      hintStyle: OpenBasketText.body(muted).copyWith(fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide(color: onGround, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide(color: onGround, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide(color: onGround, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide(
          color: isDark ? OpenBasketColors.ruleDark : OpenBasketColors.rule,
          width: 1.5,
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: onGround,
      selectionHandleColor: onGround,
      selectionColor: OpenBasketColors.signal.withValues(alpha: 0.5),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? OpenBasketColors.signal
            : OpenBasketColors.paper,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? (isDark ? const Color(0xFF2C2C29) : OpenBasketColors.ink)
            : (isDark ? const Color(0xFF3A3A36) : const Color(0xFFDCDCD8)),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1C1C1A) : OpenBasketColors.ink,
      contentTextStyle: OpenBasketText.body(OpenBasketColors.paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
