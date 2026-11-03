import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myshimizu/core/app_state.dart';
import 'package:myshimizu/core/formatters.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/common.dart';

// - HEADER HALAMAN: EYEBROW + JUDUL, TOMBOL NOTIFIKASI (RIWAYAT POMPA), DAN AVATAR (AKUN)
class AppHeader extends StatefulWidget {
  final String eyebrow;
  final String title;
  const AppHeader({
    super.key,
    required this.eyebrow,
    required this.title,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final _portal = OverlayPortalController();
  final _historyLink = LayerLink();
  final _accountLink = LayerLink();
  final Object _group = Object();
  String? _open;

  void _toggle(String id) {
    final next = _open == id ? null : id;
    setState(() => _open = next);
    if (next == null) {
      _portal.hide();
    } else if (!_portal.isShowing) {
      _portal.show();
    }
  }

  void _close() {
    if (_open == null) return;
    setState(() => _open = null);
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final screen = screenOf(width);
    final mobile = screen == Screen.mobile;
    final btn = mobile ? 38.0 : 40.0;
    final titleSize = mobile
        ? (width <= 390 ? 26.0 : 29.0)
        : clamPx(28, width * .03, 38);
    final maxTitleW = mobile ? (width <= 390 ? 205.0 : 250.0) : double.infinity;

    final left = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxTitleW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Kicker(widget.eyebrow),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: sora(titleSize,
              color: const Color(0xFF0D2528), 
              em: -.04, 
              height: mobile ? 1.08 : null,
            ),
          )
        ],
      ),
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _bellButton(btn),
        SizedBox(width: mobile ? 7 : 10),
        _avatarButton(btn)
      ],
    );

    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(
        mobile ? 4 : 3, 
        0, 
        mobile ? 4 : 3, 
        mobile ? 19 : 25
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: left),
          const SizedBox(width: 12),
          OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildOverlay,
            child: actions,
          )
        ],
      ),
    );
  }

  Widget _bellButton(double size) {
    final active = _open == 'history';
    return CompositedTransformTarget(
      link: _historyLink,
      child: TapRegion(
        groupId: _group,
        child: Tappable(
          onTap: () => _toggle('history'),
          semanticLabel: 'Activity History',
          builder: (context, hover) => Glass(
            blur: 12,
            radius: BorderRadius.circular(13),
            color: active 
                    ? rgba(255, 255, 255, .9) 
                    : rgba(255, 255, 255, .65),
            border: Border.all(
              color: active 
                      ? rgba(45, 151, 138, .24)
                      : rgba(34, 68, 69, .12),
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedRotation(
                    turns: hover ? -0.022 : 0, 
                    duration: const Duration(milliseconds: 200),
                    child: AppIcon(
                      'bell',
                      size: 20,
                      color: active 
                              ? const Color(0xFF123C3D)
                              : const Color(0xFF516965),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD49750),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEFF4F1),
                          width: 2,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  Widget _avatarButton(double size) {
    final active = _open == 'account';
    return CompositedTransformTarget(
      link: _accountLink,
      child: TapRegion(
        groupId: _group,
        child: Tappable(
          onTap: () => _toggle('account'),
          semanticLabel: 'Account',
          builder: (context, hover) => Lift(
            hover: hover, 
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: lg(145, const [Color(0xFF1E4A4B), Color(0xFF123234)]),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: active 
                          ? rgba(45, 151, 138, .5)
                          : rgba(34, 68, 69, .12)
                ),
              ),
              child: const Center(
                child: AppIcon('user', size: 18, color: Color(0xFFD8FFFA),),
              ),
            )
          )
        )
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final open = _open;
    if (open == null) return const SizedBox.shrink();

    final mq = MediaQuery.of(context);
    final mobile = screenOf(mq.size.width) == Screen.mobile;
    final isHistory = open == 'history';

    Widget popover = isHistory
        ? _HistoryPopover(width: math.min(390, mq.size.width - 30), fluid: mobile)
        : _AccountPopover(onLogout: () {
          AppScope.of(context).logout();
        });

    popover = TapRegion(
      groupId: _group,
      onTapOutside: (_) => _close(),
      child: popover,
    );

    if (isHistory && mobile) {
      return Positioned(
        top: 72 + mq.padding.top,
        left: 13,
        right: 13,
        child: popover,
      );
    }

    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: isHistory ? _historyLink : _accountLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.topRight,
        offset: const Offset(0, 12),
        child: popover,
      )
    );
  }
}

// - POPOVER RIWAYAT -
class _HistoryPopover extends StatelessWidget {
  final double width;
  final bool fluid;
  const _HistoryPopover({
    required this.width,
    required this.fluid,
  });

  @override
  Widget build(BuildContext context) {
    final history = AppScope.of(context).history;
    final content = Glass(
      blur: 24,
      radius: BorderRadius.circular(20),
      color: rgba(248, 251, 249, .97),
      border: Border.all(color: rgba(28, 65, 63, .12)),
      shadows: [
        BoxShadow(
          color: rgba(15, 44, 43, .2),
          offset: const Offset(0, 24),
          blurRadius: 65,
        )
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 20, 21, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Kicker('RECENT ACTIVITY'),
                    const SizedBox(height: 6),
                    Text('Pump usage history',
                      style: sora(17, color: const Color(0xFF173235), em: -.035),
                    ),
                  ],
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 29, minHeight: 29),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEEE9),
                    borderRadius: blob(10, 3),
                  ),
                  child: Text(
                    '${history.length}',
                    style: sora(10, w: FontWeight.w700, color: const Color(0xFF276E65)),
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: rgba(29, 66, 65, .08))),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 330),
              child: SingleChildScrollView(
                child: Column(
                  children: [for (final h in history) _HistoryRow(h)],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF0F4F1),
            child: Row(
              children: [
                const StatusDot(color: Color(0xFF50BD8D), size: 6),
                const SizedBox(width: 11),
                Expanded(
                  child: Text('Activity is stored locally in this preview',
                    style: manrope(7, color: const Color(0xFF849491)),
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
    return fluid ? content : SizedBox(width: width, child: content);
  }
}

class _HistoryRow extends StatelessWidget {
  final PumpHistory item;
  const _HistoryRow(this.item);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: rgba(29, 66, 65, .07)))
    ),
    child: Row(
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: lg(145, const [Color(0xFF275E5D), Color(0xFF13383A)]),
            borderRadius: blob(12, 4),
          ),
          child: Text(initials(item.user),
            style: sora(8, w: FontWeight.w700, color: const Color(0xFFDFFAF5), em: .04),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.user,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: manrope(10, w: FontWeight.w700, color: const Color(0xFF1B3638)),
              ),
              const SizedBox(height: 4),
              Text(formatActivityTime(item.startedAt),
                style: manrope(8, color: const Color(0xFF8A999D)),
              ),
            ],
          )
        ),
        const SizedBox(width: 11),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F1EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('${item.durationMinutes} MIN',
            style: manrope(7, w: FontWeight.w800, color: const Color(0xFF367D70), em: .09),
          ),
        )
      ],
    ),
  );
}

// - POPOVER AKUN -
class _AccountPopover extends StatelessWidget {
  final VoidCallback onLogout;
  const _AccountPopover({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user;

    return SizedBox(
      width: 255,
      child: Glass(
        blur: 24,
        radius: BorderRadius.circular(20),
        color: rgba(248, 251, 249, .97),
        border: Border.all(color: rgba(28, 65, 63, .12)),
        shadows: [
          BoxShadow(color: rgba(15, 44, 43, .2), offset: const Offset(0, 24), blurRadius: 65),
        ],
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: rgba(29, 66, 65, .08))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: lg(145, const [Color(0xFF275E5D), Color(0xFF13383A)]),
                      borderRadius: blob(12, 4)
                    ),
                    child: Text(initials(user?.name ?? ''),
                      style: sora(8, w: FontWeight.w700, color: const Color(0xFFDFFAF5), em: .04),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(10, w: FontWeight.w700, color: const Color(0xFF183538)),
                        ),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(8, color: const Color(0xFF81918E)),
                        ),
                      ],
                    )
                  )
                ],
              ),
            ),
            const SizedBox(height: 9),
            Tappable(
              onTap: onLogout,
              semanticLabel: 'Sign out',
              builder: (context, hover) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hover ? const Color(0xFFF4E8E2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const AppIcon('logout', size: 17, color: Color(0xFFA05C45)),
                    const SizedBox(width: 9),
                    Text(
                      'Sign out',
                      style: manrope(9, w: FontWeight.w700, color: const Color(0xFFA05C45)),
                    )
                  ],
                ),
              ) 
            )
          ],
        ),
      ),
    );
  }
}