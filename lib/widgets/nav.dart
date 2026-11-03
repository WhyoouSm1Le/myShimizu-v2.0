import 'package:flutter/material.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/common.dart';

enum AppPage { home, power, panel }

const _items = <(AppPage, String, String)>[
  (AppPage.home, 'home', 'Home'),
  (AppPage.power, 'chart', 'Electrical'),
  (AppPage.panel, 'temp', 'Control Box'),
];

const _mobileLabels = {
  AppPage.home: 'Home',
  AppPage.power: 'Electrical',
  AppPage.panel: 'Control Box',
};

// - SIDEBAR (WEB / TABLET) -
class Sidebar extends StatelessWidget {
  final bool compact;
  final AppPage page;
  final ValueChanged<AppPage> onSelect;
  const Sidebar({
    super.key,
    required this.compact,
    required this.page,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 82 : 232,
      child: GlowBox(
        decoration: BoxDecoration(
          color: C.sidebarBg,
          border: Border(right: BorderSide(color: rgba(133, 180, 173, .14))),
        ),
        glows: [
          Glow.fade(.2, 0, rgba(58, 133, 129, .24), .31)
        ],
        padding: compact
            ? const EdgeInsets.fromLTRB(14, 27, 14, 24)
            : const EdgeInsets.fromLTRB(20, 30, 20, 24),
        child: DefaultTextStyle(
          style: manrope(12, color: const Color(0xFFE8F2EF)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _brand(),
              if (!compact) ...[
                const SizedBox(height: 33),
                Padding(
                  padding: const EdgeInsetsGeometry.fromLTRB(14, 0, 0, 12),
                  child: Kicker(
                    'MAIN MENU',
                    color: const Color(0xFF55716E),
                    em: .18,
                  ),
                ),
              ] else
                const SizedBox(height: 28),
              for (final it in _items) _SideItem(
                icon: it.$2, 
                label: it.$3, 
                active: page == it.$1, 
                compact: compact, 
                onTap: () => onSelect(it.$1)
              ),
              const Spacer(),
              if (!compact) _system(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    final mark = const BrandMark(size: 43, iconSize: 22);
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 0 : 4, 0, compact ? 0 : 4, 29),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: rgba(180, 218, 211, .13))),
      ),
      child: compact
          ? Center(child: mark)
          : Row(
            children: [
              mark,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MYSHIMIZU',
                      style: sora(15, w: FontWeight.w700, color: const Color(0xFFE8F2EF), em: .18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'CONTROL SYSTEM',
                      style: manrope(7, w: FontWeight.w800, color: const Color(0xFF71908C), em: .17),
                    ),
                  ],
                )
              )
            ],
          )
    );
  }

  Widget _system() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: rgba(151, 204, 195, .04),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: rgba(132, 184, 177, .15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('SYTEM STATUS'),
        const SizedBox(height: 10),
        Row(
          children: [
            const StatusDot(color: Color(0xFF61D79B), size: 7),
            const SizedBox(width: 13),
            Text(
              'All systems normal',
              style: manrope(10, w: FontWeight.w700, color: const Color(0xFFC2D8D4)),
            ),
            const SizedBox(height: 7),
          ],
        ),
        Text(
              'Firmware v2.4.1',
              style: manrope(8, color: const Color(0xFF55716D)),
            ),
      ],
    ),
  );
}

// - WEB & TABLET
class _SideItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;
  const _SideItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hover) {
        final color = active
            ? const Color(0xFFEAFFFB)
            : hover
                ? const Color(0xFFDFF6F2)
                : const Color(0xFF77918D);
        final glyphColor = active ? const Color(0xFF071B1D) : color;
        final glyph = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: hover
              ? (Matrix4.translationValues(0, -1, 0)..rotateZ(-0.035))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: blob(11, 4),
            color: active ? null : rgba(133, 190, 181, .035),
            gradient: active
                ? lg(145, const [Color(0xFF75E2D3), Color(0xFF4DC3B5)])
                : null,
            border: Border.all(
              color: active
                  ? rgba(122, 229, 211, .4)
                  : hover
                      ? rgba(116, 219, 203, .16)
                      : rgba(123, 176, 169, .08)
            ),
            boxShadow: active
                ? [BoxShadow(color: rgba(61, 205, 185, .2), offset: const Offset(0, 7), blurRadius: 18)]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppIcon(
                icon,
                size: 20,
                color: glyphColor,
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: glyphColor.withAlpha(89),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        );

        final row = Row(
          mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            glyph,
            if (!compact) ...[
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  style: manrope(11, w: FontWeight.w700, color: color),
                )
              )
            ]
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: !active && hover ? rgba(151, 205, 196, .86) : null,
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.centerRight,
                      colors: [rgba(75, 210, 191, .16), rgba(75, 210, 191, .04)],
                    )
                  : null,
              border: Border.all(color: active ? rgba(106, 219, 202, .15) : Colors.transparent)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  if (active)
                    const Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 3,
                      child: ColoredBox(color: Color(0xFF5BD8C7))
                    ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
                    alignment: Alignment.center,
                    child: row,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// - BOTTOM NAV MOBILE -
class MobileNav extends StatelessWidget {
  final AppPage page;
  final ValueChanged<AppPage> onSelect;
  const MobileNav({
    super.key,
    required this.page,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Glass(
      blur: 18,
      radius: BorderRadius.circular(20),
      color: rgba(6, 25, 28, .95),
      border: Border.all(color: rgba(130, 206, 196, .18)),
      shadows: [
        BoxShadow(
          color: rgba(5, 24, 26, .3), 
          offset: const Offset(0, 20), 
          blurRadius: 40
        ),
      ],
      padding: EdgeInsets.fromLTRB(8, 7, 8, 7 + bottomInset * .5),
      child: Row(
        children: [
          for (final it in _items)
            Expanded(
              child: _MobileItems(
                icon: it.$2, 
                label: _mobileLabels[it.$1]!, 
                active: page == it.$1, 
                onTap: () => onSelect(it.$1),
              )
            )
        ],
      ),
    );
  }
}

// - MOBILE -
class _MobileItems extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _MobileItems({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? const Color(0xFF69DFD0) : const Color(0xFF77918D);
    final textColor = active ? const Color(0xFFEAFFFB) : const Color(0xFF77918D);
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, _) => Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: active ? rgba(84, 216, 198, .13) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 29,
              height: 29,
              child: Center(
                child: AppIcon(
                  icon, size: 20, color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: manrope(7, w: FontWeight.w700, color: textColor),
            )
          ],
        ),
      ),
    );
  }
}