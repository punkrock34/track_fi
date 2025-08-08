import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/contracts/services/currency/i_currency_exchange_service.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../features/accounts/providers/accounts_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import 'currency_picker.dart';

class CurrencySelectorButton extends ConsumerWidget {
  const CurrencySelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    
    return FutureBuilder<String>(
      future: ref.read(currencyExchangeServiceProvider).getBaseCurrency(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final String currentCurrency = snapshot.data ?? 'GBP';
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        
        return InkWell(
          onTap: isLoading ? null : () => _showCurrencyPicker(context, ref, currentCurrency),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingXs,
              vertical: DesignTokens.spacing2xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading) 
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Text(
                    currentCurrency,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Gap(DesignTokens.spacing2xs),
                Icon(
                  Icons.expand_more,
                  size: 14,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentCurrency) async {
    final String? selectedCurrency = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (_) => CurrencyPicker(
        currentCurrency: currentCurrency,
      ),
    );

    if(!context.mounted) {
      return;
    }

    if (selectedCurrency != null && selectedCurrency != currentCurrency) {
      await _changeCurrency(context, ref, selectedCurrency);
    }
  }

  Future<void> _changeCurrency(BuildContext context, WidgetRef ref, String newCurrency) async {
    final ICurrencyExchangeService currencyService = ref.read(currencyExchangeServiceProvider);
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Text('Changing currency to $newCurrency...'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );

    try {
      await currencyService.setBaseCurrency(newCurrency);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency changed to $newCurrency'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Trigger dashboard refresh - we'll need to invalidate providers
        ref.invalidate(dashboardProvider);
        ref.invalidate(accountsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change currency: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
