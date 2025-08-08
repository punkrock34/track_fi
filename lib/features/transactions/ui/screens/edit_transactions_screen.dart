import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../../../shared/utils/date_utils.dart';
import '../../../../shared/utils/ui_utils.dart';
import '../../../../shared/widgets/accounts/account_selector.dart';
import '../../../../shared/widgets/accounts/transaction_type_toggle.dart';
import '../../../../shared/widgets/common/error_banner.dart';
import '../../../../shared/widgets/common/unsaved_changes_banner.dart';
import '../../../../shared/widgets/input/text/currency_input_field.dart';
import '../../../../shared/widgets/input/text/text_input_field_widget.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../models/edit_transaction_state.dart';
import '../../providers/edit_transaction_provider.dart';
import '../widgets/category_selector.dart';

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

    // Loading or not yet loaded
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

    // Error state if we failed to load
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

    // Populate text controllers with the current state
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
                // Unsaved changes banner
                if (state.hasChanges) ...<Widget>[
                  UnsavedChangesBanner(
                    visible: state.hasChanges,
                  ).animate(key: const ValueKey<String>('changes-indicator')).slideY(begin: -0.3).fadeIn(),
                ],

                // Error Message
                if (state.errorMessage != null) ...<Widget>[
                  ErrorBanner(message: state.errorMessage)
                    .animate(key: const ValueKey<String>('error-message'))
                    .shake(hz: 4, curve: Curves.easeInOut)
                    .fadeIn(),
                  const Gap(DesignTokens.spacingMd),
                ],

                // Basic Information header
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('basic-info-title'))
                    .slideX(begin: -0.3, delay: 50.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                // Type toggle
                TransactionTypeToggle(
                  selectedType: state.effectiveType,
                  onTypeChanged: notifier.updateType,
                )
                    .animate(key: const ValueKey<String>('type-toggle'))
                    .slideX(begin: 0.3, delay: 100.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                // Amount field
                CurrencyInputField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  currency: CurrencyUtils.getCurrencyForAccount(
                    state.effectiveAccountId,
                    accountsAsync.value,
                  ),
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
                )
                    .animate(key: const ValueKey<String>('amount-field'))
                    .slideX(begin: 0.3, delay: 150.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                // Date field
                _buildDateField(theme, state, notifier)
                    .animate(key: const ValueKey<String>('date-field'))
                    .slideX(begin: 0.3, delay: 200.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                // Description field
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
                )
                    .animate(
                        key: const ValueKey<String>('description-field'))
                    .slideX(begin: 0.3, delay: 250.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Account & Category header
                Text(
                  'Account & Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('account-category-title'))
                    .slideX(begin: -0.3, delay: 300.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                // Account selector
                AccountSelector(
                  selectedAccountId: state.effectiveAccountId,
                  accounts: accountsAsync.value ?? <Account>[],
                  onAccountChanged: notifier.updateAccountId,
                  isLoading: accountsAsync.isLoading,
                )
                    .animate(
                        key: const ValueKey<String>('account-selector'))
                    .slideX(begin: 0.3, delay: 350.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingMd),

                // Category selector
                CategorySelector(
                  selectedCategoryId: state.effectiveCategoryId,
                  transactionType: state.effectiveType,
                  onCategoryChanged: notifier.updateCategoryId,
                )
                    .animate(
                        key: const ValueKey<String>('category-selector'))
                    .slideX(begin: 0.3, delay: 400.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Additional Details header
                Text(
                  'Additional Details (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                )
                    .animate(
                        key: const ValueKey<String>('additional-title'))
                    .slideX(begin: -0.3, delay: 450.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingSm),

                // Reference field
                TextInputField(
                  controller: _referenceController,
                  label: 'Reference',
                  hint: 'Transaction reference or ID',
                  onChanged: notifier.updateReference,
                  prefixIcon: Icons.tag_outlined,
                )
                    .animate(
                        key: const ValueKey<String>('reference-field'))
                    .slideX(begin: 0.3, delay: 500.ms)
                    .fadeIn(),

                const Gap(DesignTokens.spacingXl),

                // Info card
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
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusLg),
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
                          borderRadius: BorderRadius.circular(
                              DesignTokens.radiusFull),
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
                              'Transaction Update',
                              style:
                                  theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(DesignTokens.spacing2xs),
                            Text(
                              'Changes will update your account balance accordingly.\nOriginal: ${DateUtils.formatDateTime(state.originalTransaction?.createdAt ?? DateTime.now())}',
                              style:
                                  theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(key: const ValueKey<String>('info-card'))
                    .slideY(begin: 0.3, delay: 550.ms)
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

  Widget _buildDateField(
    ThemeData theme,
    EditTransactionState state,
    EditTransactionNotifier notifier,
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
          borderRadius:
              BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: state.effectiveDate != null
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.3),
                width:
                    state.effectiveDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: state.effectiveDate != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface
                          .withOpacity(0.6),
                ),
                const Gap(DesignTokens.spacingXs),
                Expanded(
                  child: Text(
                    state.effectiveDate != null
                        ? DateUtils.formatDate(
                            state.effectiveDate!)
                        : 'Select date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight:
                          state.effectiveDate != null
                              ? FontWeight.w500
                              : null,
                      color: state.effectiveDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      EditTransactionNotifier notifier) async {
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
