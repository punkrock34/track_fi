import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/ui_utils.dart';
import '../../../../shared/widgets/input/currency_input_field.dart';
import '../../../../shared/widgets/input/dropdown_field.dart';
import '../../../../shared/widgets/input/text_input_field_widget.dart';
import '../../models/edit_account_state.dart';
import '../../providers/edit_account_provider.dart';
import '../widgets/account_type_selector.dart';
import '../widgets/sort_code_formatter.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
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
      ref.read(editAccountProvider.notifier).loadAccount(widget.accountId);
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

  void _updateControllers(EditAccountState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
    }
    if (_balanceController.text != state.balance.toStringAsFixed(2)) {
      _balanceController.text = state.balance.toStringAsFixed(2);
    }
    if (_bankNameController.text != (state.bankName ?? '')) {
      _bankNameController.text = state.bankName ?? '';
    }
    if (_accountNumberController.text != (state.accountNumber ?? '')) {
      _accountNumberController.text = state.accountNumber ?? '';
    }
    if (_sortCodeController.text != (state.sortCode ?? '')) {
      _sortCodeController.text = state.sortCode ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final EditAccountState state = ref.watch(editAccountProvider);
    final EditAccountNotifier notifier = ref.read(editAccountProvider.notifier);
    final ThemeData theme = Theme.of(context);

    // Update controllers when state changes
    _updateControllers(state);

    // Show loading state
    if (state.originalAccount == null && state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Account'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (state.originalAccount == null && state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Account'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const Gap(DesignTokens.spacingMd),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Gap(DesignTokens.spacingLg),
              ElevatedButton.icon(
                onPressed: () => notifier.loadAccount(widget.accountId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: !state.hasChanges,
      onPopInvoked: (bool didPop) async {
        if (!didPop && state.hasChanges) {
          final bool? shouldDiscard = await _showDiscardChangesDialog();
          if ((shouldDiscard ?? false) && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Account'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Changes indicator
                if (state.hasChanges) ...<Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.spacingSm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const Gap(DesignTokens.spacingXs),
                        const Text('You have unsaved changes'),
                      ],
                    ),
                  ).animate().slideY(begin: -0.3).fadeIn(),
                  const Gap(DesignTokens.spacingMd),
                ],

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

                // Account Details Section
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
                        onChanged: notifier.updateBalance,
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

                // Bank Information Section
                Text(
                  'Bank Information (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ).animate().slideX(begin: -0.3, delay: 250.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingSm),

                TextInputField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  hint: 'e.g., Barclays, HSBC, Nationwide',
                  onChanged: notifier.updateBankName,
                  prefixIcon: Icons.business_outlined,
                ).animate().slideX(begin: 0.3, delay: 300.ms).fadeIn(),

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
                ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Account Status Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Account Status',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(DesignTokens.spacingSm),
                        SwitchListTile(
                          title: Text(state.isActive ? 'Active' : 'Inactive'),
                          subtitle: Text(
                            state.isActive 
                              ? 'Account is active and visible in lists'
                              : 'Account is inactive and hidden from most views',
                          ),
                          value: state.isActive,
                          onChanged: notifier.updateIsActive,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),

                const Gap(DesignTokens.spacingXl),
              ],
            ),
          ),
        ),
        floatingActionButton: state.hasChanges 
            ? FloatingActionButton.extended(
                onPressed: state.isValid && !state.isLoading ? _handleSave : null,
                icon: state.isLoading 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Changes'),
                backgroundColor: state.isValid && !state.isLoading 
                    ? null 
                    : theme.colorScheme.surfaceVariant,
                foregroundColor: state.isValid && !state.isLoading 
                    ? null 
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.38),
              ).animate()
               .slideY(begin: 1)
               .fadeIn(duration: const Duration(milliseconds: 200))
            : null,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool success = await ref.read(editAccountProvider.notifier).saveChanges();

    if (!mounted) {
      return;
    }

    if (success) {
      UiUtils.showSuccess(context, 'Account updated successfully!');
      context.pop();
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return UiUtils.showConfirmationDialog(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      isDestructive: true,
    );
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
