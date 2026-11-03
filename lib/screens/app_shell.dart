import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/nav.dart';
import 'package:myshimizu/screens/home_screen.dart';
import 'package:myshimizu/screens/panel_screen.dart';
import 'package:myshimizu/screens/power_screen.dart';

// - MEMILIH LAYOUT OTOMATIS BERDASARKAN LEBAR LAYAR:
// - MOBILE (<= 700px) : bottom navigation (layout Android)
// - TABLET (<= 1050px) : sidebar ikon 82px
// - dekstop (> 1050px) : sidebar lebar 232px (layout web)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage _page = AppPage.home;

  Widget get _body => KeyedSubtree(
    key: ValueKey(_page),
    child: switch (_page) {
      AppPage.home => const HomeScreen(),
      AppPage.power => const PowerScreen(),
      AppPage.panel => const PanelScreen(),
    },
  );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screen = screenOf(mq.size.width);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: C.pageBg,
        body: screen == Screen.mobile ? _mobile(mq) : _wide(mq, screen),
      ),
    );
  }

  Widget _mobile(MediaQueryData mq) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            13, 21 + mq.padding.top, 13, 16 + 86 + mq.viewPadding.bottom),
          child: _body,
        ),
        Positioned(
          left: 11,
          right: 11,
          bottom: 10 + mq.viewPadding.bottom * .5,
          child: MobileNav(
            page: _page, 
            onSelect: (p) => setState(() => _page = p),
          ),
        ),
      ],
    );
  }

  Widget _wide(MediaQueryData mq, Screen screen) {
    final h = clamPx(24, mq.size.width * .033, 54);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sidebar(
          compact: screen == Screen.tablet, 
          page: _page, 
          onSelect: (p) => setState(() => _page = p),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1540),
                child: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(h, 31, h, 23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _body,
                      const SizedBox(height: 27),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          )
        )
      ],
    );
  }

  Widget _footer() {
    final s = manrope(7, w: FontWeight.w700, color: const Color(0xFF879592), em: .11);

    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: rgba(32, 66, 65, .1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('MYSHIMIZU CONTROL SYSTEM', style: s),
          Text('Last sync 08:42:16   GMT+7', style: s),
        ],
      ),
    );
  }
}