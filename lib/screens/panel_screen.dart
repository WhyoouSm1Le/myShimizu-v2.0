import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_header.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/cards.dart';
import 'package:myshimizu/widgets/common.dart';

enum FanMode { off, slow, fast }

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  FanMode _fan = FanMode.slow;

  double get _temperature => switch (_fan) {
        FanMode.fast => 29.8,
        FanMode.off => 36.8,
        FanMode.slow => 32.6,
      };

  @override
  Widget build(BuildContext context) {
    final screen = screenOf(MediaQuery.sizeOf(context).width);
    final mobile = screen == Screen.mobile;

    final tempCard = _tempCard(mobile);
    final fanCard = _fanCard(mobile);

    final stats = [
      StatusCard(
        icon: 'temp', 
        green: false, 
        kicker: '24-HOUR AVERAGE', 
        title: '31.2°C', 
        body: 'Within the safe temperature range',
        compact: mobile,
      ),
      StatusCard(
        icon: 'clock', 
        green: true, 
        kicker: 'FAN RUNTIME', 
        title: '4 hours 28 minutes', 
        body: '18% of total operating time',
        compact: mobile,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppHeader(eyebrow: 'CONTROL BOX MONITORING', title: 'Temperature & cooling'),
        if (mobile) ...[
          tempCard,
          const SizedBox(height: 10),
          fanCard,
          const SizedBox(height: 11),
          stats[0],
          const SizedBox(height: 10),
          stats[1],
        ] else ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tempCard),
                const SizedBox(width: 15),
                Expanded(child: fanCard),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: stats[0]),
              const SizedBox(width: 14),
              Expanded(child: stats[1]),
            ],
          ),
          const SizedBox(height: 30),
        ]
      ],
    );
  }

  Widget _tempCard(bool mobile) {
    final hot = _temperature > 35;
    final size = mobile ? 230.0 : 260.0;
    final arc = math.min(_temperature / 60 * 283, 283.0);
    final scale = manrope(7, w: FontWeight.w800, color: const Color(0xFF899895), em: .09);
    
    return CardSurface(
      radius: mobile ? 17 : 19,
      minHeight: mobile ? null : 430,
      padding: EdgeInsets.all(mobile ? 21 : 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Kicker('INTERNAL TEMPERATURE')),
              const SizedBox(width: 8),
              StatusPill(label: hot ? 'HIGH' : 'NORMAL', warning: hot),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: arc), 
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.easeOut,
                      builder: (context, v, _) =>
                          CustomPaint(painter: _GaugePainter(v)),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_temperature',
                          style: sora(52, color: const Color(0xFF143336), em: -.07),
                        ),
                        Transform.translate(
                          offset: const Offset(4, -11),
                          child: Text(
                            '°C',
                            style: manrope(14, color: const Color(0xFF718582)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: size * .68,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'CURRENT TEMPERATURE',
                        style: manrope(
                          7, w: FontWeight.w800, color: const Color(0xFF8A9996), em: .13,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SAFE · 18°C', 
                style: scale
              ),
              Text(
                'CRITICAL · 45°C',
                style: scale,
              )
            ],
          )
        ],
      )
    );
  }

  Widget _fanCard(bool mobile) {
    final running = _fan != FanMode.off;
    final label = switch (_fan) {
      FanMode.off => 'Off',
      FanMode.slow => 'Slow',
      FanMode.fast => 'Fast',
    };
    final spinSeconds = switch (_fan) {
      FanMode.off => 0,
      FanMode.slow => 3,
      FanMode.fast => 1,
    };
    final fg = running ? const Color(0xFF2D9889) : const Color(0xFF65807C);
    final bg = running ? const Color(0xFFDCF1EB) : const Color(0xFFE1EBE7);

    Widget modeButton(FanMode mode, String icon, String text) {
      final active = _fan == mode;
      return Expanded(
        child: Tappable(
          onTap: () => setState(() => _fan = mode),
          semanticLabel: 'Fan $text',
          builder: (context, hover) => Lift(
            hover: hover && !active, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 19),
              decoration: BoxDecoration(
                color: active ? null : const Color(0xFFF0F4F1),
                gradient: active
                    ? lg(145, const[Color(0xFF173F40), Color(0xFF0D2F32)])
                    : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? const Color(0xFF123B3C) : const Color(0xFFD8E1DD)
                )
              ),
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: blob(12, 4),
                      border: Border.all(
                        color: active ? const Color(0xFF547774) : const Color(0xFFCDDAD5)
                      ),
                    ),
                    child: Center(
                      child: AppIcon(
                        icon,
                        size: 17,
                        color: active ? const Color(0xFF6BE0D0) : const Color(0xFF788986),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text.toUpperCase(),
                    style: manrope(
                      8,
                      w: FontWeight.w700,
                      color: active ? const Color(0xFFEAFFFB) : const Color(0xFF788986),
                      em: .12,
                    ),
                  )
                ],
              ),
            )
          )
        )
      );
    }

    return CardSurface(
      radius: mobile ? 17 : 19,
      minHeight: mobile ? null : 430,
      padding: EdgeInsets.all(mobile ? 21 : 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Kicker('PANEL FAN'),
                    const SizedBox(height: 8),
                    Text(
                      'Mode $label',
                      style: sora(
                        21, color: const Color(0xFF132C2F)
                      ),
                    ),
                  ],
                )
              ),
              const SizedBox(width: 12),
              Container(
                width: 67,
                height: 67,
                decoration: BoxDecoration(color: bg, borderRadius: blob(22, 7)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DashedCircle(color: fg.withAlpha(56)),
                      )
                    ),
                    Spin(
                      seconds: spinSeconds, 
                      child: AppIcon('fan', size: 42, color: fg),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 27),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Text(
              'Adjust the fan speed to keep the control panel components at an '
              'optimal temperature.',
              style: manrope(10, color: const Color(0xFF748682), height: 1.7),
            ),
          ),
          const SizedBox(height: 27),
          Row(
            children: [
              modeButton(FanMode.off, 'fanOff', 'Off'),
              const SizedBox(width: 8),
              modeButton(FanMode.slow, 'fanSlow', 'Slow'),
              const SizedBox(width: 8),
              modeButton(FanMode.fast, 'fanFast', 'Fast'),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFEB),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const AppIcon('shield', size: 18, color: Color(0xFF359477)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Automatic mode is active — fan adjusts at the 35°C threshold',
                    style: manrope(8, color: const Color(0xFF647B76), height: 1.5),
                  )
                )
              ],
            ),
          )
        ],
      )
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double arc;
  _GaugePainter(this.arc);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 120;
    final c = size.center(Offset.zero);
    final r = 45 * k;
    final stroke = 6 * k;

    canvas.drawCircle(
      c, 
      r, 
      Paint()
        ..color = const Color(0xFFDFE8E4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), 
      -math.pi / 2, 
      2 * math.pi * (arc / 283), 
      false, 
      Paint()
        ..color = C.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.arc != arc; 
}