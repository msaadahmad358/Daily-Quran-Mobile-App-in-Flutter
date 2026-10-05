import 'package:flutter/material.dart';

/// Indo-Pak mushaf style (same as Quran reader default).
class AppArabic {
  AppArabic._();

  static const String fontFamily = 'IndoPak';

  static TextStyle style({
    double fontSize = 22,
    double height = 1.75,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: height,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
