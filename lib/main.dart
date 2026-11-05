import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myshimizu/core/theme.dart';
import 'package:myshimizu/providers/auth_provider.dart';
import 'package:myshimizu/providers/storage_provider.dart';
import 'package:myshimizu/screens/app_shell.dart';
import 'package:myshimizu/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: DevicePreview(
        builder: (context) => MyShimizuApp(),
      ),
    )
  );
}

class MyShimizuApp extends StatelessWidget {
  const MyShimizuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authProvider) != null;
    return signedIn ? const AppShell() : const LoginScreen();
  }
}