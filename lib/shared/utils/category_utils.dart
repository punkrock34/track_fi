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
      // Income Categories
      case 'cat_income_salary':
        return Icons.work_rounded;
      case 'cat_income_freelance':
        return Icons.laptop_mac_rounded;
      case 'cat_income_business':
        return Icons.business_rounded;
      case 'cat_income_investment':
        return Icons.trending_up_rounded;
      case 'cat_income_rental':
        return Icons.home_work_rounded;
      case 'cat_income_pension':
        return Icons.elderly_rounded;
      case 'cat_income_bonus':
        return Icons.card_giftcard_rounded;
      case 'cat_income_refund':
        return Icons.money_rounded;
      case 'cat_income_gift':
        return Icons.redeem_rounded;
      case 'cat_income_other':
        return Icons.attach_money_rounded;

      // Expense Categories
      case 'cat_expense_groceries':
        return Icons.shopping_cart_rounded;
      case 'cat_expense_transport':
        return Icons.directions_car_rounded;
      case 'cat_expense_dining':
        return Icons.restaurant_rounded;
      case 'cat_expense_utilities':
        return Icons.flash_on_rounded;
      case 'cat_expense_rent':
        return Icons.home_rounded;
      case 'cat_expense_insurance':
        return Icons.security_rounded;
      case 'cat_expense_healthcare':
        return Icons.local_hospital_rounded;
      case 'cat_expense_entertainment':
        return Icons.movie_rounded;
      case 'cat_expense_shopping':
        return Icons.shopping_bag_rounded;
      case 'cat_expense_education':
        return Icons.school_rounded;
      case 'cat_expense_fitness':
        return Icons.fitness_center_rounded;
      case 'cat_expense_travel':
        return Icons.flight_rounded;
      case 'cat_expense_subscriptions':
        return Icons.subscriptions_rounded;
      case 'cat_expense_fuel':
        return Icons.local_gas_station_rounded;
      case 'cat_expense_phone':
        return Icons.phone_android_rounded;
      case 'cat_expense_internet':
        return Icons.wifi_rounded;
      case 'cat_expense_childcare':
        return Icons.child_care_rounded;
      case 'cat_expense_pet':
        return Icons.pets_rounded;
      case 'cat_expense_gifts':
        return Icons.card_giftcard_rounded;
      case 'cat_expense_charity':
        return Icons.favorite_rounded;
      case 'cat_expense_taxes':
        return Icons.receipt_long_rounded;
      case 'cat_expense_other':
        return Icons.more_horiz_rounded;

      // Transfer Categories
      case 'cat_transfer_internal':
        return Icons.swap_horiz_rounded;
        
      default:
        return Icons.category_rounded;
    }
  }

  static Color getCategoryColor(String categoryId, ThemeData theme) {
    switch (categoryId) {
      // Income Categories - Green shades for positive income
      case 'cat_income_salary':
        return const Color(0xFF4CAF50); // Material Green
      case 'cat_income_freelance':
        return const Color(0xFF66BB6A); // Light Green
      case 'cat_income_business':
        return const Color(0xFF2E7D32); // Dark Green
      case 'cat_income_investment':
        return const Color(0xFF388E3C); // Medium Green
      case 'cat_income_rental':
        return const Color(0xFF43A047); // Another Green
      case 'cat_income_pension':
        return const Color(0xFF689F38); // Light Olive Green
      case 'cat_income_bonus':
        return const Color(0xFF7CB342); // Yellow Green
      case 'cat_income_refund':
        return const Color(0xFF8BC34A); // Lime Green
      case 'cat_income_gift':
        return const Color(0xFF9CCC65); // Pale Green
      case 'cat_income_other':
        return const Color(0xFF66BB6A); // Light Green

      // Expense Categories - Various colors for different expense types
      case 'cat_expense_groceries':
        return const Color(0xFFFF9800); // Orange
      case 'cat_expense_transport':
        return const Color(0xFF2196F3); // Blue
      case 'cat_expense_dining':
        return const Color(0xFFE91E63); // Pink
      case 'cat_expense_utilities':
        return const Color(0xFFFFC107); // Amber
      case 'cat_expense_rent':
        return const Color(0xFF795548); // Brown
      case 'cat_expense_insurance':
        return const Color(0xFF607D8B); // Blue Grey
      case 'cat_expense_healthcare':
        return const Color(0xFFF44336); // Red
      case 'cat_expense_entertainment':
        return const Color(0xFF9C27B0); // Purple
      case 'cat_expense_shopping':
        return const Color(0xFFE91E63); // Pink
      case 'cat_expense_education':
        return const Color(0xFF3F51B5); // Indigo
      case 'cat_expense_fitness':
        return const Color(0xFF4CAF50); // Green
      case 'cat_expense_travel':
        return const Color(0xFF00BCD4); // Cyan
      case 'cat_expense_subscriptions':
        return const Color(0xFF9C27B0); // Purple
      case 'cat_expense_fuel':
        return const Color(0xFF795548); // Brown
      case 'cat_expense_phone':
        return const Color(0xFF009688); // Teal
      case 'cat_expense_internet':
        return const Color(0xFF2196F3); // Blue
      case 'cat_expense_childcare':
        return const Color(0xFFFFEB3B); // Yellow
      case 'cat_expense_pet':
        return const Color(0xFFFF5722); // Deep Orange
      case 'cat_expense_gifts':
        return const Color(0xFFE91E63); // Pink
      case 'cat_expense_charity':
        return const Color(0xFFF44336); // Red
      case 'cat_expense_taxes':
        return const Color(0xFF424242); // Dark Grey
      case 'cat_expense_other':
        return const Color(0xFF9E9E9E); // Grey

      // Transfer Categories
      case 'cat_transfer_internal':
        return const Color(0xFF673AB7); // Deep Purple
        
      default:
        return theme.colorScheme.primary;
    }
  }

  static String getCategoryType(String categoryId) {
    if (categoryId.startsWith('cat_income_')) {
      return 'income';
    } else if (categoryId.startsWith('cat_expense_')) {
      return 'expense';
    } else if (categoryId.startsWith('cat_transfer_')) {
      return 'transfer';
    }
    return 'other';
  }

  static List<String> getCategoriesForType(String type) {
    switch (type) {
      case 'income':
        return <String>[
          'cat_income_salary',
          'cat_income_freelance',
          'cat_income_business',
          'cat_income_investment',
          'cat_income_rental',
          'cat_income_pension',
          'cat_income_bonus',
          'cat_income_refund',
          'cat_income_gift',
          'cat_income_other',
        ];
      case 'expense':
        return <String>[
          'cat_expense_groceries',
          'cat_expense_transport',
          'cat_expense_dining',
          'cat_expense_utilities',
          'cat_expense_rent',
          'cat_expense_insurance',
          'cat_expense_healthcare',
          'cat_expense_entertainment',
          'cat_expense_shopping',
          'cat_expense_education',
          'cat_expense_fitness',
          'cat_expense_travel',
          'cat_expense_subscriptions',
          'cat_expense_fuel',
          'cat_expense_phone',
          'cat_expense_internet',
          'cat_expense_childcare',
          'cat_expense_pet',
          'cat_expense_gifts',
          'cat_expense_charity',
          'cat_expense_taxes',
          'cat_expense_other',
        ];
      case 'transfer':
        return <String>['cat_transfer_internal'];
      default:
        return <String>[];
    }
  }

  static bool isIncomeCategory(String categoryId) {
    return categoryId.startsWith('cat_income_');
  }

  static bool isExpenseCategory(String categoryId) {
    return categoryId.startsWith('cat_expense_');
  }

  static bool isTransferCategory(String categoryId) {
    return categoryId.startsWith('cat_transfer_');
  }

  static IconData resolveIcon(String codePoint) {
    return IconData(
      int.tryParse(codePoint) ?? Icons.category.codePoint,
      fontFamily: 'MaterialIcons',
    );
  }

  static Color resolveColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', ''), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

}
