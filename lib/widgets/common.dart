import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';

// - GLOW / RADIAL-GRADIENT -
class Glow {
  final double x, y;
  final List<Color> colors;
  final List<double> stops;

  factory Glow.fade(double x, double y, Color c, double stop) => 
      Glow(x, y, [c, c.withAlpha(0)], [0, stop]);
      
  const Glow(
    this.x,
    this.y,
    this.colors,
    this.stops,
  );
}

class _GlowPainter extends CustomPainter {
  final List<Glow> glows;
  _GlowPainter(this.glows);

  @override
  void paint(Canvas canvas, Size size) {
    for (final g in glows.reversed) {
      final cx = size.width * g.x, cy = size.height * g.y;
      final dx = math.max(cx, size.width -  cx);
      final dy = math.max(cy, size.height - cy);
      final r = math.sqrt(dx * dx + dy * dy);
      final paint = Paint()
        ..shader = ui.Gradient.radial(Offset(cx, cy), r, g.colors, g.stops);
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => true;
}

class GlowBox extends StatelessWidget {
  final BoxDecoration decoration;
  final List<Glow> glows;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  const GlowBox({
    super.key,
    this.decoration =  const BoxDecoration(),
    this.glows = const [],
    this.radius,
    this.padding,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: _GlowPainter(glows),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    if (radius != null) {
      content = ClipRRect(borderRadius: radius!, child: content);
    }
    return DecoratedBox(
      decoration: decoration.copyWith(borderRadius: radius),
      child: content,
    );
  }
}

// - GLASS (BACKDROP BLUR + SHADOW)
class _OuterShadowPainter extends CustomPainter {
  final BorderRadius radius;
  final List<BoxShadow> shadows;
  _OuterShadowPainter(
    this.radius,
    this.shadows  
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    for (final s in shadows) {
      canvas.save();
      
      final outside = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(600))
        ..addRRect(rrect);
      canvas.clipPath(outside);
      canvas.drawRRect(
        rrect.shift(s.offset).inflate(s.spreadRadius), 
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma), 
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OuterShadowPainter old) => true;
}

class Glass extends StatelessWidget {
  final double blur;
  final BorderRadius radius;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final Widget? child;
  const Glass({
    super.key,
    this.blur = 0,
    required this.radius,
    this.color,
    this.gradient,
    this.border,
    this.shadows = const [],
    this.padding,
    this.constraints,
    this.child,
    });

  @override
  Widget build(BuildContext context) {
    Widget w = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        border: border,
        borderRadius: radius,
      ),
      child: padding != null ? Padding(
        padding: padding!, child: child,
      ) : child
    );
    if (constraints != null) {
      w = ConstrainedBox(constraints: constraints!, child: w);
    }
    if (blur > 0) {
      w = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: w,
      );
    }
    w = ClipRRect(borderRadius: radius, child: w);
    if (shadows.isNotEmpty) {
      w = CustomPaint(painter: _OuterShadowPainter(radius, shadows), child: w);
    }
    return w;
  }
}

// - INTERAKSI -
class Tappable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool hovering) builder;
  final String? semanticLabel;
  const Tappable({
    super.key,
    this.onTap,
    required this.builder,
    this.semanticLabel
  });

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Semantics(
          button: widget.onTap != null,
          label: widget.semanticLabel,
          child: widget.builder(context, _hover),
        ),
      ),
    );
  }
}

// -EFEK
class Lift extends StatelessWidget {
  final bool hover;
  final double dy;
  final Widget child;
  const Lift({
    super.key,
    required this.hover,
    this.dy = -2,
    required this.child,
    });

  @override
  Widget build(BuildContext context) => 
  AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    transform: Matrix4.translationValues(0, hover ? dy : 0, 0),
    child: child,
  );
}

// - ELEMEN KECIL -
class Kicker extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double em;
  const Kicker(
    this.text,
    {
    super.key,
    this.color = C.kicker,
    this.size = 8,
    this.em = .17
  });

  @override
  Widget build(BuildContext context) =>
  Text(
    text, style: manrope(size, w:FontWeight.w800, color: color, em: em),
  );
}

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;
  const StatusDot({
    super.key,
    required this.color,
    this.size = 6,
  });

  @override
  Widget build(BuildContext context) =>
  Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color.withAlpha(26), spreadRadius: 4)],
    ),
  );
}

class StatusPill extends StatelessWidget {
  final String label;
  final bool warning;
  const StatusPill({
    super.key,
    required this.label,
    this.warning = false
  });

  @override
  Widget build(BuildContext context) =>
  Glass(
    blur: 10,
    radius: BorderRadius.circular(30),
    color: rgba(240, 250, 246, .55),
    border: Border.all(color: rgba(47, 92, 82, .15)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(color: warning 
                          ? const Color(0xFFD18D4E)
                          : const Color(0XFF52C78C)),
        const SizedBox(width: 7),
        Text(
          label, 
          style: manrope(
            8, w: FontWeight.w800,
          color: const Color(0xFF365B52),
          em: .12
          ),
        )
      ],
    ),
  );
}

class BrandMark extends StatelessWidget {
  final double size;
  final double iconSize;
  const BrandMark({
    super.key,
    required this.size,
    required this.iconSize
  });

  @override
  Widget build(BuildContext context) =>
  Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: lg(145, const [Color(0xFF65E2D2), Color(0xFFB3F3E9)]),
      borderRadius: blob(14, 5),
      boxShadow: [
        BoxShadow(
          color: rgba(74, 213, 195, .18),
          offset: const Offset(0, 8),
          blurRadius: 24
        ),
      ],
    ),
    child: Center(
      child: AppIcon(
        'droplet',
        size: iconSize,
        color: const Color(0xFF092225),
      ),
    ),
  );
}

class PowerIcon extends StatelessWidget {
  final double size;
  final Color bg;
  final Color fg;
  final double iconSize;
  const PowerIcon({
    super.key,
    required this.size,
    required this.bg,
    required this.fg,
    required this.iconSize,
    });

  @override
  Widget build(BuildContext context) =>
  Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: bg, borderRadius: blob(16, 6)),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: (size / 38) / 2 + 12,
          top: (size / 28) / 2 + 12,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: rgba(121, 225, 212, .2)
              ),
            ),
          ),
        ),
        AppIcon('bolt', size: iconSize, color: fg),
      ],
    ),
  );
}

// - GRID & DASHED -
class _GridPainter extends CustomPainter {
  final Color color;
  final double step;
  final bool centered;
  const _GridPainter(
    this.color,
    this.step,
    this.centered,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;

    final ox = centered ? (size.width / 2) % step : 0.0;
    final oy = centered ? (size.height / 2) % step : 0.0;
    final shift = centered ? 0.0 : .5;

    for (double x = ox; x <= size.width; x += step) {
      canvas.drawLine(Offset(x + shift, 0), Offset(x + shift, size.height), p);
    }
    for (double y = oy; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y + shift), Offset(size.width, y + shift), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.color != color || old.step != step || old.centered != centered;
}

class GridLines extends StatelessWidget {
  final Color color;
  final double step;
  final LinearGradient? mask;
  final bool centered;
  const GridLines({
    super.key,
    required this.color,
    required this.step,
    this.mask,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget g = CustomPaint(
      painter: _GridPainter(color, step, centered), 
      size: Size.infinite
    );
    if (mask != null) {
      g = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => mask!.createShader(rect),
        child: g,
      );
    }
    return IgnorePointer(child: g);
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addOval(Rect.fromCircle(
        center: size.center(Offset.zero), 
        radius: size.width / 2 - .5,
      )
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 3), paint);
        d += 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
  old.color != color;
}

class DashedCircle extends StatelessWidget {
  final Color color;
  const DashedCircle({super.key, required this.color});

  @override
  Widget build(BuildContext context) =>
  CustomPaint(
    painter: _DashedCirclePainter(color), size: Size.infinite,
  );
}

List<double> _contrastMatrix(double c) {
  final t = (1 - c) * 0.5 * 255;
  return [c, 0, 0, 0, t, 0, c, 0, 0, t, 0, 0, c, 0, t, 0, 0, 0, 1, 0];
}

List<double> _saturatedMatrix(double s) {
  const lr = .2126, lg = .7512, lb = .0722;
  return [
    lr + (1 - lr) * s, lg - lg * s, lb - lb * s, 0, 0,
    lr - lr * s, lg + (1 - lg) * s, lb - lb * s, 0, 0,
    lr - lr * s, lg - lg * s, lb + (1 - lb) * s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

// - GAMBAR POMPA - PNG ASLI BG PUTIH
class PumpImage extends StatelessWidget {
  final double size;
  final bool cutout;
  final double opacity;
  final double contrast;
  final double saturate;
  final Color? shadowColor;
  final double shadowDy;
  final double shadowBlur;
  const PumpImage({
    super.key,
    required this.size,
    this.cutout = false,
    this.opacity = 1,
    this.contrast = 1.08,
    this.saturate = .9,
    this.shadowColor,
    this.shadowDy = 34,
    this.shadowBlur = 25,
  });

  @override
  Widget build(BuildContext context) {
    final asset =
        cutout ? 'assets/images/pump_cutout.png' : 'assets/images/pump.png';

    Image raw() => Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    Widget img = ColorFiltered(
      colorFilter: ColorFilter.matrix(_contrastMatrix(contrast)),
      child: raw(),
    );
    img = ColorFiltered(
      colorFilter: ColorFilter.matrix(_saturatedMatrix(saturate)),
      child: img,
    );

    Widget? shadow;
    if (shadowColor != null) {
      if (cutout) {
        shadow = Transform.translate(
          offset: Offset(0, shadowDy),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: shadowBlur / 2, sigmaY: shadowBlur /2,
            ),
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(shadowColor!, BlendMode.srcIn),
              child: raw(),
            ),
          ),
        );
      } else {
        shadow = DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: shadowColor!,
                offset: Offset(0, shadowDy),
                blurRadius: shadowBlur,
              )
            ]
          )
        );
      }
    }

    Widget result = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (shadow != null) Positioned.fill(child: shadow),
          img,
        ],
      ),
    );
    
    if (opacity < 1) result = Opacity(opacity: opacity, child: result);
    return IgnorePointer(child: result);
  }
}

// - ANIMASI KIPAS -
class Spin extends StatefulWidget {
  final int seconds;
  final Widget child;
  const Spin({
    super.key,
    required this.seconds,
    required this.child
  });

  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends State<Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(covariant Spin old) {
    super.didUpdateWidget(old);
    if (old != widget.seconds) _apply();
  }

  void _apply() {
    if (widget.seconds <= 0) {
      _c.stop();
      _c.value = 0;
    } else {
      _c.duration = Duration(seconds: widget.seconds);
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
  RotationTransition(turns: _c, child: widget.child);
}