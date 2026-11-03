import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myshimizu/core/app_state.dart';
import 'package:myshimizu/core/formatters.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/widgets/app_icon.dart';
import 'package:myshimizu/widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController(text: 'rizky@aquacontrol.id');
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _accepted = false;
  String _error = '';

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _fail(String message) => setState(() => _error = message);

  void _setMode(bool register) {
    setState(() {
      _register = register;
      _error = '';
      _password.clear();
      _confirm.clear();
    });
  }

  void _submit() {
    final app = AppScope.of(context);
    final email = _email.text.trim();

    if (_register) {
      final name = _fullName.text.trim();
      if (name.length < 2) return _fail('Enter your full name to create an account.');
      if (!email.contains('@')) return _fail('Enter a valid email address.');
      if (_password.text.length < 6) {
        return _fail('Create a password with at least 6 characters.');
      }
      if (_password.text != _confirm.text) {
        return _fail('Your password confirmation does not match.');
      }
      if (!_accepted) {
        return _fail('Accept the terms and privacy policy to continue.');
      }
      app.register(AppUser(name: name, email: email));
      return;
    }

    if (!email.contains('@') || _password.text.length < 4) {
      return _fail('Enter a valid email and at least 4 password characters.');
    }
    app.login(app.findAccount(email) ??
        AppUser(name: userNameFromEmail(email), email: email));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screen = screenOf(size.width);

    final Widget body;
    if (screen == Screen.mobile) {
      body = _mobile(size);
    } else {
      final w = size.width;
      final panelW = w > 1050 ? math.max(420.0, w * .4) : math.max(390.0, w * .85 / 1.85);
      final h = math.max(size.height, 640.0);
      body = SingleChildScrollView(
        child: SizedBox(
          height: h,
          child: Row(
            children: [
              SizedBox(width: w - panelW, height: h, child: _showCaseWide(w - panelW, h, w)),
              SizedBox(width: panelW, height: h, child: _panel(w, false)),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: screen == Screen.mobile
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(backgroundColor: C.loginPanelBg, body: body),
    );
  }

  Widget _showcaseBackground() => GlowBox(
    decoration: BoxDecoration(
      gradient: lg(145, const [Color(0xFF061315), Color(0xFF0C2527)]),
    ),
    glows: [
      Glow.fade(.78, .2, rgba(71, 188, 176, .22), .28),
      Glow.fade(.2, .8, rgba(189, 139, 77, .12), .30),
    ],
    child: const SizedBox.expand(),
  );

  Widget _brand(double markSize, double iconSize, double titleSize) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      BrandMark(
        size: markSize, 
        iconSize: iconSize
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MYSHIMIZU',
            style: sora(titleSize,
              w: FontWeight.w700, color: const Color(0xFFE9F7F4), em: .2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'CONTROL SYSTEM',
            style: manrope(7,
              w: FontWeight.w800, color: const Color(0xFF71908C), em: .17,
            ),
          ),
        ],
      )
    ],
  );

  Widget _showCaseWide(double w, double h, double vw) {
    final pad = clamPx(32, vw * .05, 76);
    final boxW = math.min(vw * .68, 900.0);
    final boxH = math.min(vw * .57, 720.0);
    final img = math.max(boxW, boxH);

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(child: _showcaseBackground()),
          Positioned.fill(
            child: Opacity(
              opacity: .4,
              child: GridLines(
                color: rgba(118, 204, 192, .08), 
                step: 58,
                mask: lg(135, const [Colors.black, Colors.transparent], const [0, .75]),
              ),
            )
          ),
          Positioned(
            right: -.18 * w,
            bottom: -.18 * h,
            width: boxW,
            height: boxH,
            child: Center(
              child: PumpImage(
                size: img,
                opacity: .28,
                contrast: 1.15,
                saturate: 0,
                shadowColor: rgba(0, 0, 0, .45),
                shadowDy: 40,
                shadowBlur: 45,
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _brand(48, 24, 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.min(
                          620, 
                          (w - 2 * pad) * .88)),
                        child: _message(vw),
                    ),
                  ),
                ),
                Text(
                  'SHIMIZU PS-128 BIT  FIRMWARE 2.4.0',
                  style: manrope(7, 
                    w: FontWeight.w800, color: const Color(0xFF4D6B68), em: .16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _message(double vw) {
    final h1 = clamPx(44, vw * .053, 78);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Kicker('SMART WATER PUMP INFRASTRUCTURE', color: Color(0xFF63D5C6), em: .22),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 590),
          child: Text(
            'Control every drop with confidence.',
            style: sora(h1, color: const Color(0xFFE9F7F4), em: -.065, height: 1.03),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 510),
          child: Text(
            'Monitor energy, manage pump runtime, and keep your home water system '
            'protected from one secure workspace.',
            style: manrope(13, color: const Color(0xFF8DAAA6), height: 1.8),
          ),
        ),
        const SizedBox(height: 39),
        _statusChip(),
      ],
    );
  }

  Widget _statusChip() => Glass(
    blur: 12,
    radius: BorderRadius.circular(18),
    color: rgba(156, 216, 207, .06),
    border: Border.all(color: rgba(135, 211, 200, .16)),
    padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: rgba(105, 223, 208, .12),
            borderRadius: blob(15, 5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: DashedCircle(color: rgba(105, 223, 208, .35)),
                )
              ),
              const AppIcon('wifi', size: 26, color: Color(0xFF69DFD0)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System connected',
              style: manrope(10, 
              w: FontWeight.w700, color: const Color(0xFFDCECE9)),
            ),
            const SizedBox(height: 5),
            Text(
              'ESP32 UNIT 01  SIGNAL EXCELLENT',
              style: manrope(7,
                w: FontWeight.w800, color: const Color(0xFF5E817D), em: .12,
              ),
            )
          ],
        )
      ],
    ),
  );

  Widget _showcaseMobile() => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 275),
    child: ClipRect(
      child: Stack(
        children: [
          Positioned.fill(child: _showcaseBackground()),
          Positioned.fill(
            child: Opacity(
              opacity: .4,
              child: GridLines(
                color: rgba(118, 204, 192, .08), 
                step: 39,
                mask: lg(135, const [Colors.black, Colors.transparent], const [0, .75]),
              ),
            )
          ),
          Positioned(
            right: -100,
            bottom: -90,
            width: 390,
            height: 300,
            child: Center(
              child: PumpImage(
                size: 300,
                opacity: .28,
                contrast: 1.15,
                saturate: 0,
                shadowColor: rgba(0, 0, 0, .45),
                shadowDy: 40,
                shadowBlur: 45,
              ),
            )
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(
              22, 25 + MediaQuery.paddingOf(context).top, 22, 25,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 225),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _brand(42, 21, 16),
                    const Spacer(),
                    FractionallySizedBox(
                      widthFactor: .85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Kicker(
                          'SMART WATER PUMP INFRASTRUCTURE',
                          color: Color(0xFF63D5C6), em: .22,
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Text(
                              'Control every drop with confidence.',
                              style: sora(
                                clamPx(32, MediaQuery.sizeOf(context).width * 1, 44),
                                color: const Color(0xFFE9F7F4),
                                em: -.065,
                                height: 1.03,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

// - PANEL FORM (SISI TERANG) -
  Widget _mobile(Size size) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _showcaseMobile(),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: math.max(0, size.height - 275)),
            child: _panel(size.width, true),
          )
        ],
      ),
    );
  }

  Widget _panel(double vw, bool mobile) {
    final hPad = mobile ? (vw <= 390 ? 18.0 : 22.0) : clamPx(30, vw * .06, 90);
    
    return GlowBox(
      decoration: const BoxDecoration(color: C.loginPanelBg),
      glows: [Glow.fade(1, 0, rgba(63, 187, 170, .12), .27)],
      child: Padding(
        padding: mobile
            ? EdgeInsetsGeometry.fromLTRB(hPad, 38, hPad, 45)
            : EdgeInsetsGeometry.symmetric(horizontal: hPad, vertical: 30),
        child: Center(
          child: () {
            final form = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _form(vw, mobile),
            );
            return mobile ? form : SingleChildScrollView(child: form);
          }(),
        ),
      ),
    );
  }

  Widget _form(double vw, bool mobile) {
    final fieldH = _register ? 52.0 : 57.0;
    final gap = _register ? 13.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Kicker(_register ? 'NEW OPERATOR' : 'AUTHORIZED ACCESS'),
        const SizedBox(height: 11),
        Text(
          _register ? 'Create account.' : 'Welcome back.',
          style: sora(
            mobile ? 36 : clamPx(35, vw * .04, 49),
            color: const Color(0xFF102C2F),
            em: -.055,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          _register
              ? 'Set up your profile to access the Aqua control room.'
              : 'Sign in to monitor and control your water pump.',
          style: manrope(
            11, color: const Color(0xFF7C8D8A),
          ),
        ),
        SizedBox(
          height: _register ? (mobile ? 23 : 25) : (mobile ? 29 : 39),
        ),
        if (_register) ...[
          _Field(
            label: 'Full name', 
            icon: 'user', 
            controller: _fullName, 
            hint: 'Enter your full name',
            height: fieldH,
            onSubmitted: _submit,
          ),
          SizedBox(height: gap),
        ],
        _Field(
          label: 'Email address', 
          icon: 'mail', 
          controller: _email, 
          hint: 'name@example.com',
          height: fieldH,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: _submit,
        ),
        SizedBox(height: gap),
        _Field(
          label: 'Password', 
          icon: 'lock', 
          controller: _password, 
          hint: _register ? 'Minimum 6 characters' : 'Enter your password',
          height: fieldH,
          obscure: true, 
          onSubmitted: _submit,
        ),
        if (_register) ...[
          SizedBox(height: gap),
          _Field(
            label: 'Confirm password', 
            icon: 'shield', 
            controller: _confirm, 
            hint: 'Repeat your password',
            height: fieldH, 
            onSubmitted: _submit,
          ),
          const SizedBox(height: 16),
          _TermsCheck(
            value: _accepted, 
            onChanged: (v) => setState(() => _accepted = v),
          ),
        ],
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 13),
          Text(_error,
            style: manrope(9, 
              w: FontWeight.w700, 
              color: const Color(0xFFB25F43)
            ),
          ),
        ],
        const SizedBox(height: 26),
        Tappable(
          onTap: _submit,
          semanticLabel: _register ? 'Create my account' : 'Enter control room',
          builder: (context, hover) => Lift(
            hover: hover, 
            child: Container(
              height: 59,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: lg(135, const [Color(0xFF123D3E), Color(0xFF09282B)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: rgba(10, 48, 50, .18), 
                    offset: const Offset(0, 15), 
                    blurRadius: 32
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _register ? 'CREATE MY ACCOUNT' : 'ENTER CONTROL ROOM',
                    style: manrope(10,
                      w: FontWeight.w800,
                      color: const Color(0xFFEAFFFB),
                      em: .12,
                    ),
                  ),
                  const AppIcon('arrow', size: 20, color: Color(0xFF66DDCD))
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon('shield', size: 16, color: Color(0xFF449C84)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _register
                    ? 'Passwords are not stored in this frontend prototype.'
                    : 'Frontend preview — use any password with 4+ characters.',
                textAlign: TextAlign.center,
                style: manrope(8, color: const Color(0xFF8A9996)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _AuthSwitch(register: _register, onTap: () => _setMode(!_register)),
      ],
    );
  }
}

class _Field extends StatefulWidget {
  final String label, icon, hint;
  final double height;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final VoidCallback onSubmitted;
  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.height = 57,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  State<_Field> createState() => __FieldState();
}

class __FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: manrope(9, w: FontWeight.w800, color: const Color(0xFF4B6360), em: .06),
        ),
        const SizedBox(height: 9),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            color: rgba(255, 255, 255, .72),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: f ? const Color(0xFF6CCFC1) : const Color(0xFFD1DCD7)),
            boxShadow: [
              BoxShadow(
                color: rgba(25, 57, 54, .04), 
                offset: const Offset(0, 8), 
                blurRadius: 24
              ),
              if (f) BoxShadow(color: rgba(79, 196, 180, .1), spreadRadius: 4),
            ],
          ),
          child: Row(
            children: [
              AppIcon(
                widget.icon,
                size: 18, color: f ? const Color(0xFF269B8B) : const Color(0xFF66807C),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  onSubmitted: (_) => widget.onSubmitted(),
                  cursorColor: const Color(0xFF269B8B),
                  style: manrope(12, w: FontWeight.w600, color: const Color(0xff173336)),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: manrope(12,
                      w: FontWeight.w500, color: const Color(0xFFA0AEAB),
                    )
                  ),
                )
              )
            ],
          ),
        )
      ],
    );
  }
}

class _TermsCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TermsCheck({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2F9E8E);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: value ? accent : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? accent : const Color(0xFF767676)),
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'I agree to the Terms of Service and Privacy Policy for this '
                'control system.',
                style: manrope(8, color: const Color(0xFF728582), height: 1.55),
              )
            )
          ],
        ),
      ),
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  final bool register;
  final VoidCallback onTap;
  const _AuthSwitch({
    required this.register,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: rgba(35, 75, 72, .1))),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            register ? 'Already have an account?' : 'New to MyShimizu Control?',
            style: manrope(9, color: const Color(0xFF7E908C)),
          ),
          Tappable(
            onTap: onTap,
            builder: (context, hover) {
              final color = hover ? const Color(0xFF15594F) : const Color(0xFF247F73);
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    register ? 'Sign in instead' : 'Create account',
                    style: manrope(9, w: FontWeight.w800, color: color),
                  ),
                  const SizedBox(width: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(hover ? 2 : 0, 0, 0),
                    child: AppIcon('arrow', size: 15, color: color),
                  )
                ],
              );
            }
          )
        ],
      ),
    );
  }
}