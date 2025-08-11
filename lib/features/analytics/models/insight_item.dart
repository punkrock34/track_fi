import 'package:flutter/material.dart';

class InsightItem {
  InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.value,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? value;
}
