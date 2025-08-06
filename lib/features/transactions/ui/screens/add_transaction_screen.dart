import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/date_utils.dart';
import '../../../../shared/widgets/input/currency_input_field.dart';
import '../../../../shared/widgets/input/text_input_field_widget.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../models/add_transaction_state.dart';
import '../../providers/add_transaction_provider.dart';
import '../widgets/account_selector.dart';
import '../widgets/category_selector.dart';
import '../widgets/transaction_type_toggle.dart';

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
              // Error message
              if (state.errorMessage != null) ...<Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignTokens.spacingSm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const Gap(DesignTokens.spacingXs),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(hz: 4, curve: Curves.easeInOut).fadeIn(),
                const Gap(DesignTokens.spacingMd),
              ],

              // Section: Basic Information
              Text(
                'Basic Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 50.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              // Transaction Type
              TransactionTypeToggle(
                selectedType: state.type,
                onTypeChanged: notifier.updateType,
              ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Amount and Date Row
              CurrencyInputField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                currency: _getSelectedAccountCurrency(accountsAsync.value, state.accountId),
                onChanged: notifier.updateAmount,
                required: true,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                  return 'Amount is required';
                  }
                  final double? amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) {
                  return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
              ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              _buildDateField(theme, state, notifier)
                .animate()
                .slideX(begin: 0.3, delay: 150.ms)
                .fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Description Field
              TextInputField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What was this transaction for?',
                onChanged: notifier.updateDescription,
                prefixIcon: Icons.description_outlined,
                required: true,
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Description is required';
                  }
                  if (value!.trim().length < 3) {
                    return 'Description must be at least 3 characters';
                  }
                  return null;
                },
              ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              // Section: Account & Category
              Text(
                'Account & Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 250.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              // Account Selection
              AccountSelector(
                selectedAccountId: state.accountId,
                accounts: accountsAsync.value ?? <Account>[],
                onAccountChanged: notifier.updateAccountId,
                isLoading: accountsAsync.isLoading,
              ).animate().slideX(begin: 0.3, delay: 300.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Category Selection
              CategorySelector(
                selectedCategoryId: state.categoryId,
                transactionType: state.type,
                onCategoryChanged: notifier.updateCategoryId,
              ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              // Section: Additional Details (Optional)
              Text(
                'Additional Details (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().slideX(begin: -0.3, delay: 400.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              // Reference Field
              TextInputField(
                controller: _referenceController,
                label: 'Reference',
                hint: 'Transaction reference or ID',
                onChanged: notifier.updateReference,
                prefixIcon: Icons.tag_outlined,
              ).animate().slideX(begin: 0.3, delay: 450.ms).fadeIn(),

              const Gap(DesignTokens.spacingXl),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      theme.colorScheme.primaryContainer.withOpacity(0.1),
                      theme.colorScheme.secondaryContainer.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const Gap(DesignTokens.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Transaction Preview',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(DesignTokens.spacing2xs),
                          Text(
                            'This will be added to your selected account and update the balance accordingly.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),

              const Gap(DesignTokens.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    ThemeData theme,
    AddTransactionState state,
    AddTransactionNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Date',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        InkWell(
          onTap: () => _selectDate(notifier),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: state.transactionDate != null
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: state.transactionDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: state.transactionDate != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const Gap(DesignTokens.spacingXs),
                Expanded(
                  child: Text(
                    state.transactionDate != null
                        ? DateUtils.formatDate(state.transactionDate!)
                        : 'Select date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: state.transactionDate != null ? FontWeight.w500 : null,
                      color: state.transactionDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(AddTransactionNotifier notifier) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      notifier.updateTransactionDate(selectedDate);
    }
  }

  String _getSelectedAccountCurrency(List<Account>? accounts, String? accountId) {
    if (accounts == null || accountId == null) {
      return 'GBP';
    }
    
    final Account? account = accounts.cast<Account?>().firstWhere(
      (Account? a) => a?.id == accountId,
      orElse: () => null,
    );
    
    return account?.currency ?? 'GBP';
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
