import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../features/household/household_controller.dart';

/// The building blocks of screen set v3 ("frosted layers"): the ambient wash
/// every screen carries, the glass that floats over content, the solid cards
/// that hold numbers, and the person chip. Screens compose these instead of
/// drawing their own boxes, so a radius or a blur changes in one place.

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Colours a screen reaches for that are not in the Material scheme.
class Ob {
  Ob._(this.dark);

  factory Ob.of(BuildContext context) => Ob._(_isDark(context));

  final bool dark;

  Color get ground => dark ? OpenBasketColors.ink : OpenBasketColors.paper;
  Color get onGround => dark ? OpenBasketColors.paper : OpenBasketColors.ink;
  Color get meta => dark ? OpenBasketColors.metaDark : OpenBasketColors.meta;

  /// The quiet panel a total or a fact sits on.
  Color get tonal => dark ? const Color(0xFF1C1C1A) : OpenBasketColors.tonal;

  /// One step up from tonal: the amount pill, a pressed chip.
  Color get chip => dark ? const Color(0xFF2C2C29) : OpenBasketColors.chip;
  Color get rule => dark ? OpenBasketColors.ruleDark : OpenBasketColors.rule;

  /// Unticked box edges and spent bars.
  Color get faint => dark ? const Color(0xFF3A3A36) : const Color(0xFFC9C9C4);

  /// The countdown card: ink in light, a lifted near-black in dark.
  Color get inkCard => dark ? const Color(0xFF1A1A17) : OpenBasketColors.ink;

  Color get glass =>
      dark ? OpenBasketColors.glassDark : OpenBasketColors.glassLight;
  Color get glassBorder => dark
      ? OpenBasketColors.glassBorderDark
      : OpenBasketColors.glassBorderLight;
}

/// The faint wash behind every screen: Signal at the top right, ink (or a
/// trace of Signal in the dark) at the bottom left, so the glass has
/// something to pick up.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    required this.child,
    this.strong = false,
    super.key,
  });

  final Widget child;

  /// Behind a sheet the wash is stronger, as the design draws it.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return CustomPaint(
      painter: _AmbientPainter(dark: dark, strong: strong),
      child: child,
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({required this.dark, required this.strong});

  final bool dark;
  final bool strong;

  void _ellipse(
    Canvas canvas,
    Size size, {
    required Offset centre,
    required double rx,
    required double ry,
    required Color color,
    required double stop,
  }) {
    canvas.save();
    canvas.translate(size.width * centre.dx, size.height * centre.dy);
    canvas.scale(size.width * rx, size.height * ry);
    canvas.drawCircle(
      Offset.zero,
      1,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: [0, stop],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1)),
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = dark ? OpenBasketColors.ink : OpenBasketColors.paper,
    );
    if (dark) {
      _ellipse(
        canvas,
        size,
        centre: const Offset(0.80, -0.06),
        rx: 0.9,
        ry: 0.55,
        color: OpenBasketColors.signal.withValues(alpha: strong ? 0.3 : 0.18),
        stop: 0.6,
      );
      _ellipse(
        canvas,
        size,
        centre: const Offset(0.06, 1.06),
        rx: 0.8,
        ry: 0.55,
        color: OpenBasketColors.signal.withValues(alpha: 0.06),
        stop: 0.62,
      );
    } else {
      _ellipse(
        canvas,
        size,
        centre: const Offset(0.82, -0.08),
        rx: 0.85,
        ry: 0.55,
        color: OpenBasketColors.signal.withValues(alpha: strong ? 0.45 : 0.24),
        stop: 0.62,
      );
      _ellipse(
        canvas,
        size,
        centre: const Offset(0.04, 1.04),
        rx: 0.7,
        ry: 0.5,
        color: OpenBasketColors.ink.withValues(alpha: strong ? 0.12 : 0.06),
        stop: 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.dark != dark || old.strong != strong;
}

/// A screen of the set: the ambient wash, safe area, an optional back row,
/// and an optional frosted bar pinned to the bottom that content scrolls
/// under.
class ObScaffold extends StatelessWidget {
  const ObScaffold({
    required this.body,
    this.back,
    this.backLabel,
    this.onBack,
    this.bottomBar,
    this.resizeToAvoidBottomInset = true,
    this.safeBottom = true,
    super.key,
  });

  /// False when the body ends in a panel that pads the home indicator
  /// itself (the checkout totals), so it reaches the bottom edge.
  final bool safeBottom;

  final Widget body;

  /// Shows the back row. [backLabel] is where it goes ("Stores", "Home").
  final bool? back;
  final String? backLabel;
  final VoidCallback? onBack;

  /// Pinned under the content on light glass (the add bar, checkout bar).
  final Widget? bottomBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final showBack = back ?? false;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AmbientBackground(
        child: SafeArea(
          bottom: bottomBar == null && safeBottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBack) BackRow(label: backLabel, onBack: onBack),
              Expanded(child: body),
              if (bottomBar != null) GlassBar(child: bottomBar!),
            ],
          ),
        ),
      ),
    );
  }
}

/// "← Stores": a 44px arrow and where it goes back to.
class BackRow extends StatelessWidget {
  const BackRow({this.label, this.onBack, super.key});

  final String? label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    void pop() {
      if (onBack != null) {
        onBack!();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 2, 22, 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: pop,
            child: Semantics(
              button: true,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: kMinTapTarget,
                    height: kMinTapTarget,
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: 22,
                      color: ob.onGround,
                    ),
                  ),
                  if (label != null)
                    Text(
                      label!,
                      style: OpenBasketText.body(
                        ob.onGround,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted glass: blur 26, the palette's glass tint, a hairline of light.
/// For things that float over content — never for a number you read.
class Glass extends StatelessWidget {
  const Glass({
    required this.child,
    this.radius = 22,
    this.padding,
    this.shadow = true,
    this.borderRadius,
    this.tint,
    super.key,
  });

  final Widget child;
  final double radius;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool shadow;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final shape = borderRadius ?? BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: ob.dark ? 0.4 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? ob.glass,
              borderRadius: shape,
              border: Border.all(color: ob.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The frosted strip pinned to the bottom of a screen: the add bar, the
/// checkout bar, a primary action. Reaches under the home indicator.
class GlassBar extends StatelessWidget {
  const GlassBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            // The Scaffold has already lifted the body above the keyboard and
            // zeroed its insets, so the view says whether it is up.
            12 + (View.of(context).viewInsets.bottom > 0 ? 0 : bottom),
          ),
          decoration: BoxDecoration(
            color: ob.glass,
            border: Border(top: BorderSide(color: ob.glassBorder)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A solid quiet card: tonal fill, 16px corners. Holds numbers.
class TonalCard extends StatelessWidget {
  const TonalCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Ob.of(context).tonal,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

/// A raised paper card with a soft shadow: settlement lines, "You owe Kaan".
class RaisedCard extends StatelessWidget {
  const RaisedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ob.dark ? const Color(0xFF1A1A17) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(radius),
        border: ob.dark
            ? Border.all(color: OpenBasketColors.paper.withValues(alpha: 0.1))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: ob.dark ? 0.3 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// An ink card in both themes — the states the set calls out (create a
/// household, the household code, an error).
class InkCard extends StatelessWidget {
  const InkCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ob.inkCard,
        borderRadius: BorderRadius.circular(radius),
        border: ob.dark
            ? Border.all(color: OpenBasketColors.paper.withValues(alpha: 0.1))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: ob.dark ? 0.4 : 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// "That code didn't match": an ink card with a Signal ring, a bold line
/// and the reason underneath. Reassure first, blame never.
class InkNotice extends StatelessWidget {
  const InkNotice({
    required this.title,
    this.body,
    this.icon = CupertinoIcons.exclamationmark_circle,
    this.action,
    this.iconOnSignal = false,
    super.key,
  });

  final String title;
  final String? body;
  final IconData icon;
  final Widget? action;

  /// A ticked Signal square instead of a ring ("Back online").
  final bool iconOnSignal;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: ob.dark ? const Color(0xFF1C1C1A) : OpenBasketColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: ob.dark
            ? Border.all(color: OpenBasketColors.paper.withValues(alpha: 0.1))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconOnSignal)
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: OpenBasketColors.signal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 15, color: OpenBasketColors.ink),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 18, color: OpenBasketColors.signal),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: OpenBasketText.body(
                    OpenBasketColors.paper,
                  ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                if (body != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    body!,
                    style: OpenBasketText.meta(
                      OpenBasketColors.metaDark,
                    ).copyWith(height: 1.5),
                  ),
                ],
                if (action != null) ...[const SizedBox(height: 12), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A one-line note with a small icon: "It shows up in history as
/// cancelled", "Changing this doesn't convert anything".
class IconNote extends StatelessWidget {
  const IconNote({
    required this.text,
    this.icon = CupertinoIcons.info_circle,
    this.boxed = false,
    super.key,
  });

  final String text;
  final IconData icon;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: ob.onGround),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: OpenBasketText.meta(ob.meta).copyWith(height: 1.5),
          ),
        ),
      ],
    );
    if (!boxed) return row;
    return TonalCard(padding: const EdgeInsets.all(14), child: row);
  }
}

/// "IN THE HOUSE   Invite": a mono label with an optional underlined link.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    this.action,
    this.onAction,
    this.trailing,
    super.key,
  });

  final String text;
  final String? action;
  final VoidCallback? onAction;

  /// A quiet note on the right instead of a link ("Ayşe added 12s ago").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: OpenBasketText.label(ob.meta),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
          if (action != null) LinkText(action!, onTap: onAction),
        ],
      ),
    );
  }
}

/// Bold, underlined, 44px tall: the set's text link.
class LinkText extends StatelessWidget {
  const LinkText(this.text, {this.onTap, this.fontSize = 13, super.key});

  final String text;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: Align(
          widthFactor: 1,
          child: Text(
            text,
            style: OpenBasketText.body(ob.onGround).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: ob.onGround,
            ),
          ),
        ),
      ),
    );
  }
}

/// A screen's title and the line under it.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {this.subtitle, this.fontSize = 32, super.key});

  final String title;
  final String? subtitle;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OpenBasketText.display(ob.onGround).copyWith(
            fontSize: fontSize,
            height: 1.06,
            letterSpacing: -0.035 * fontSize,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: OpenBasketText.body(ob.meta).copyWith(fontSize: 15.5),
          ),
        ],
      ],
    );
  }
}

/// The mark on its own, in the ground's ink.
class BrandMark extends StatelessWidget {
  const BrandMark({this.height = 30, this.opacity = 1, super.key});

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity,
    child: Image.asset(
      _isDark(context)
          ? 'assets/brand/mark_paper.png'
          : 'assets/brand/mark_ink.png',
      height: height,
      excludeFromSemantics: true,
    ),
  );
}

/// The mark and "open basket", top left of the home screen.
class Wordmark extends StatelessWidget {
  const Wordmark({this.height = 27, super.key});

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    _isDark(context)
        ? 'assets/brand/wordmark_paper.png'
        : 'assets/brand/wordmark_ink.png',
    height: height,
    semanticLabel: 'Open Basket',
  );
}

/// A 44px frosted square holding one icon (the settings gear).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final button = GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 14,
        child: SizedBox(
          width: kMinTapTarget,
          height: kMinTapTarget,
          child: Icon(icon, size: 20, color: ob.onGround),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// Every member's place in the household, longest-standing first and former
/// members included, which is what their tone hangs off.
final memberToneProvider = Provider<Map<int, int>>((final ref) {
  final members = ref.watch(membersProvider).value ?? const [];
  return {
    for (var i = 0; i < members.length; i++)
      if (members[i].id != null) members[i].id!: i,
  };
});

/// The person square: an initial on the member's tone. 34px in rows, 26px
/// in chips.
class PersonAvatar extends ConsumerWidget {
  const PersonAvatar({
    required this.memberId,
    required this.name,
    this.size = 34,
    this.shopper = false,
    this.faded = false,
    this.onInk = false,
    super.key,
  });

  /// On the ink countdown card: the dark tones, whatever the theme.
  final bool onInk;

  final int memberId;
  final String name;
  final double size;

  /// The shopper's square is Signal wherever it marks whose run it is.
  final bool shopper;

  /// Greyed for a queued item that has not reached the server yet.
  final bool faded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = onInk ? Brightness.dark : Theme.of(context).brightness;
    final index = ref.watch(memberToneProvider)[memberId] ?? memberId;
    final tone = shopper
        ? const MemberTone(OpenBasketColors.signal, OpenBasketColors.ink)
        : MemberTones.of(index, brightness);
    final ob = Ob.of(context);
    final fill = faded ? ob.chip : tone.fill;
    final onFill = faded ? ob.meta : tone.onFill;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: tone.outlined && !faded
            ? Border.all(color: tone.onFill, width: 1.5)
            : null,
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style:
            OpenBasketText.body(
              onFill,
            ).copyWith(
              fontSize: size * 0.41,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
      ),
    );
  }
}

/// "A  Ayşe": the person chip.
class PersonChip extends StatelessWidget {
  const PersonChip({
    required this.memberId,
    required this.name,
    this.onTap,
    super.key,
  });

  final int memberId;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 13, 6),
        decoration: BoxDecoration(
          color: ob.dark
              ? OpenBasketColors.paper.withValues(alpha: 0.08)
              : OpenBasketColors.tonal,
          borderRadius: BorderRadius.circular(12),
          border: ob.dark
              ? Border.all(
                  color: OpenBasketColors.paper.withValues(alpha: 0.12),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PersonAvatar(memberId: memberId, name: name, size: 26),
            const SizedBox(width: 8),
            Text(
              name,
              style: OpenBasketText.body(
                ob.onGround,
              ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small overlapping squares: who is looking, who was told.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.people,
    this.size = 28,
    this.max = 3,
    this.onDark = false,
    super.key,
  });

  /// (memberId, name)
  final List<(int, String)> people;
  final double size;
  final int max;

  /// On the countdown card: the extra count sits on ink.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(max).toList();
    final more = people.length - shown.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (id, name) in shown) ...[
          PersonAvatar(memberId: id, name: name, size: size, onInk: onDark),
          const SizedBox(width: 4),
        ],
        if (more > 0)
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onDark ? const Color(0xFF2C2C29) : Ob.of(context).chip,
              borderRadius: BorderRadius.circular(size * 0.32),
            ),
            child: Text(
              '+$more',
              style: OpenBasketText.mono(
                color: onDark ? OpenBasketColors.metaDark : Ob.of(context).meta,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

enum TickState { empty, got, unavailable }

/// The shopper's box: empty, an ink tick, or an outlined cross. 32px inside a
/// 44px hit box. Ink, not Signal — got items are settled business.
class TickBox extends StatelessWidget {
  const TickBox({required this.state, this.onTap, super.key});

  final TickState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final Widget box = switch (state) {
      TickState.empty => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: ob.faint, width: 1.5),
        ),
      ),
      TickState.got => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ob.onGround,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          CupertinoIcons.checkmark_alt,
          size: 19,
          color: ob.ground,
        ),
      ),
      TickState.unavailable => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: ob.onGround, width: 1.5),
        ),
        child: Icon(CupertinoIcons.xmark, size: 15, color: ob.onGround),
      ),
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: kMinTapTarget,
        height: kMinTapTarget,
        child: Align(alignment: Alignment.centerRight, child: box),
      ),
    );
  }
}

/// "YOU", "SETTLED", "FROZEN": a small mono tag.
class Tag extends StatelessWidget {
  const Tag(
    this.text, {
    this.icon,
    this.outlined = false,
    this.inverse = false,
    super.key,
  });

  final String text;
  final IconData? icon;

  /// "CANCELLED": an outline instead of a fill.
  final bool outlined;

  /// Paper on the ink card (FROZEN on the grey card stays ink).
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final fill = inverse ? OpenBasketColors.paper : ob.onGround;
    final onFill = inverse ? OpenBasketColors.ink : ob.ground;
    final fg = outlined ? ob.meta : onFill;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? null : fill,
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: ob.meta, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text.toUpperCase(),
            style: OpenBasketText.mono(
              color: fg,
              fontSize: 10.5,
              letterSpacing: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width ink button (Cancel it, See the whole run, Rotate).
class InkButton extends StatelessWidget {
  const InkButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = kPrimaryButtonHeight,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: ob.onGround,
        foregroundColor: ob.ground,
        minimumSize: Size.fromHeight(height),
        textStyle: OpenBasketText.title(ob.ground),
      ),
      onPressed: onPressed,
      child: _Label(label: label, icon: icon),
    );
  }
}

/// The Signal button with an optional leading icon and its glow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.glow = false,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// The home screen's "Open a basket" carries a Signal shadow.
  final bool glow;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : _Label(label: label, icon: icon),
    );
    if (!glow || onPressed == null) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kButtonRadius),
        boxShadow: [
          BoxShadow(
            color: OpenBasketColors.signal.withValues(alpha: 0.42),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: button,
    );
  }
}

/// A full-width outlined button.
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.quiet = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// A faint edge instead of ink ("Keep shopping", "Join" before a code).
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return OutlinedButton(
      style: quiet
          ? OutlinedButton.styleFrom(
              side: BorderSide(color: ob.faint, width: 1.5),
              backgroundColor: ob.glass,
            )
          : null,
      onPressed: onPressed,
      child: _Label(label: label, icon: icon),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 9),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/// A key and a value on one line, in a tonal block ("Time left  5:12").
class FactRow extends StatelessWidget {
  const FactRow({
    required this.label,
    required this.value,
    this.valueWidget,
    super.key,
  });

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: OpenBasketText.meta(ob.meta).copyWith(
              fontSize: 14,
            ),
          ),
        ),
        valueWidget ??
            Text(
              value,
              style: OpenBasketText.mono(
                color: ob.onGround,
                fontSize: 15,
              ),
            ),
      ],
    );
  }
}

/// A rounded bottom sheet on frosted paper over a dimmed, blurred screen —
/// screens 06, 13, 18.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: OpenBasketColors.ink.withValues(alpha: 0.46),
    elevation: 0,
    builder: (sheetContext) {
      final ob = Ob.of(sheetContext);
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
          child: Container(
            decoration: BoxDecoration(
              color: ob.dark
                  ? const Color(0xF21A1A17)
                  : OpenBasketColors.paper.withValues(alpha: 0.97),
              border: Border(top: BorderSide(color: ob.glassBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: ob.faint,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Flexible(child: builder(sheetContext)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Shaped skeleton rows, never a spinner.
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.rows = 3, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final strong = ob.dark ? const Color(0xFF2C2C29) : const Color(0xFFDCDCD8);
    final soft = ob.dark ? const Color(0xFF242421) : const Color(0xFFE4E4E0);
    const widths = [0.62, 0.48, 0.7, 0.55];
    return TonalCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: strong,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 11,
                          width: c.maxWidth * widths[i % widths.length],
                          decoration: BoxDecoration(
                            color: strong,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 9,
                          width: c.maxWidth * 0.4,
                          decoration: BoxDecoration(
                            color: soft,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A screen still loading: the wash and shaped skeletons.
class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({this.back = false, super.key});

  final bool back;

  @override
  Widget build(BuildContext context) => ObScaffold(
    back: back,
    body: const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Align(alignment: Alignment.topCenter, child: SkeletonList()),
    ),
  );
}

/// The mark carries an empty state — no illustration.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return TonalCard(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(height: 30, opacity: 0.3),
          const SizedBox(height: 16),
          Text(title, style: OpenBasketText.title(ob.onGround, fontSize: 19)),
          const SizedBox(height: 8),
          Text(
            body,
            style: OpenBasketText.body(ob.meta).copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Can't reach something: reassure, then a Signal retry.
class ErrorCard extends StatelessWidget {
  const ErrorCard({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => InkNotice(
    title: title,
    body: body,
    action: SizedBox(
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: OpenBasketText.body(
            OpenBasketColors.ink,
          ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        onPressed: onRetry,
        child: Text(retryLabel),
      ),
    ),
  );
}

/// Six boxes, one character each — the sign-in code (02) and the household
/// code (04, 17, 27, 28). Mono 26, frosted, the current box outlined.
class CharBoxes extends StatelessWidget {
  const CharBoxes({
    required this.value,
    this.length = 6,
    this.focused = true,
    this.error = false,
    this.struck = false,
    this.onInk = false,
    super.key,
  });

  final String value;
  final int length;
  final bool focused;

  /// Every box outlined in ink, as after a wrong code (03, 27).
  final bool error;

  /// Greyed and struck through: a code that stopped working (28).
  final bool struck;

  /// On the ink household-code card (17).
  final bool onInk;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Row(
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _box(context, ob, i)),
        ],
      ],
    );
  }

  Widget _box(BuildContext context, Ob ob, int i) {
    final char = i < value.length ? value[i] : '';
    final current = focused && !error && !struck && i == value.length;
    final Color fill;
    final Border? border;
    final Color fg;
    if (onInk) {
      fill = OpenBasketColors.paper.withValues(alpha: 0.08);
      border = Border.all(
        color: OpenBasketColors.paper.withValues(alpha: 0.14),
      );
      fg = OpenBasketColors.paper;
    } else if (struck) {
      fill = ob.tonal;
      border = Border.all(color: ob.rule, width: 1.5);
      fg = ob.meta.withValues(alpha: 0.6);
    } else if (error || current) {
      fill = ob.glass;
      border = Border.all(color: ob.onGround, width: 1.5);
      fg = ob.onGround;
    } else {
      fill = ob.glass;
      border = Border.all(color: ob.glassBorder);
      fg = ob.onGround;
    }
    return AspectRatio(
      aspectRatio: onInk ? 0.9 : 0.82,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(onInk ? 11 : 15),
          border: border,
          boxShadow: onInk || struck
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: ob.dark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: current
            ? Container(width: 2, height: 26, color: ob.onGround)
            : Text(
                char,
                style:
                    OpenBasketText.mono(
                      color: fg,
                      fontSize: onInk ? 22 : 26,
                    ).copyWith(
                      decoration: struck ? TextDecoration.lineThrough : null,
                      decorationColor: fg,
                    ),
              ),
      ),
    );
  }
}

/// A row in a settings-style list: label, optional detail, value, chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    required this.title,
    this.subtitle,
    this.value,
    this.valueMono = false,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.chevron = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final bool valueMono;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    final titleColor = destructive
        ? Theme.of(context).colorScheme.error
        : ob.onGround;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ob.rule)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: OpenBasketText.body(titleColor).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: OpenBasketText.meta(ob.meta).copyWith(
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              // Not flexible: a flexible value takes half the row whatever
              // its length, and the chevrons stop lining up.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  value!,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: valueMono
                      ? OpenBasketText.mono(color: ob.onGround, fontSize: 14)
                      : OpenBasketText.body(ob.meta).copyWith(fontSize: 14),
                ),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            if (chevron && trailing == null) ...[
              const SizedBox(width: 8),
              Icon(CupertinoIcons.chevron_right, size: 16, color: ob.meta),
            ],
          ],
        ),
      ),
    );
  }
}

/// [CharBoxes] you can type into: an invisible field over the boxes takes
/// the keyboard, paste and one-time-code autofill, and the boxes draw it.
class CharBoxesField extends StatefulWidget {
  const CharBoxesField({
    required this.controller,
    this.length = 6,
    this.keyboardType = TextInputType.number,
    this.inputFormatters = const [],
    this.autofillHints = const [],
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = true,
    this.error = false,
    this.struck = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final int length;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final List<String> autofillHints;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool error;
  final bool struck;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<CharBoxesField> createState() => _CharBoxesFieldState();
}

class _CharBoxesFieldState extends State<CharBoxesField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_changed);
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    _focus.removeListener(_changed);
    widget.controller.removeListener(_changed);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CharBoxes(
          value: widget.controller.text,
          length: widget.length,
          focused: _focus.hasFocus,
          error: widget.error,
          struck: widget.struck,
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              autocorrect: false,
              enableSuggestions: false,
              showCursor: false,
              maxLength: widget.length,
              autofillHints: widget.autofillHints,
              inputFormatters: widget.inputFormatters,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ),
      ],
    );
  }
}

/// A dashed rounded outline: the "add" tile, a queued row, Undo.
class DashedRectPainter extends CustomPainter {
  const DashedRectPainter({
    required this.color,
    this.radius = 14,
    this.strokeWidth = 1.5,
    this.dash = 5,
    this.gap = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Rebuilds its child once a second, for lines that say how long ago
/// something was. The countdown has its own tick; this is for the rest.
class EverySecond extends StatefulWidget {
  const EverySecond({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  State<EverySecond> createState() => _EverySecondState();
}

class _EverySecondState extends State<EverySecond> {
  late final Stream<int> _ticks = Stream.periodic(
    const Duration(seconds: 1),
    (i) => i,
  );

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _ticks,
    builder: (context, _) => widget.builder(context),
  );
}

/// The set's switch: a rounded-square ink track with a Signal thumb when
/// on; a pale track with a paper thumb when off. 50x30 inside a 44px row.
class ObSwitch extends StatelessWidget {
  const ObSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: SizedBox(
          height: kMinTapTarget,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 50,
              height: 30,
              padding: const EdgeInsets.all(3),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value
                    ? (ob.dark ? const Color(0xFF2C2C29) : OpenBasketColors.ink)
                    : (ob.dark
                          ? const Color(0xFF3A3A36)
                          : const Color(0xFFDCDCD8)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value
                      ? OpenBasketColors.signal
                      : OpenBasketColors.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
