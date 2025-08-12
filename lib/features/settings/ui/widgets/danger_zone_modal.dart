import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/contracts/services/database/i_database_service.dart';
import '../../../../core/contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../../core/logging/log.dart';
import '../../../../core/providers/database/database_service_provider.dart';
import '../../../../core/providers/secure_storage/secure_storage_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/input/text/text_input_field_widget.dart';
import '../../../onboarding/providers/onboarding_provider.dart';

enum DangerZoneStep {
  warning,
  confirmation,
  clearing,
  success,
}

class DangerZoneModal extends ConsumerStatefulWidget {
  const DangerZoneModal({super.key});

  @override
  ConsumerState<DangerZoneModal> createState() => _DangerZoneModalState();
}

class _DangerZoneModalState extends ConsumerState<DangerZoneModal> {
  DangerZoneStep _currentStep = DangerZoneStep.warning;
  final TextEditingController _confirmationController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const String _confirmationText = 'DELETE ALL DATA';

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    
    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        insetPadding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: screenSize.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DesignTokens.radiusLg),
                    topRight: Radius.circular(DesignTokens.radiusLg),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.error.withOpacity(0.2),
                    ),
                  ),
                ),
                child: _buildHeader(theme),
              ),
              
              // Content
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (_errorMessage != null) ...<Widget>[
                        _buildErrorMessage(theme),
                        const Gap(DesignTokens.spacingSm),
                      ],
                      
                      Flexible(
                        child: _buildCurrentStep(theme),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              if (_currentStep != DangerZoneStep.success)
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(DesignTokens.radiusLg),
                      bottomRight: Radius.circular(DesignTokens.radiusLg),
                    ),
                  ),
                  child: _buildActions(theme),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    String title;
    IconData icon;
    
    switch (_currentStep) {
      case DangerZoneStep.warning:
        title = 'Clear All Data';
        icon = Icons.warning_rounded;
      case DangerZoneStep.confirmation:
        title = 'Confirm Action';
        icon = Icons.delete_forever_rounded;
      case DangerZoneStep.clearing:
        title = 'Clearing Data...';
        icon = Icons.hourglass_empty_rounded;
      case DangerZoneStep.success:
        title = 'Data Cleared';
        icon = Icons.check_circle_outline_rounded;
    }

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _currentStep == DangerZoneStep.success 
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            color: _currentStep == DangerZoneStep.success 
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            size: 24,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _currentStep == DangerZoneStep.success 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ),
        if (!_isLoading)
          IconButton(
            onPressed: _navigateToOnboarding,
            icon: const Icon(Icons.close_rounded),
            iconSize: 20,
          ),
      ],
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case DangerZoneStep.warning:
        return _buildWarningStep(theme);
      case DangerZoneStep.confirmation:
        return _buildConfirmationStep(theme);
      case DangerZoneStep.clearing:
        return _buildClearingStep(theme);
      case DangerZoneStep.success:
        return _buildSuccessStep(theme);
    }
  }

  Widget _buildWarningStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.dangerous_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Text(
                      'Permanent Data Deletion',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Gap(DesignTokens.spacingXs),
                Text(
                  'This will permanently delete ALL your financial data stored locally on this device. This action cannot be undone.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),

          const Gap(DesignTokens.spacingMd),

          Text(
            'What will be deleted:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Gap(DesignTokens.spacingXs),

          _buildWarningItem(
            theme,
            Icons.account_balance_rounded,
            'All Financial Accounts',
            "Every account you've added including names, balances, bank details, and account numbers",
          ),

          _buildWarningItem(
            theme,
            Icons.receipt_long_rounded,
            'Complete Transaction History',
            "All income, expenses, and transfers - every financial transaction you've recorded",
          ),
          
          _buildWarningItem(
            theme,
            Icons.security_rounded,
            'Security & Authentication Data',
            'Your PIN, biometric settings, and all encrypted security information',
          ),

          _buildWarningItem(
            theme,
            Icons.settings_rounded,
            'App Settings',
            'Theme preferences, currency settings, and all other app configurations',
          ),

          const Gap(DesignTokens.spacingLg),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Text(
                      'Before you proceed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(DesignTokens.spacingXs),
                Text(
                  'Consider exporting your data first from Settings > Data > Export Data. While you cannot currently re-import this data, it serves as a backup record of your financial information.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(ThemeData theme, IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.error,
              size: 18,
            ),
          ),
          const Gap(DesignTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Gap(2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Are you absolutely sure?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.error,
            ),
          ),
          
          const Gap(DesignTokens.spacingSm),
          
          Text(
            'This will permanently delete all your financial data from TrackFi. Once deleted, this information cannot be recovered.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          const Gap(DesignTokens.spacingMd),

          Text(
            'To confirm this irreversible action, please type:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const Gap(DesignTokens.spacingMd),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Text(
              _confirmationText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
                fontFamily: 'monospace',
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Gap(DesignTokens.spacingMd),

          TextInputField(
            controller: _confirmationController,
            label: 'Confirmation Text',
            hint: 'Type the text above exactly as shown',
            onChanged: (_) => setState(() {}),
            validator: (String? value) {
              if (value?.trim() != _confirmationText) {
                return 'Text must match exactly';
              }
              return null;
            },
            prefixIcon: Icons.warning_rounded,
          ),

          const Gap(DesignTokens.spacingMd),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Text(
              '⚠️ This action is permanent and will reset TrackFi to its initial state',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearingStep(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.colorScheme.error,
            ),
          ).animate().scale(duration: 1000.ms, curve: Curves.easeInOut).then()
           .rotate(duration: 2000.ms)
           .then(delay: 500.ms)
           .rotate(duration: 2000.ms),
          
          const Gap(DesignTokens.spacingLg),
          
          Text(
            'Clearing all data...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          
          const Gap(DesignTokens.spacingSm),
          
          Text(
            'Please wait while we securely delete your data.\nThis may take a few moments.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(ThemeData theme) {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToOnboarding();
      }
    });

    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            
            const Gap(DesignTokens.spacingMd),
            
            Text(
              'Data Cleared Successfully',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(delay: 300.ms),
            
            const Gap(DesignTokens.spacingSm),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingSm),
              child: Text(
                'All your financial data has been permanently deleted from this device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(delay: 500.ms),

            const Gap(DesignTokens.spacingSm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingSm),
              child: Text(
                'Returning to setup process...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().slideY(begin: 0.3, delay: 700.ms).fadeIn(delay: 700.ms),

            const Gap(DesignTokens.spacingMd),

            // Progress indicator
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ).animate().fadeIn(delay: 1000.ms),

            const Gap(DesignTokens.spacingMd),

            // Optional manual button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _navigateToOnboarding,
                child: const Text('Continue Now'),
              ),
            ).animate().slideY(begin: 0.3, delay: 900.ms).fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 18,
          ),
          const Gap(DesignTokens.spacingXs),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(hz: 4, curve: Curves.easeInOut).fadeIn();
  }

  Widget _buildActions(ThemeData theme) {
    switch (_currentStep) {
      case DangerZoneStep.warning:
        return Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: _isLoading ? null : _proceedToConfirmation,
                child: const Text('I Understand, Continue'),
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _navigateToOnboarding,
                child: const Text('Cancel'),
              ),
            ),
          ],
        );

      case DangerZoneStep.confirmation:
        final bool canProceed = _confirmationController.text.trim() == _confirmationText;
        
        return Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed ? theme.colorScheme.error : null,
                  foregroundColor: canProceed ? theme.colorScheme.onError : null,
                ),
                onPressed: canProceed && !_isLoading ? _handleClearAllData : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete Everything'),
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => setState(() => _currentStep = DangerZoneStep.warning),
                child: const Text('Back'),
              ),
            ),
          ],
        );

      case DangerZoneStep.clearing:
      case DangerZoneStep.success:
        return const SizedBox.shrink();
    }
  }

  void _proceedToConfirmation() {
    setState(() {
      _currentStep = DangerZoneStep.confirmation;
      _confirmationController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _handleClearAllData() async {
    setState(() {
      _isLoading = true;
      _currentStep = DangerZoneStep.clearing;
      _errorMessage = null;
    });

    try {
      // Clear database
      final IDatabaseService databaseService = ref.read(databaseServiceProvider);
      await databaseService.deleteDatabase();
      await databaseService.init();

      // Clear secure storage
      final ISecureStorageService secureStorage = ref.read(secureStorageProvider);
      await secureStorage.clearAll();

      // Clear onboarding state
      ref.read(onboardingProvider.notifier).reset();

      // Small delay to show the clearing animation
      await Future<void>.delayed(const Duration(seconds: 2));

      setState(() {
        _currentStep = DangerZoneStep.success;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      await log(
        message: 'Failed to clear all data',
        error: e,
        stackTrace: stackTrace,
      );

      setState(() {
        _errorMessage = 'Failed to clear data. Please try again.';
        _currentStep = DangerZoneStep.confirmation;
        _isLoading = false;
      });
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      context.goNamed('onboarding');
    }
  }
}

Future<bool?> showDangerZoneModal(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const DangerZoneModal(),
  );
}
