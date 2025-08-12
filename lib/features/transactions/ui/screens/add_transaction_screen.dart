import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../../../shared/widgets/accounts/account_selector.dart';
import '../../../../shared/widgets/accounts/transaction_type_toggle.dart';
import '../../../../shared/widgets/common/error_banner.dart';
import '../../../../shared/widgets/input/date/date_picker.dart';
import '../../../../shared/widgets/input/text/currency_input_field.dart';
import '../../../../shared/widgets/input/text/text_input_field_widget.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../models/add_transaction_state.dart';
import '../../providers/add_transaction_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/transaction_form_validators.dart';
import '../widgets/transaction_info_card.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.preselectedAccountId,
  });

  final String? preselectedAccountId;

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addTransactionProvider.notifier).reset(
        preselectedAccountId: widget.preselectedAccountId,
      );
      ref.read(accountsProvider.notifier).loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddTransactionState state = ref.watch(addTransactionProvider);
    final AddTransactionNotifier notifier = ref.read(addTransactionProvider.notifier);
    final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);
    final ThemeData theme = Theme.of(context);

    final String currentCurrency = () {
      final String? accountCurrency = CurrencyUtils.getCurrencyForAccount(
        state.accountId,
        accountsAsync.value,
      );
      
      if (accountCurrency != null) {
        return accountCurrency;
      }
      
      return ref.watch(baseCurrencyProvider).maybeWhen(
        data: (String baseCurrency) => baseCurrency,
        orElse: () => 'RON',
      );
    }();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: <Widget>[
          TextButton(
            onPressed: state.isValid && !state.isLoading ? _handleSave : null,
            child: state.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              if (state.errorMessage != null) ...<Widget>[
                ErrorBanner(message: state.errorMessage)
                  .animate(key: const ValueKey<String>('error-message'))
                  .shake(hz: 4, curve: Curves.easeInOut)
                  .fadeIn(),
                const Gap(DesignTokens.spacingMd),
              ],

              Text(
                'Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 50.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              AccountSelector(
                selectedAccountId: state.accountId,
                accounts: accountsAsync.value ?? <Account>[],
                onAccountChanged: notifier.updateAccountId,
                isLoading: accountsAsync.isLoading,
              ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              Text(
                'Transaction Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 150.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              TransactionTypeToggle(
                selectedType: state.type,
                onTypeChanged: notifier.updateType,
              ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              CurrencyInputField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                currency: currentCurrency,
                onChanged: notifier.updateAmount,
                required: true,
                validator: TransactionFormValidators.validateAmount,
              ).animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              DatePicker(
                selectedDate: state.transactionDate,
                onDateChanged: notifier.updateTransactionDate,
              ).animate().slideX(begin: 0.3, delay: 300.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              TextInputField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What was this transaction for?',
                onChanged: notifier.updateDescription,
                prefixIcon: Icons.description_outlined,
                required: true,
                validator: TransactionFormValidators.validateDescription,
              ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 400.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              CategorySelector(
                selectedCategoryId: state.categoryId,
                transactionType: state.type,
                onCategoryChanged: notifier.updateCategoryId,
              ).animate().slideX(begin: 0.3, delay: 450.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              Text(
                'Additional Details (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().slideX(begin: -0.3, delay: 500.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              TextInputField(
                controller: _referenceController,
                label: 'Reference',
                hint: 'Transaction reference or ID',
                onChanged: notifier.updateReference,
                prefixIcon: Icons.tag_outlined,
                validator: TransactionFormValidators.validateReference,
              ).animate().slideX(begin: 0.3, delay: 550.ms).fadeIn(),

              const Gap(DesignTokens.spacingXl),

              const TransactionInfoCard()
                .animate()
                .slideY(begin: 0.3, delay: 600.ms)
                .fadeIn(),

              const Gap(DesignTokens.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool success = await ref.read(addTransactionProvider.notifier).createTransaction();
    
    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const Gap(DesignTokens.spacingXs),
              const Text('Transaction created successfully!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      context.pop();
    }
  }
}
