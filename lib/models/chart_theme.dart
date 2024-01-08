import 'package:flutter/material.dart';

class ChartTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color meta;
  final Color grade0;
  final Color grade1;
  final Color grade2;
  final Color grade3;
  final Color grade4;

  const ChartTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.meta,
    required this.grade0,
    required this.grade1,
    required this.grade2,
    required this.grade3,
    required this.grade4,
  });
}

class ChartThemes {
  static ChartTheme get dracula {
    return const ChartTheme(
      backgroundColor: Color(0xff181818),
      textColor: Color(0xfff8f8f2),
      meta: Color(0xff666666),
      grade0: Color(0xff282a36),
      grade1: Color(0xff44475a),
      grade2: Color(0xff6272a4),
      grade3: Color(0xffbd93f9),
      grade4: Color(0xffff79c6),
    );
  }
}
