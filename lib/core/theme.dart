import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//SKALA TEXT (KALO MAU LEBIH KEBACA DI ANDROID COBA 1.1-1.2)
const double kTextScale = 1.0;

double fs(double v) => v * kTextScale;

Color rgba(
  int r,
  int g,
  int b,
  [double a = 1]) => Color.fromRGBO(r, g, b, a);

//TEMA WARNA APLIKASI
class C {
  static const pageBg = Color(0xFFE8EEEB);
  static const loginPanelBg = Color(0xFFEDF2EF);
  static const sidebarBg = Color(0xFF071416);
  static const ink = Color(0xFF142326);
  static const kicker = Color(0xFF748784);
  static const teal = Color(0xFF42B8AA);
}

//GRADASI MIRING
LinearGradient lg(double deg, List<Color> colors, [List<double>? stops]) {
  final r = deg * math.pi / 180;
  return LinearGradient(
    begin: Alignment(-math.sin(r), math.cos(r)),
    end: Alignment(math.sin(r), -math.cos(r)),
    colors: colors,
    stops: stops,
  );
}

//SUDUT KOTAK ASIMETRIS
BorderRadius blob(double r, double bl) => BorderRadius.only(
      topLeft: Radius.circular(r),
      topRight: Radius.circular(r),
      bottomRight: Radius.circular(r),
      bottomLeft: Radius.circular(bl),
    );

//UNTUK JUDUL BESAR DAN ANGKA METRIK
TextStyle sora(
  double size, {
    FontWeight w = FontWeight.w600,
    Color color = C.ink,
    double em = 0,
    double? height,
  }) =>
      GoogleFonts.sora(
        fontSize: fs(size),
        fontWeight: w,
        color: color,
        letterSpacing: em * fs(size),
        height: height,
      );

//UNTUK LABEL KECIL
TextStyle manrope(
  double size, {
    FontWeight w = FontWeight.w400,
    Color color = C.ink,
    double em = 0,
    double? height,
  }) =>
      GoogleFonts.manrope(
        fontSize: fs(size),
        fontWeight: w,
        color: color,
        letterSpacing: em * fs(size),
        height: height,
      );

enum Screen { mobile, tablet, dekstop }

//STATUS LAYAR
Screen screenOf(double width) {
  if (width <= 700) return Screen.mobile;
  if (width <= 1050) return Screen.tablet;
  return Screen.dekstop;
}

//UKURAN MEMBESAR/MENGECIL SECARA FLEKSIBEL
double clamPx(double lo, double v, double hi) => 
    math.min(math.max(v, lo), hi); 