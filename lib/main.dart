import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myshimizu/core/app_state.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/screens/app_shell.dart';
import 'package:myshimizu/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();

  runApp(
    DevicePreview(
      builder: (context) => MyShimizuApp(state: state)
    )
  );
}

class MyShimizuApp extends StatelessWidget {
  final AppState state;
  const MyShimizuApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'MyShimizu Control System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: C.pageBg,
          colorScheme: ColorScheme.fromSeed(seedColor: C.teal),
          textTheme: GoogleFonts.manropeTextTheme(),
          splashFactory: NoSplash.splashFactory,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), 
          child: Material(
            type: MaterialType.transparency,
            child: DefaultTextStyle(
              style: manrope(12, color: C.ink), 
              child: child!,
            ),
          )
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final signedIn = AppScope.of(context).user != null;

    return signedIn ? const AppShell() : const LoginScreen();
  }
}