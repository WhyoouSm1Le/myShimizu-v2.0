import 'package:flutter/material.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/common.dart';

// - KARTU KACA PUTIH STANDAR (METRIC, CHART, TEMPREATURE, DLL)
class CardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double? minHeight;
  final bool hoverlift;
  const CardSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 19,
    this.minHeight,
    this.hoverlift = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget build(bool hover) => Glass(
      blur: 14,
      radius: BorderRadius.circular(radius),
      color: rgba(250, 252, 250, .78),
      border: Border.all(color: rgba(29, 66, 65, .1)),
      shadows: [
        BoxShadow(
          color: rgba(28, 53, 51, .06), 
          offset: const Offset(0, 13)
        )
      ],
      padding: padding,
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      child: child,
    );
    if (!hoverlift) return build(false);
    return Tappable(
      builder: (_, h) => Lift(
        hover: h, dy: -3, 
        child: build(h)
      )
    );
  }
}

// GRID RESPONSIF SEDERHANA DENGAN JUMLAH KOLOM TETAP
class ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double gap;
  final List<Widget> children;
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.gap,
    required this.children
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final w = (c.maxWidth - gap * (columns - 1)) / columns;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final ch in children) SizedBox(width: w, child: ch,)
      ],
    );
  }); 
}

class SignalBars extends StatelessWidget {
  const SignalBars({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 29,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final h in const [8.0, 14.0, 21.0, 28.0])
        Container(
          width: 4,
          height: h,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF4BBD96),
            borderRadius: BorderRadius.circular(4),
          ),
        )
      ],
    ),
  );
}

class MiniBadge extends StatelessWidget {
  final String text;
  const MiniBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFE1F2EB),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text,
      style: manrope(7, 
      w: FontWeight.w800, 
      color: const Color(0xFF3B806B)
      ),
    ),
  );
}

// - KARTU STATUS (IKON + TEKS + TRAILING) HOME & CONTROL BOX
class StatusCard extends StatelessWidget {
  final String icon;
  final bool green;
  final String kicker;
  final String title;
  final String body;
  final Widget? trailing;
  final bool compact;
  final double minHeight;
  const StatusCard({
    super.key,
    required this.icon,
    required this.green,
    required this.kicker,
    required this.title,
    required this.body,
    this.trailing,
    this.compact = false,
    this.minHeight = 104,
  });

  @override
  Widget build(BuildContext context) {
    final fg = green ? const Color(0xFF27836B) : const Color(0xFFA66C32);
    final bg = green ? const Color(0xFFDFF3EB) : const Color(0xFFF4E6D4);
    return Glass(
      blur: 18,
      radius: BorderRadius.circular(compact ? 17 : 18),
      color: rgba(248, 251, 249, .86),
      border: Border.all(color: rgba(255, 255, 255, .7)),
      shadows: [
        BoxShadow(
          color: rgba(27, 54, 51, .1), 
          offset: const Offset(0, 16), 
          blurRadius: 35,
        ),
      ],
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 15 : 20,
        vertical: compact ? 15 : 18,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: blob(15, 5)
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppIcon(
                  icon,
                  size: 20,
                  color: fg,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: fg.withAlpha(71)),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Kicker(kicker),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(13, w: FontWeight.w700, color: const Color(0xFF183135)),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(9, color: const Color(0xFF80908D)),
                ),
              ],
            ), 
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}