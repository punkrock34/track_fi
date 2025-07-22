import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../shared/utils/category_utils.dart';

class DefaultCategories {
  static Future<void> insert(Database db) async {
    final String now = DateTime.now().toIso8601String();
    final ThemeData fakeTheme = ThemeData();

    final List<Map<String, Object>> allCategories = <Map<String, Object>>[];

    for (final String type in <String>['income', 'expense', 'transfer']) {
      for (final String id in CategoryUtils.getCategoriesForType(type)) {
        final String name = CategoryUtils.getCategoryName(id);
        final String icon = CategoryUtils.getCategoryIcon(id).codePoint.toString();
        final String color = CategoryUtils.getCategoryColor(id, fakeTheme).value.toRadixString(16).padLeft(8, '0');

        allCategories.add(<String, Object>{
          'id': id,
          'name': name,
          'icon': icon,
          'color': '#$color',
          'type': type,
          'is_default': 1,
          'created_at': now,
        });
      }
    }

    for (final Map<String, Object> category in allCategories) {
      await db.insert('categories', category);
    }
  }
}
