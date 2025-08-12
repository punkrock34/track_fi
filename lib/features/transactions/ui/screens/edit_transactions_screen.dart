import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../../../shared/utils/ui_utils.dart';
import '../../../../shared/widgets/accounts/account_selector.dart';
import '../../../../shared/widgets/accounts/transaction_type_toggle.dart';
import '../../../../shared/widgets/common/error_banner.dart';
import '../../../../shared/widgets/common/unsaved_changes_banner.dart';
import '../../../../shared/widgets/input/date/date_picker.dart';
import '../../../../shared/widgets/input/text/currency_input_field.dart';
import '../../../../shared/widgets/input/text/text_input_field_widget.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../models/edit_transaction_state.dart';
import '../../providers/edit_transaction_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/transaction_form_validators.dart';
import '../widgets/transaction_info_card.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _updateControllers(EditTransactionState state) {
    final String amountString = state.effectiveAmount.toStringAsFixed(2);
    if (_amountController.text != amountString) {
      _amountController.text = amountString;
    }
    final String desc = state.effectiveDescription;
    if (_descriptionController.text != desc) {
      _descriptionController.text = desc;
    }
    final String ref = state.effectiveReference ?? '';
    if (_referenceController.text != ref) {
      _referenceController.text = ref;
    }
  }

  @override
  Widget build(BuildContext context) {
    final EditTransactionState? state =
        ref.watch(editTransactionProvider(widget.transactionId));
    final EditTransactionNotifier notifier =
        ref.read(editTransactionProvider(widget.transactionId).notifier);

    final AsyncValue<List<Account>> accountsAsync =
        ref.watch(accountsProvider);

    final ThemeData theme = Theme.of(context);

    final String currentCurrency = () {
      final String? accountCurrency = CurrencyUtils.getCurrencyForAccount(
        state?.effectiveAccountId,
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


    if (state == null ||
        (state.originalTransaction == null && state.isLoading)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.originalTransaction == null && state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
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
                onPressed: () =>
                    notifier.loadTransaction(widget.transactionId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    _updateControllers(state);

    return PopScope(
      canPop: !state.hasChanges,
      onPopInvoked: (bool didPop) async {
        if (!didPop && state.hasChanges) {
          final bool? discard = await _showDiscardChangesDialog();
          if ((discard ?? false) && context.mounted) {
            notifier.discardChanges();
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
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
                if (state.hasChanges) ...<Widget>[
                  UnsavedChangesBanner(
                    visible: state.hasChanges,
                  ).animate(key: const ValueKey<String>('changes-indicator')).slideY(begin: -0.3).fadeIn(),
                ],

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
                )
                    .animate(
                        key: const ValueKey<String>('account-title'))
                    .slideX(begin: -0.3, delay: 50.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                AccountSelector(
                  selectedAccountId: state.effectiveAccountId,
                  accounts: accountsAsync.value ?? <Account>[],
                  onAccountChanged: notifier.updateAccountId,
                  isLoading: accountsAsync.isLoading,
                )
                    .animate(
                        key: const ValueKey<String>('account-selector'))
                    .slideX(begin: 0.3, delay: 100.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingLg),

                Text(
                  'Transaction Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('basic-info-title'))
                    .slideX(begin: -0.3, delay: 150.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                TransactionTypeToggle(
                  selectedType: state.effectiveType,
                  onTypeChanged: notifier.updateType,
                )
                    .animate(key: const ValueKey<String>('type-toggle'))
                    .slideX(begin: 0.3, delay: 200.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                CurrencyInputField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  currency: currentCurrency,
                  onChanged: notifier.updateAmount,
                  required: true,
                  validator: TransactionFormValidators.validateAmount,
                )
                    .animate(key: const ValueKey<String>('amount-field'))
                    .slideX(begin: 0.3, delay: 250.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                DatePicker(
                  selectedDate: state.effectiveDate,
                  onDateChanged: notifier.updateTransactionDate,
                )
                    .animate(key: const ValueKey<String>('date-field'))
                    .slideX(begin: 0.3, delay: 300.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                TextInputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What was this transaction for?',
                  onChanged: notifier.updateDescription,
                  prefixIcon: Icons.description_outlined,
                  required: true,
                  validator: TransactionFormValidators.validateDescription,
                )
                    .animate(
                        key: const ValueKey<String>('description-field'))
                    .slideX(begin: 0.3, delay: 350.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingLg),

                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('category-title'))
                    .slideX(begin: -0.3, delay: 400.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                CategorySelector(
                  selectedCategoryId: state.effectiveCategoryId,
                  transactionType: state.effectiveType,
                  onCategoryChanged: notifier.updateCategoryId,
                )
                    .animate(
                        key: const ValueKey<String>('category-selector'))
                    .slideX(begin: 0.3, delay: 450.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingLg),

                Text(
                  'Additional Details (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('additional-title'))
                    .slideX(begin: -0.3, delay: 500.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                TextInputField(
                  controller: _referenceController,
                  label: 'Reference',
                  hint: 'Transaction reference or ID',
                  onChanged: notifier.updateReference,
                  prefixIcon: Icons.tag_outlined,
                  validator: TransactionFormValidators.validateReference,
                )
                    .animate(
                        key: const ValueKey<String>('reference-field'))
                    .slideX(begin: 0.3, delay: 550.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingXl),

                TransactionInfoCard(
                  isEdit: true,
                  originalDate: state.originalTransaction?.createdAt,
                )
                    .animate(key: const ValueKey<String>('info-card'))
                    .slideY(begin: 0.3, delay: 600.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingXl),
              ],
            ),
          ),
        ),
        floatingActionButton: state.hasChanges
            ? FloatingActionButton.extended(
                onPressed: state.isValid && !state.isLoading
                    ? _handleSave
                    : null,
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
                backgroundColor:
                    state.isValid && !state.isLoading
                        ? null
                        : theme.colorScheme.surfaceVariant,
                foregroundColor:
                    state.isValid && !state.isLoading
                        ? null
                        : theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.38),
              )
                .animate(key: const ValueKey<String>('save-fab'))
                .slideY(begin: 1)
                .fadeIn(duration:
                    const Duration(milliseconds: 200))
            : null,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final bool success = await ref
        .read(editTransactionProvider(widget.transactionId).notifier)
        .saveChanges();
    if (!mounted) {
      return;
    }
    if (success) {
      UiUtils.showSuccess(context, 'Transaction updated successfully!');
      context.pop();
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return UiUtils.showConfirmationDialog(
      context,
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      isDestructive: true,
    );
  }
}
