import 'package:flutter/material.dart';

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
}
