import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/common.dart';

const kDurations = [5, 10, 15, 20];

// MENAMPILKAN DIALOG PILIH DURASI. MENGEMBALIKAN MENIT JIKA "START PUMP" DITEKAN.
Future<int?> showDurationDialog(BuildContext context, 
    {required ValueNotifier<int> selected}) {
  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, _) => _DurationDialog(selected: selected, animation: anim)
  );
}

class _DurationDialog extends StatelessWidget {
  final ValueNotifier<int> selected;
  final Animation<double> animation;
  const _DurationDialog({
    required this.selected,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = size.width <= 700;
    final pad = mobile ? 21.0 : 27.0;
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    final modal = Glass(
      radius: BorderRadius.circular(mobile ? 21 : 25),
      border: Border.all(color: rgba(190, 225, 219, .72)),
      shadows: [
        BoxShadow(color: rgba(2, 24, 25, .35), offset: const Offset(0, 34))
      ],
      child: GlowBox(
        decoration: const BoxDecoration(color: Color(0xFFF4F8F5)),
        glows: [Glow.fade(1, 0, rgba(71, 197, 179, .13), .29)],
        padding: EdgeInsets.all(pad),
        child: _content(context, mobile),
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: curved,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: ColoredBox(color: rgba(3, 17, 19, .66)),
                  ),
                ),
              )
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedBuilder(
                  animation: curved, 
                  builder: (context, child) => Opacity(
                    opacity: curved.value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - curved.value)),
                      child: Transform.scale(
                        scale: .98 + .02 * curved.value, 
                        child: child
                      ),
                    )
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 510),
                    child: modal,
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _content(BuildContext context, bool mobile) {
    return ValueListenableBuilder<int>(
      valueListenable: selected, 
      builder: (context, value, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9EEE8),
                  borderRadius: blob(16, 5),
                ),
                child: const Center(
                  child: AppIcon(
                    'timer', 
                    size: 25, 
                    color: Color(0xFF237F72),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Kicker('PUMP SCHEDULE'),
                    const SizedBox(height: 6),
                    Text(
                      'Select run duration',
                      style: sora(21, color: const Color(0xFF173235)),
                    ),
                  ],
                )
              ),
              const SizedBox(width: 14),
              Tappable(
                onTap: () => Navigator.of(context).pop(),
                semanticLabel: 'Close',
                builder: (context, h) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rgba(255, 255, 255, .6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8E2DE)),
                  ),
                  child: const Center(
                    child: AppIcon('close', size: 18, color: Color(0xFF728783),),
                  ),
                )
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'The pump will stop automatically when the selected time is complete.',
            style: manrope(10, color: const Color(0xFF748683), height: 1.6),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(builder: (context, c) {
            final cols = mobile ? 2 : 4;
            const gap = 9.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final d in kDurations)
                  SizedBox(
                    width: w,
                    child: _Option(
                      minutes: d, 
                      active: d == value, 
                      height: mobile ? 86 : 102, 
                      onTap: () => selected.value = d,
                    ),
                  )
              ],
            );
          }),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEEA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DefaultTextStyle(
              style: manrope(8, color: const Color(0xFF748483)), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      AppIcon('droplet', size: 17, color: Color(0xFF3F9D8D)),
                      SizedBox(width: 8),
                      Text('Estimated water cycle'),
                    ],
                  ),
                  Text(
                    '$value minutes',
                    style: manrope(8, w: FontWeight.w700, color: const Color(0xFF294A48)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          Tappable(
            onTap: () => Navigator.of(context).pop(value),
            semanticLabel: 'Start pump',
            builder: (context, hover) => Lift(
              hover: hover, 
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: lg(135, const [Color(0xFF164446), Color(0xFF092A2D)]),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(color: rgba(8, 43, 45, .18), offset: const Offset(0, 15), blurRadius: 30),
                  ],
                ),
                child: Row(
                  children: [
                    const PowerIcon(
                      size: 43, 
                      bg: Color(0xFF6EDFD0), 
                      fg: Color(0xFF092A2D), 
                      iconSize: 25,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START PUMP',
                            style: manrope(
                              10,
                              w: FontWeight.w700,
                              color: const Color(0xFFEAFFFB),
                              em: .12
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'RUN FOR $value MINUTES',
                            style: manrope(
                              7,
                              w: FontWeight.w800,
                              color: const Color(0xFF77A7A2),
                              em: .1,
                            ),
                          )
                        ],
                      )
                    ),
                    const SizedBox(width: 14),
                    const AppIcon('arrow', size: 20, color: Color(0xFF65DCCC)),
                  ],
                ),
              )
            )
          )
        ],
      )
    );
  }
}

class _Option extends StatelessWidget {
  final int minutes;
  final bool active;
  final double height;
  final VoidCallback onTap;
  const _Option({
    required this.minutes,
    required this.active,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? const Color(0xFF6CDDD0) : const Color(0xFF6C807C);

    return Tappable(
      onTap: onTap,
      semanticLabel: '$minutes minutes',
      builder: (context, hover) => Lift(
        hover: hover && !active, 
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: active ? null : rgba(255, 255, 255, .6),
            gradient: active ? lg(145, const [Color(0xFF174446), Color(0xFF0B2C2F)]) : null,
            border: Border.all(
              color: active
                  ? const Color(0xFF174748)
                  : hover
                      ? const Color(0xFF9BC8C0)
                      : const Color(0xFFD5DFDB)
            ),
            boxShadow: active
                ? [BoxShadow(color: rgba(11, 48, 49, .16), offset: const Offset(0, 12), blurRadius: 24)]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Positioned(
                  right: -21,
                  bottom: -21,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: fg.withAlpha(41)),
                    ),
                  ),
                ),
                if (active)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: const StatusDot(color: Color(0xFF65DDCD)),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$minutes',
                        style: sora(
                          28,
                          color: active ? const Color(0xFFEAFFFB) : const Color(0xFF173638),
                          em: -.06
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'MINUTES',
                        style: manrope(
                          6,
                          w: FontWeight.w800,
                          color: fg,
                          em: .14,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}