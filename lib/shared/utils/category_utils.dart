import 'package:flutter/material.dart';

class CategoryUtils {
  CategoryUtils._();

  /// Get category name from ID
  static String getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'cat_income_salary':
        return 'Salary';
      case 'cat_expense_groceries':
        return 'Groceries';
      case 'cat_expense_transport':
        return 'Transport';
      case 'cat_expense_dining':
        return 'Dining Out';
      case 'cat_transfer_internal':
        return 'Transfer';
      default:
        return 'Other';
    }
  }

  /// Get category icon from ID
  static IconData getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_income_salary':
        return Icons.work_rounded;
      case 'cat_expense_groceries':
        return Icons.shopping_cart_rounded;
      case 'cat_expense_transport':
        return Icons.directions_car_rounded;
      case 'cat_expense_dining':
        return Icons.restaurant_rounded;
      case 'cat_transfer_internal':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get category color from ID
  static Color getCategoryColor(String categoryId, ThemeData theme) {
    switch (categoryId) {
      case 'cat_income_salary':
        return Colors.green;
      case 'cat_expense_groceries':
        return Colors.orange;
      case 'cat_expense_transport':
        return Colors.blue;
      case 'cat_expense_dining':
        return Colors.red;
      case 'cat_transfer_internal':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}
