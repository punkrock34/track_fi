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

              // Transaction Type
              TransactionTypeToggle(
                selectedType: state.type,
                onTypeChanged: notifier.updateType,
              ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Account Selection
              AccountSelector(
                selectedAccountId: state.accountId,
                accounts: accountsAsync.value ?? <Account>[],
                onAccountChanged: notifier.updateAccountId,
                isLoading: accountsAsync.isLoading,
              ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Amount Field (Full Width)
              CurrencyInputField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                currency: _getSelectedAccountCurrency(accountsAsync.value, state.accountId),
                onChanged: notifier.updateAmount,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return 'Amount is required';
                  }
                  final double? amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Date Field (Full Width)
              _buildDateField(theme, state, notifier)
                  .animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Description Field
              TextInputField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'e.g., Grocery shopping, Salary payment (optional)',
                onChanged: notifier.updateDescription,
                prefixIcon: Icons.description_outlined,
              ).animate().slideX(begin: 0.3, delay: 300.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Reference Field
              TextInputField(
                controller: _referenceController,
                label: 'Reference',
                hint: 'Transaction reference or ID (optional)',
                onChanged: notifier.updateReference,
                prefixIcon: Icons.tag_outlined,
              ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              // Category Selection
              CategorySelector(
                selectedCategoryId: state.categoryId,
                transactionType: state.type,
                onCategoryChanged: notifier.updateCategoryId,
              ).animate().slideX(begin: 0.3, delay: 400.ms).fadeIn(),

              const Gap(DesignTokens.spacingXl),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Expanded(
                      child: Text(
                        'This transaction will be added to your selected account. '
                        'You can edit or delete it later if needed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 450.ms).fadeIn(),
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
        Text(
          'Date',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
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
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const Gap(DesignTokens.spacingSm),
                Expanded(
                  child: Text(
                    state.transactionDate != null
                        ? DateUtils.formatDate(state.transactionDate!)
                        : 'Select date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: state.transactionDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
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
          content: const Text('Transaction created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      context.pop();
    }
  }
}
