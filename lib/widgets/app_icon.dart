import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _icons = {
  'home': r'''<path d="M3.3 11.1 12 4l8.7 7.1"/><path d="M5.8 10v8.4c0 .9.7 1.6 1.6 1.6h9.2c.9 0 1.6-.7 1.6-1.6V10"/><path d="M9 20v-5.1c0-.8.6-1.4 1.4-1.4h3.2c.8 0 1.4.6 1.4 1.4V20"/><path d="M16.2 7.4V4.8h2.2v4.4"/><circle cx="12" cy="9.2" r=".9" fill="currentColor" stroke="none"/>''',
  'chart': r'''<path d="M3.5 18.8h17" opacity=".45"/><path d="M5 15.8 8.1 12l2.8 2.1 4.2-6 3.9 2.5"/><path d="m15.2 5.2 4.5 1.2-1.2 4.5"/><circle cx="8.1" cy="12" r="1" fill="currentColor" stroke="none"/><circle cx="15.1" cy="8.1" r="1" fill="currentColor" stroke="none"/>''',
  'temp': r'''<rect x="4" y="4" width="16" height="16" rx="4"/><path d="M8 8h3M8 12h2M8 16h3" opacity=".5"/><path d="M15.8 15V9.4a1.8 1.8 0 1 0-3.6 0V15a2.8 2.8 0 1 0 3.6 0Z"/><path d="M14 16.8v-5.5"/>''',
  'wifi': r'''<path d="M3.5 9.1a13.3 13.3 0 0 1 17 0"/><path d="M6.8 12.8a8.2 8.2 0 0 1 10.4 0"/><path d="M10 16.3a3.2 3.2 0 0 1 4 0"/><circle cx="12" cy="19.1" r="1.35" fill="currentColor" stroke="none"/><path d="M18.9 4.7h1.8v1.8" opacity=".5"/>''',
  'bolt': r'''<path d="m13.9 2.7-8 10.1h5l-.8 8.5 8-10.6h-5.2l1-8Z"/><path d="M4.1 7.2h3M16.8 17.2h3" opacity=".55"/>''',
  'voltage': r'''<path d="M12.8 2.8 5.9 12h5l-.7 9.2 7.9-11h-5.4l.1-7.4Z"/><path d="M4 5.2h3M17 18.8h3" opacity=".45"/>''',
  'current': r'''<path d="M4 12a8 8 0 0 1 13.9-5.4"/><path d="m18.4 3.8-.2 3.7-3.7-.2"/><path d="M20 12A8 8 0 0 1 6.1 17.4"/><path d="m5.6 20.2.2-3.7 3.7.2"/><circle cx="12" cy="12" r="1.7" fill="currentColor" stroke="none"/>''',
  'power': r'''<path d="M12 3v8"/><path d="M7.2 5.8a8 8 0 1 0 9.6 0"/><path d="M7.1 16.4h2.2l1.1-2.7 2.2 4.5 1.2-2.5h3.1" opacity=".55"/>''',
  'energy': r'''<path d="M7.3 3.5h9.4v17H7.3z"/><path d="M9.8 1.8h4.4v1.7"/><path d="m12.8 6.2-3 4.5h2.4l-.7 4.4 3.2-5h-2.4l.5-3.9Z"/><path d="M9.8 17.6h4.4" opacity=".5"/>''',
  'fan': r'''<circle cx="12" cy="12" r="2.1" fill="currentColor" stroke="none"/><path d="M11 10.1c-1.5-2.1-1.1-6.5 1.8-7.1 2.6-.5 4 2.2 2.8 4.4-.7 1.3-1.8 2.2-2.7 3M13.9 11c2.1-1.5 6.5-1.1 7.1 1.8.5 2.6-2.2 4-4.4 2.8-1.3-.7-2.2-1.8-3-2.7M13 13.9c1.5 2.1 1.1 6.5-1.8 7.1-2.6.5-4-2.2-2.8-4.4.7-1.3 1.8-2.2 2.7-3M10.1 13c-2.1 1.5-6.5 1.1-7.1-1.8-.5-2.6 2.2-4 4.4-2.8 1.3.7 2.2 1.8 3 2.7"/>''',
  'fanOff': r'''<circle cx="12" cy="12" r="7.5"/><path d="m8.8 8.8 6.4 6.4"/>''',
  'fanSlow': r'''<circle cx="9" cy="12" r="2.2"/><path d="M9 9.8C7.9 7.7 9.2 5.5 11.2 6c1.3.3 1.8 1.7.9 2.8-.7.8-1.7 1-2.4 1.5M11.2 12c2.1-1.1 4.3.2 3.8 2.2-.3 1.3-1.7 1.8-2.8.9-.8-.7-1-1.7-1.5-2.4M9 14.2c1.1 2.1-.2 4.3-2.2 3.8-1.3-.3-1.8-1.7-.9-2.8.7-.8 1.7-1 2.4-1.5"/><path d="M17 9.5h3M17 13h3M17 16.5h3" opacity=".5"/>''',
  'fanFast': r'''<circle cx="10" cy="12" r="2"/><path d="M10 10c-1.2-2.2.4-4.5 2.4-3.7 1.7.7 1.3 2.6-.8 4M12 12c2.2-1.2 4.5.4 3.7 2.4-.7 1.7-2.6 1.3-4-.8M10 14c1.2 2.2-.4 4.5-2.4 3.7-1.7-.7-1.3-2.6.8-4M8 12c-2.2 1.2-4.5-.4-3.7-2.4.7-1.7 2.6-1.3 4 .8"/><path d="M18 7h2M18 11h3M18 15h2" opacity=".55"/>''',
  'droplet': r'''<path d="M12 2.7c-1.8 2.7-6.4 7.7-6.4 12a6.4 6.4 0 0 0 12.8 0c0-4.3-4.6-9.3-6.4-12Z"/><path d="M8.7 15.3c.3 1.6 1.5 2.7 3.1 3"/><path d="M9.3 12.1c.8-1.8 1.8-3.4 2.7-4.7" opacity=".45"/>''',
  'bell': r'''<path d="M18.5 10.2c0-3.8-2.5-6.3-6.5-6.3s-6.5 2.5-6.5 6.3c0 4-1.5 5.3-2.2 6.6-.4.7.1 1.4.9 1.4h15.6c.8 0 1.3-.7.9-1.4-.7-1.3-2.2-2.6-2.2-6.6Z"/><path d="M9.5 20.2a3.3 3.3 0 0 0 5 0M9.9 3.9V2.5h4.2v1.4"/><path d="M7.9 14.8h8.2" opacity=".45"/>''',
  'user': r'''<circle cx="12" cy="8" r="4.1"/><path d="M4.6 20c.7-3.8 3.5-5.9 7.4-5.9s6.7 2.1 7.4 5.9"/><path d="M8.2 15.1 12 18l3.8-2.9" opacity=".5"/>''',
  'arrow': r'''<path d="M5 12h13.5"/><path d="M14 7.5c1.5 1.7 3 3.2 4.5 4.5-1.5 1.3-3 2.8-4.5 4.5"/>''',
  'clock': r'''<circle cx="12" cy="12" r="8.7"/><path d="M12 6.8v5.4l3.8 2.1"/><path d="M5.8 3.7 3.7 5.8M18.2 3.7l2.1 2.1" opacity=".5"/><circle cx="12" cy="12" r=".9" fill="currentColor" stroke="none"/>''',
  'shield': r'''<path d="M12 3.3c-2.1 1.2-4.3 2-6.6 2.6v5.2c0 4.5 2.3 7.8 6.6 9.7 4.3-1.9 6.6-5.2 6.6-9.7V5.9c-2.3-.6-4.5-1.4-6.6-2.6Z"/><path d="m8.9 12.1 2 2 4.5-4.5"/>''',
  'mail': r'''<rect x="3.3" y="5.2" width="17.4" height="13.6" rx="3"/><path d="m4.8 7 7.2 6 7.2-6M4.8 17l4.5-4.2M19.2 17l-4.5-4.2"/>''',
  'lock': r'''<rect x="4.5" y="10" width="15" height="11" rx="3"/><path d="M8 10V7.4a4 4 0 0 1 8 0V10"/><circle cx="12" cy="15.3" r="1.2" fill="currentColor" stroke="none"/><path d="M12 16.5v1.7"/>''',
  'logout': r'''<path d="M10 4H5.5A2.5 2.5 0 0 0 3 6.5v11A2.5 2.5 0 0 0 5.5 20H10"/><path d="M14.5 7.5 19 12l-4.5 4.5M8 12h11"/>''',
  'timer': r'''<circle cx="12" cy="13" r="8"/><path d="M12 13V8.5M9 2.5h6M17.8 5.8l1.4-1.4"/><path d="M12 13h3.2" opacity=".55"/>''',
  'close': r'''<path d="m6 6 12 12M18 6 6 18"/>''',
};

class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const AppIcon(
    this.name,
    {
      super.key,
      this.size = 20,
      this.color
    });

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    final inner = (_icons[name] ?? '').replaceAll('currentColor', '#000000');
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="#000000" stroke-width="1.65" stroke-linecap="round" '
        'stroke-linejoin="round">$inner</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}