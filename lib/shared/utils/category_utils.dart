import 'package:flutter/material.dart';

class CategoryUtils {
  CategoryUtils._();

  static String getCategoryName(String categoryId) {
    switch (categoryId) {
      // Income Categories
      case 'cat_income_salary':
        return 'Salary';
      case 'cat_income_freelance':
        return 'Freelance';
      case 'cat_income_business':
        return 'Business';
      case 'cat_income_investment':
        return 'Investment';
      case 'cat_income_rental':
        return 'Rental Income';
      case 'cat_income_pension':
        return 'Pension';
      case 'cat_income_bonus':
        return 'Bonus';
      case 'cat_income_refund':
        return 'Refund';
      case 'cat_income_gift':
        return 'Gift';
      case 'cat_income_other':
        return 'Other Income';

      // Expense Categories
      case 'cat_expense_groceries':
        return 'Groceries';
      case 'cat_expense_transport':
        return 'Transport';
      case 'cat_expense_dining':
        return 'Dining Out';
      case 'cat_expense_utilities':
        return 'Utilities';
      case 'cat_expense_rent':
        return 'Rent/Mortgage';
      case 'cat_expense_insurance':
        return 'Insurance';
      case 'cat_expense_healthcare':
        return 'Healthcare';
      case 'cat_expense_entertainment':
        return 'Entertainment';
      case 'cat_expense_shopping':
        return 'Shopping';
      case 'cat_expense_education':
        return 'Education';
      case 'cat_expense_fitness':
        return 'Fitness & Gym';
      case 'cat_expense_travel':
        return 'Travel';
      case 'cat_expense_subscriptions':
        return 'Subscriptions';
      case 'cat_expense_fuel':
        return 'Fuel';
      case 'cat_expense_phone':
        return 'Phone Bill';
      case 'cat_expense_internet':
        return 'Internet';
      case 'cat_expense_childcare':
        return 'Childcare';
      case 'cat_expense_pet':
        return 'Pet Care';
      case 'cat_expense_gifts':
        return 'Gifts';
      case 'cat_expense_charity':
        return 'Charity';
      case 'cat_expense_taxes':
        return 'Taxes';
      case 'cat_expense_other':
        return 'Other Expenses';

      // Transfer Categories
      case 'cat_transfer_internal':
        return 'Transfer';
        
      default:
        return 'Other';
    }
  }

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
