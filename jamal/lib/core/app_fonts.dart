import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_session.dart';

class AppFonts {
  static const List<String> _fallbackFonts = [
    'Noto Sans',
    'Noto Sans Arabic',
    'Segoe UI',
    'Arial',
  ];

  static TextStyle plusJakartaSans({
    TextStyle? textStyle,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
  }) {
    final lang = UserSession().languageNotifier.value.languageCode;
    TextStyle style;

    if (lang == 'ar') {
      style = GoogleFonts.notoNaskhArabic(
        textStyle: textStyle,
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
      );
    } else if (lang == 'ru') {
      style = GoogleFonts.notoSans(
        textStyle: textStyle,
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
      );
    } else {
      style = GoogleFonts.plusJakartaSans(
        textStyle: textStyle,
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    final fallback = <String>[
      ...(style.fontFamilyFallback ?? const <String>[]),
      ..._fallbackFonts,
    ];
    return style.copyWith(fontFamilyFallback: fallback);
  }
}
