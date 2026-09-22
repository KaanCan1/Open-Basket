import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_basket_flutter/src/core/theme.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  // buildOpenBasketTheme reaches google_fonts, which touches the services
  // binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('palette contrast', () {
    // The screen set published these ratios. If a token moves, this fails
    // before anyone ships a button nobody can read — the first version of the
    // design shipped a primary label at 3.6:1 and it took a measurement to
    // notice.
    test('body text clears AA on both grounds', () {
      expect(
        _contrast(OpenBasketColors.ink, OpenBasketColors.paper),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(OpenBasketColors.paper, OpenBasketColors.ink),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('meta text clears AA on its own ground', () {
      expect(
        _contrast(OpenBasketColors.meta, OpenBasketColors.paper),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(OpenBasketColors.metaDark, OpenBasketColors.ink),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('the primary button label clears AA', () {
      expect(
        _contrast(OpenBasketColors.ink, OpenBasketColors.signal),
        greaterThanOrEqualTo(4.5),
      );
    });

    test(
      'signal is unreadable as text on paper, which is why it is fill only',
      () {
        expect(
          _contrast(OpenBasketColors.signal, OpenBasketColors.paper),
          lessThan(1.2),
        );
      },
    );
  });

  group('member tones', () {
    test('a member keeps the same tone every time', () {
      for (var id = 0; id < 50; id++) {
        expect(
          MemberTones.forMember(id, Brightness.light),
          MemberTones.forMember(id, Brightness.light),
        );
      }
    });

    test('neighbouring members do not collide', () {
      final tones = [
        for (var id = 0; id < MemberTones.light.length; id++)
          MemberTones.forMember(id, Brightness.light),
      ];
      expect(tones.toSet(), hasLength(MemberTones.light.length));
    });
  });

  group('theme', () {
    test('keeps the ink-on-signal button in both brightnesses', () {
      for (final brightness in Brightness.values) {
        final theme = buildOpenBasketTheme(brightness);
        expect(theme.colorScheme.primary, OpenBasketColors.signal);
        expect(theme.colorScheme.onPrimary, OpenBasketColors.ink);
      }
    });

    test('every control clears the 44px tap target', () {
      final theme = buildOpenBasketTheme(Brightness.light);
      final size = theme.filledButtonTheme.style!.minimumSize!.resolve({});
      expect(size!.height, greaterThanOrEqualTo(kMinTapTarget));
    });
  });

  group('resolved control colours', () {
    // The palette test above checks tokens. This checks what Material
    // actually paints, which is a different thing: Signal is colorScheme
    // .primary, and Material falls back to primary for the foreground of
    // anything it has no theme for. Screen 04 shipped an outlined button
    // reading lime on paper at about 1.6:1 -- every token in it was correct.
    for (final brightness in Brightness.values) {
      final theme = buildOpenBasketTheme(brightness);
      final ground = theme.scaffoldBackgroundColor;
      final name = brightness.name;

      test('the outlined button is readable on $name paper', () {
        final foreground = theme.outlinedButtonTheme.style!.foregroundColor!
            .resolve({})!;
        expect(_contrast(foreground, ground), greaterThanOrEqualTo(4.5));
      });

      test('the text button is readable on $name paper', () {
        final foreground = theme.textButtonTheme.style!.foregroundColor!
            .resolve({})!;
        expect(_contrast(foreground, ground), greaterThanOrEqualTo(4.5));
      });

      test('the filled button is readable in $name', () {
        final style = theme.filledButtonTheme.style!;
        expect(
          _contrast(
            style.foregroundColor!.resolve({})!,
            style.backgroundColor!.resolve({})!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('the iOS action sheet is readable in $name', () {
        // What CupertinoActionSheet actually tints its actions with.
        final tint = MaterialBasedCupertinoThemeData(
          materialTheme: theme,
        ).primaryColor;
        expect(tint, isNot(OpenBasketColors.signal));
        expect(_contrast(tint, ground), greaterThanOrEqualTo(4.5));
      });

      test('Signal is never a foreground in $name', () {
        // The one rule the palette has.
        for (final style in [
          theme.outlinedButtonTheme.style!,
          theme.textButtonTheme.style!,
        ]) {
          expect(
            style.foregroundColor!.resolve({}),
            isNot(OpenBasketColors.signal),
          );
        }
      });
    }
  });
}
