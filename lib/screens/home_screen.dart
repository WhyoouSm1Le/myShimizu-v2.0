import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myshimizu/core/app_state.dart';
import 'package:myshimizu/core/formatters.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/screens/duration_dialog.dart';
import 'package:myshimizu/widgets/app_header.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/cards.dart';
import 'package:myshimizu/widgets/common.dart';
import 'package:myshimizu/widgets/pump_visual.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _selected = ValueNotifier<int>(10);

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  Future<void> _handlePower(AppState s) async {
    if (s.pumpOn) {
      s.stopPump();
      return;
    }
    final minutes = await showDurationDialog(context, selected: _selected);
    if (minutes != null) s.startPump(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final screen = screenOf(MediaQuery.sizeOf(context).width);
    final mobile = screen == Screen.mobile;
    final firsName = (s.user?.name ?? '').split(' ').first;

    final control = _ControlCard(
      pumpOn: s.pumpOn, 
      remaining: s.remainingSeconds, 
      mobile: mobile, 
      onPower: () => _handlePower(s),
    );

    final connection = StatusCard(
      icon: 'wifi', 
      green: true, 
      kicker: 'ESP32 CONNECTION', 
      title: 'Connected to cloud', 
      body: 'Data synced 3 seconds ago',
      trailing: const SignalBars(),
      compact: mobile,
      minHeight: mobile ? 92 : 104,
    );

    final flow = StatusCard(
      icon: 'droplet', 
      green: false, 
      kicker: 'FLOW STATUS', 
      title: s.pumpOn ? 'Water flow is normal' : 'No water flow', 
      body: s.pumpOn ? '18.4 liters / minute' : 'Pump is currently on standby',
      trailing: const MiniBadge('NORMAL'),
      compact: mobile,
      minHeight: mobile ? 92 : 104,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppHeader(
          eyebrow: headerDate(DateTime.now()), 
          title: 'Hello, $firsName',
        ),
        if (mobile) ...[
          SizedBox(
            height: 331 + 286,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 405,
                  child: PumpVisual(mobile: true),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 331,
                  height: 286,
                  child: control,
                )
              ],
            ),
          ),
          const SizedBox(height: 11),
          connection,
          const SizedBox(height: 10),
          flow,
        ] else
          LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            final cardW = screen == Screen.tablet ? w * .42 : math.min(w * .37, 390.0);

            return SizedBox(
              height: 540 + 104 - 39,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 540,
                    child: PumpVisual(mobile: false),
                  ),
                  Positioned(
                    top: 28,
                    right: 28,
                    width: cardW,
                    height: 484,
                    child: control,
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 540 - 39,
                    child: Row(
                      children: [
                        Expanded(child: connection),
                        const SizedBox(width: 14),
                        Expanded(child: flow),
                      ],
                    )
                  )
                ],
              ),
            );
          })
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  final bool pumpOn;
  final int remaining;
  final bool mobile;
  final VoidCallback onPower;
  const _ControlCard({
    required this.pumpOn,
    required this.remaining,
    required this.mobile,
    required this.onPower,
  });

  @override
  Widget build(BuildContext context) {
    final pad = mobile ? 21.0 : 27.0;
    final divider = rgba(171, 219, 211, .12);

    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Kicker('MAIN CONTROL', color: Color(0xFF6F9691)),
              const SizedBox(height: 8),
              Text(
                pumpOn ? 'Pump is running' : 'Pump is stopped',
                style: sora(
                  21, color: const Color(0xFFF4FFFC), em: -.035,
                ),
              ),
            ],
          )
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StatusDot(color: Color(0xFF52C78C)),
            const SizedBox(width: 8),
            Text(
              pumpOn ? 'ACTIVE' : 'STANDBY',
              style: manrope(
                8, w: FontWeight.w800, color: const Color(0xFF9AB7B2), em: .1,
              ),
            ),
          ],
        )
      ],
    );

    final button = Tappable(
      onTap: onPower,
      semanticLabel: pumpOn ? 'Turn off pump' : 'Turn on pump',
      builder: (context, hover) => Lift(
        hover: hover, 
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: lg(135, const [Color(0xFF71E7D7), Color(0xFFA8F2E8)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rgba(111, 235, 217, .16)),
            boxShadow: [
              BoxShadow(
                color: rgba(68, 221, 201, hover ? .23 : .14),
                offset: Offset(0, hover ? 17 : 13),
                blurRadius: hover ? 40 : 34,
              )
            ]
          ),
          child: DefaultTextStyle(
            style: manrope(12, color: const Color(0xFF062B2B)), 
            child: Row(
              children: [
                const PowerIcon(
                  size: 47, 
                  bg: Color(0xFF0B3335), 
                  fg: Color(0xFF79E1D4), 
                  iconSize: 28,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pumpOn ? 'TURN OFF' : 'TURN ON',
                        style: manrope(
                          12, w: FontWeight.w700, color: const Color(0xFF062B2B), em: .1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pumpOn ? '${formatCountdown(remaining)} REMAINING' : 'SELECT RUN DURATION',
                        style: manrope(
                          7,
                          w: FontWeight.w800,
                          color: const Color(0xFF3B746F),
                          em: .11,
                        ),
                      ),
                    ],
                  )
                ),
                const SizedBox(width: 15),
                const AppIcon('arrow', size: 20),
              ],
            )
          ),
        )
      )
    );

    Widget meta(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: manrope(
          7, w: FontWeight.w800, color: const Color(0xFF62837F), em: .13,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        value,
        style: manrope(
          10, w: FontWeight.w700, color: const Color(0xFFDCEAE7), em: 0.6,
        ),
      )
    ],
  );

    final metaRow = Container(
    padding: const EdgeInsets.only(top: 19),
    decoration: BoxDecoration(border: Border(top: BorderSide(color: divider))),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 21),
              decoration: BoxDecoration(border: Border(left: BorderSide(color: divider))),
              child: meta("TODAY'S RUNTIME", pumpOn ? '02h 18m' : '01h 47m'),
            )
          )
        ],
      ),
    ),
  );
  
    return Glass(
      blur: 20,
      radius: BorderRadius.circular(mobile ? 20 : 22),
      gradient: pumpOn
          ? lg(145, [rgba(5, 28, 30, .94), rgba(14, 50, 48, .9)])
          : lg(145, [rgba(5, 26, 29, .94), rgba(12, 42, 43, .89)]),
      border: Border.all(color: rgba(167, 226, 217, .16)),
      shadows: [
        BoxShadow(
          color: rgba(3, 22, 24, .3), 
          offset: const Offset(0, 26), 
          blurRadius: 60
        ),
      ],
      padding: EdgeInsets.all(pad),
      child: DefaultTextStyle(
        style: manrope(12, color: const Color(0xFFE9F7F4)), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            if (mobile) ...[
              const SizedBox(height: 27),
              button,
              const SizedBox(height: 27)
            ] else
              Expanded(child: Center(child: button)),
            metaRow,
          ],
        )
      ),
    );
  }
}