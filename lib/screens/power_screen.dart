import 'package:flutter/material.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_header.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/cards.dart';
import 'package:myshimizu/widgets/common.dart';

class _Metric {
  final String label, value, unit, delta, icon;
  final bool up;
  final Color fg, bg;
  const _Metric(
    this.label,
    this.value,
    this.unit,
    this.delta,
    this.up,
    this.icon,
    this.fg,
    this.bg,
  );
}

const _metrics = [
  _Metric('VOLTAGE', '221.4', 'V', '+0.6%', true, 'voltage', Color(0xFF437F83), Color(0xFFDCECEE)),
  _Metric('CURRENT', '2.18', 'A', '-1.2%', false, 'current', Color(0xFFA36E37), Color(0xFFF2E3D0)),
  _Metric('ACTIVE POWER', '482', 'W', '+2.4%', true, 'power', Color(0xFF657878), Color(0xFFE4EAE7)),
  _Metric("TODAY'S ENERGY", '3.74', 'kWh', '+0.8%', true, 'energy', Color(0xFF358065), Color(0xFFDFF0E8)),
];

class PowerScreen extends StatefulWidget {
  const PowerScreen({super.key});

  @override
  State<PowerScreen> createState() => _PowerScreenState();
}

class _PowerScreenState extends State<PowerScreen> {
  static const _ranges = ['Today', '7 days', '30 days'];
  String _range = 'Today';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final screen = screenOf(width);
    final mobile = screen == Screen.mobile;
    final cols = screen == Screen.dekstop ? 4 : (width <= 390 ? 1 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppHeader(eyebrow: 'REALTIME MONITORING', title: 'Electrical overview'),
        ResponsiveGrid(
          columns: cols, 
          gap: mobile ? 9 : 13, 
          children: [for (final m in _metrics) _MetricCard(m, mobile: mobile)]
        ),
        SizedBox(height: mobile ? 11 : 15),
        CardSurface(
          radius: mobile ? 17 : 19,
          padding: mobile
              ? const EdgeInsets.fromLTRB(15, 21, 15, 21)
              : const EdgeInsets.fromLTRB(27, 25, 27, 21),
          child: _chartCard(mobile),
        )
      ],
    );
  }

  Widget _chartCard(bool mobile) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('CONSUMPTION HISTORY'),
        const SizedBox(height: 8),
        Text('Power usage', style: sora(21, color: const Color(0xFF132C2F), em: -.035)),
      ],
    );

    final tabs = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9E5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: mobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final r in _ranges) _tab(r, mobile)
        ],
      ),
    );

    final summaryValue = _range == 'Today' ? '3.74' : _range == '7 days' ? '24.86' : '108.32';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mobile) ...[title, const SizedBox(height: 17), tabs]
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, tabs],
          ),
        Padding(
          padding: const EdgeInsets.only(left: 54, top: 26, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: '$summaryValue ',
                  style: sora(25, color: const Color(0xFF153235), em: -.04),
                ),
                TextSpan(
                  text: 'kWh',
                  style: manrope(9, w: FontWeight.w700, color: const Color(0xFF153235), em: -.04),
                ),
              ])),
              const SizedBox(height: 4),
              Text(
                'Total consumption · ${_range.toLowerCase()}',
                style: manrope(8, color: const Color(0xFF899794)),
              ),
            ],
          ),
        ),
        const _PowerChart(),
        Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: rgba(31, 66, 65, .09))),
          ),
          child: DefaultTextStyle(
            style: manrope(8, color: const Color(0xFF82918E)), 
            child: Row(
              children: [
                if (!mobile)
                  Row(
                    children: [
                      Container(width: 16, height: 2, color: C.teal),
                      const SizedBox(width: 7),
                      Text(
                        'ACTIVE POWER',
                        style: manrope(8, w: FontWeight.w800, color: const Color(0xFF82918E), em: .1),
                      ),
                    ],
                  ),
                const Spacer(),
                _stat('Average', '367 W'),
                SizedBox(width: mobile ? 12 : 27),
                _stat('Peak', '518 W'),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _tab(String r, bool mobile) {
    final tab = Tappable(
      onTap: () => setState(() => _range = r),
      builder: (context, hover) {
        final active = r == _range;
        
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFBFDFB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [BoxShadow(color: rgba(27, 52, 50, .1), offset: const Offset(0, 3), blurRadius: 12)]
                : null,
          ),
          child: Text(
            r, 
            style: manrope(
              8, 
              w: FontWeight.w700, 
              color: active 
                  ? const Color(0xFF173538) 
                  : const Color(0xFF758683),
                ),
          ),
        );
      }
    );
    return mobile ? Expanded(child: tab) : tab;
  }

  Widget _stat(String label, String value) => Text.rich(TextSpan(children: [
    TextSpan(text: '$label '),
    TextSpan(
      text: value,
      style: manrope(8, w: FontWeight.w700, color: const Color(0xFF314C4B))
    )
  ]));
}

class _MetricCard extends StatelessWidget {
  final _Metric m;
  final bool mobile;
  const _MetricCard(this.m, {required this.mobile});

  @override
  Widget build(BuildContext context) {
    final pad = mobile ? 17.0 : 21.0;

    return CardSurface(
      hoverlift: true,
      radius: mobile ? 17 : 19,
      child: Stack(
        children: [
          Positioned(
            right: -45,
            bottom: -52,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rgba(59, 196, 177, .07),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker(m.label),
                SizedBox(height: mobile ? 25 : 20),
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: m.value,
                    style: sora(clamPx(27, MediaQuery.sizeOf(context).width * .03, 37),
                    color: const Color(0xFF123033), em: -.05, height: 1)
                  ),
                  TextSpan(
                    text: ' ${m.unit}',
                    style: manrope(10, w: FontWeight.w700, color: const Color(0xFF738784)),
                  ),
                ])),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: rgba(31, 66, 65, .08))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        m.delta,
                        style: manrope(
                          8,
                          w: FontWeight.w800,
                          color: m.up ? const Color(0xFF3A9A70) : const Color(0xFFBE754B)
                        ),
                      ),
                      if (!mobile) ...[
                        const SizedBox(width: 7),
                        Text(
                          'from 1 hour ago',
                          style: manrope(8, color: const Color(0xFF899985)),
                        )
                      ]
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 17,
            right: 17,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: m.bg,
                borderRadius: blob(13, 4),
                border: Border.all(color: rgba(255, 255, 255, .7)),
                boxShadow: [
                  BoxShadow(
                    color: rgba(29, 63, 60, .08), 
                    offset: const Offset(0, 7),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppIcon(
                    m.icon, size: 18, color: m.fg,
                  ),
                  Positioned(
                    left: 5,
                    bottom: 5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: m.fg.withAlpha(77),
                        shape: BoxShape.circle,
                      ),
                    )
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}

class _PowerChart extends StatelessWidget {
  const _PowerChart();

  @override
  Widget build(BuildContext context) {
    final axis = manrope(7, color: const Color(0xFF94A19E));

    return SizedBox(
      height: 205,
      child: Stack(
        children: [
          Positioned(
            left: 54,
            top: 7,
            right: 0,
            bottom: 28,
            child: CustomPaint(painter: _ChartPainter()),
          ),
          Positioned(
            left: 0,
            top: 4,
            bottom: 29,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in const ['600W', '400W', '200W', '0']) Text(t, style: axis),
              ],
            )
          ),
          Positioned(
            left: 54,
            right: 0,
            bottom: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final t in const ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00'])
                  Text(t, style: axis),
              ],
            )
          )
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  static const _pts = [
    Offset(8, 126), Offset(57, 115), Offset(106, 120), Offset(155, 83),
    Offset(204, 92), Offset(253, 52), Offset(302, 68), Offset(351, 38),
    Offset(400, 53), Offset(449, 30), Offset(498, 46), Offset(547, 24),
    Offset(596, 34),
  ];

  static const showArea = false;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 604, sy = size.height / 155;
    Offset t(Offset p) => Offset(p.dx * sx, p.dy * sy);

    final grid = Paint()
      ..color = const Color(0xFFDFE7E3)
      ..strokeWidth = 1;
    for (final y in const [25.0, 65.0, 105.0, 145.0]) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y * sy), Offset((x + 3).clamp(0, size.width).toDouble(), y * sy), grid);
        x += 8;
      }
    }

    final line = Path()..moveTo(t(_pts.first).dx, t(_pts.first).dy);
    for (final p in _pts.skip(1)) {
      line.lineTo(t(p).dx, t(p).dy);
    }

    if (showArea) {
      final area = Path.from(line)
        ..lineTo(t(const Offset(596, 145)).dx, t(const Offset(596, 145)).dy)
        ..lineTo(t(const Offset(8, 145)).dx, t(const Offset(8, 145)).dy)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.teal.withAlpha(71), C.teal.withAlpha(0)],
            ).createShader(Rect.fromLTRB(0, 24 * sy, size.width, 145 * sy)),
      );
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = C.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.miter,
    );

    canvas.save();
    canvas.scale(sx, sy);
    canvas.drawCircle(const Offset(449, 30), 5, Paint()..color = const Color(0xFFF8FCFA));
    canvas.drawCircle(
      const Offset(449, 30), 
      5, 
      Paint()
        ..color = C.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
      );
      canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => false;
}