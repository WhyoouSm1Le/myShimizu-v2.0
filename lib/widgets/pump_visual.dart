import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/common.dart';

class _HaloPainter extends CustomPainter {
  final Offset center;
  final double radius;
  const _HaloPainter(this.center, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    Path ring(double outer) => Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: center, radius: outer))
      ..addOval(Rect.fromCircle(center: center, radius: radius));

      canvas.drawPath(ring(radius + 59), Paint()..color = rgba(29, 91, 85, .08));
      canvas.drawPath(ring(radius + 58), Paint()..color = rgba(255, 255, 255, .16));

      final line = Paint()
        ..color = rgba(29, 91, 85, .13)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius - .5, line);
      canvas.drawLine(Offset(center.dx, center.dy - 260), Offset(center.dx, center.dy + 260), line);
      canvas.drawLine(Offset(center.dx - 260, center.dy), Offset(center.dx + 260, center.dy), line);
  }

  @override
  bool shouldRepaint(covariant _HaloPainter old) =>
      old.center != center || old.radius != radius;
}

//PANEL BESAR BERISI GAMBAR POMPA DI HALAMAN HOME
class PumpVisual extends StatelessWidget {
  final bool mobile;
  const PumpVisual({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final pad = mobile ? 19.0 : 26.0;
    final radius = BorderRadius.circular(mobile ? 24 : 28);

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = c.maxHeight;
      final imgSize = mobile ? w * 1.12 : math.min(w * .62, 660.0);
      final imgCx = mobile ? w * .5 : w * .07 + imgSize / 2;
      final imgCy = h * .51;
      final haloCenter = Offset(mobile ? w * .5 : w * .27, h * .51);
      final haloR = mobile ? 125.0 : 220.0;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: rgba(20, 47, 45, .12), 
              offset: const Offset(0, 28), 
              blurRadius: 70
            ),
          ],
        ),
        position: DecorationPosition.background,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: rgba(20, 54, 55, .1)),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: GlowBox(
              decoration: BoxDecoration(
                gradient: lg(135, const [Color(0xFFDCE6E1), Color(0xFFB7CCC5)]),
              ),
              glows: [
                Glow(
                  mobile ? .5 : .34, 
                  .49, 
                  [
                    rgba(255, 255, 255, .94),
                    rgba(255, 255, 255, .94),
                    rgba(220, 232, 227, .72),
                    rgba(220, 232, 227, 0),
                  ], 
                  const [0, .19, .43, .66]
                ),
              ],
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _HaloPainter(haloCenter, haloR)),
                    ),
                    Positioned.fill(
                      child: GridLines(
                        color: rgba(7, 27, 29, .08), 
                        step: mobile ? 38 : 52,
                        centered: true,
                        mask: mobile
                            ? lg(180, const [Colors.black, Colors.transparent], const [0, .8])
                            : lg(90, const [Colors.black, Colors.transparent], const [0, .68]),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: h * .42,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [rgba(7, 22, 23, 0), rgba(7, 22, 23, .3)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: imgCx - imgSize / 2,
                      top: imgCy - imgSize / 2,
                      width: imgSize,
                      height: imgSize,
                      child: PumpImage(
                        size: imgSize,
                        cutout: true,
                        contrast: 1.08,
                        saturate: .9,
                        shadowColor: rgba(24, 45, 43, .22),
                      ),
                    ),
                    Positioned(
                      left: pad,
                      right: pad,
                      top: pad,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'UNIT 01 / MAIN PUMP',
                              style: manrope(
                                8,
                                w: FontWeight.w800,
                                color: const Color(0xFF45615C),
                                em: .17
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StatusPill(label: 'ONLINE'),
                        ],
                      ),
                    ),
                    Positioned(
                      left: mobile ? 19 : 27,
                      right: mobile ? 19 : 27,
                      bottom: mobile ? 18 : 22,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'SHIMIZU PS-128 BIT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _caption(),
                            ),
                          ),
                          if (!mobile) ...[
                            const SizedBox(width: 12),
                            Flexible(
                            child: Text(
                              'LAST ACTIVE AT 08:42',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _caption(),
                              ),
                            ),
                          ]
                        ],
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
  
  TextStyle _caption() => manrope(7, w: FontWeight.w800, color: rgba(236, 249, 245, .8), em: .15);
}