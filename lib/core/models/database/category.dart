import 'package:flutter/material.dart';
import '../../../shared/utils/category_utils.dart';

class Category {

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdAt,
  });

  factory Category.fromDb(Map<String, dynamic> data) {
    return Category(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      icon: CategoryUtils.resolveIcon(data['icon'] as String),
      color: CategoryUtils.resolveColor(data['color'] as String),
      isDefault: (data['is_default'] as int) == 1,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
  final String id;
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  Map<String, dynamic> toDb() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'icon': icon.codePoint.toString(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isTransfer => type == 'transfer';
}
