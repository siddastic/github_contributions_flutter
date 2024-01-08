import 'package:flutter/material.dart';
import 'package:github_contributions/models/chart_theme.dart';

class Contribution {
  final DateTime date;
  final int count;
  final Color color;
  final String intensity;

  const Contribution({
    required this.date,
    required this.count,
    required this.color,
    required this.intensity,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      date: DateTime.parse(json['date']),
      count: json['count'],
      intensity: json['intensity'],
      color: Color(
          int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000),
    );
  }

  Color getColorForChartTheme(ChartTheme theme) {
    switch (intensity) {
      case '0':
        return theme.grade0;
      case '1':
        return theme.grade1;
      case '2':
        return theme.grade2;
      case '3':
        return theme.grade3;
      case '4':
        return theme.grade4;
      default:
        return theme.grade0;
    }
  }
}
