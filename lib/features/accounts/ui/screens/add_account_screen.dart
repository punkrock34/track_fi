import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/input/currency_input_field.dart';
import '../../../../shared/widgets/input/dropdown_field.dart';
import '../../../../shared/widgets/input/text_input_field_widget.dart';
import '../../models/add_account_state.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/add_account_provider.dart';
import '../widgets/account_type_selector.dart';
import '../widgets/sort_code_formatter.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key, this.accountId});

  final String? accountId;

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _sortCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AddAccountNotifier notifier = ref.read(addAccountProvider.notifier);

      if (widget.accountId != null) {
        final Account? account = ref.read(accountProvider(widget.accountId!)).value;
        if (account != null) {
          notifier.loadExistingAccount(account);
        } else {
          notifier.reset();
        }
      } else {
        notifier.reset();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _sortCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddAccountState state = ref.watch(addAccountProvider);
    final AddAccountNotifier notifier = ref.read(addAccountProvider.notifier);
    final ThemeData theme = Theme.of(context);

    _nameController.text = state.name;
    _balanceController.text = state.balance.toStringAsFixed(2);
    _bankNameController.text = state.bankName ?? '';
    _accountNumberController.text = state.accountNumber ?? '';
    _sortCodeController.text = state.sortCode ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
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

              // Section: Account Details
              Text(
                'Account Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ).animate().slideX(begin: -0.3, delay: 50.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              TextInputField(
                controller: _nameController,
                label: 'Account Name',
                hint: 'e.g., Main Current Account',
                required: true,
                onChanged: notifier.updateName,
                prefixIcon: Icons.account_balance_outlined,
                validator: (String? value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Account name is required';
                  }
                  if (value!.trim().length < 2) {
                    return 'Account name must be at least 2 characters';
                  }
                  return null;
                },
              ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              AccountTypeSelector(
                selectedType: state.type,
                onTypeChanged: notifier.updateType,
              ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: CurrencyInputField(
                      controller: _balanceController,
                      label: 'Current Balance',
                      hint: '0.00',
                      currency: state.currency,
                      onChanged: (double value) => notifier.updateBalance(value),
                      required: true,
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    child: DropdownField<String>(
                      value: state.currency,
                      label: 'Currency',
                      items: const <String>['GBP', 'USD', 'EUR'],
                      onChanged: notifier.updateCurrency,
                      itemBuilder: (String currency) => Row(
                        children: <Widget>[
                          Text(
                            _getCurrencySymbol(currency),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(DesignTokens.spacingXs),
                          Text(currency),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),

              // Section: Bank Information
              Text(
                'Bank Information (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().slideX(begin: -0.3, delay: 250.ms).fadeIn(),
              
              Text(
                'Add bank details for better organization',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ).animate().slideX(begin: -0.3, delay: 300.ms).fadeIn(),
              
              const Gap(DesignTokens.spacingSm),

              TextInputField(
                controller: _bankNameController,
                label: 'Bank Name',
                hint: 'e.g., Barclays, HSBC, Nationwide',
                onChanged: notifier.updateBankName,
                prefixIcon: Icons.business_outlined,
              ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),

              const Gap(DesignTokens.spacingMd),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextInputField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      hint: '12345678',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: notifier.updateAccountNumber,
                      prefixIcon: Icons.numbers_outlined,
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    child: TextInputField(
                      controller: _sortCodeController,
                      label: 'Sort Code',
                      hint: '12-34-56',
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                        SortCodeFormatter(),
                      ],
                                            onChanged: notifier.updateSortCode,
                      prefixIcon: Icons.tag_outlined,
                    ),
                  ),
                ],
              ).animate().slideX(begin: 0.3, delay: 400.ms).fadeIn(),

              const Gap(DesignTokens.spacingXl),

              // Info box
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Expanded(
                      child: Text(
                        'Bank details are optional and only used for organizing your accounts. '
                        'All data is securely stored on your device.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 450.ms).fadeIn(),

              const Gap(DesignTokens.spacingLg),
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

    final AddAccountState state = ref.read(addAccountProvider);
    final bool success = await ref.read(addAccountProvider.notifier).saveAccount();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isEditMode ? 'Account updated successfully!' : 'Account created successfully!',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      context.replaceNamed('accounts');
    }
  }


  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '';
    }
  }
}
