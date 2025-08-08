import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/contracts/services/currency/i_currency_exchange_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../features/accounts/providers/accounts_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../utils/currency_utils.dart';
import 'currency_picker.dart';

class CurrencySelectorButton extends ConsumerStatefulWidget {
  const CurrencySelectorButton({super.key});

  @override
  ConsumerState<CurrencySelectorButton> createState() => _CurrencySelectorButtonState();
}

class _CurrencySelectorButtonState extends ConsumerState<CurrencySelectorButton> {
  String? _currentCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
  }

  Future<void> _loadCurrentCurrency() async {
    final ICurrencyExchangeService currencyService = ref.read(currencyExchangeServiceProvider);

    try {
      final String currency = await currencyService.getBaseCurrency();
      setState(() {
        _currentCurrency = currency;
      });
    } catch (_) {
      setState(() {
        _currentCurrency = 'RON';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.primaryContainer.withOpacity(0.8),
            theme.colorScheme.secondaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _showCurrencyPicker(context),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingSm,
              vertical: DesignTokens.spacingXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      CurrencyUtils.getCurrencySymbol(_currentCurrency ?? 'RON'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Gap(DesignTokens.spacing2xs),
                  Text(
                    _currentCurrency ?? 'RON',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Gap(DesignTokens.spacing2xs),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    final String? selectedCurrency = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLg),
          ),
        ),
        child: CurrencyPicker(
          currentCurrency: _currentCurrency ?? 'RON',
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (selectedCurrency != null && selectedCurrency != _currentCurrency) {
      await _changeCurrency(selectedCurrency);
    }
  }

  Future<void> _changeCurrency(String newCurrency) async {
    final ICurrencyExchangeService currencyService = ref.read(currencyExchangeServiceProvider);
    final DashboardNotifier dashboardNotifier = ref.read(dashboardProvider.notifier);
    final AccountsNotifier accountsNotifier = ref.read(accountsProvider.notifier);

    setState(() {
      _isLoading = true;
    });

    try {
      await currencyService.setBaseCurrency(newCurrency);
      setState(() {
        _currentCurrency = newCurrency;
      });

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const Gap(DesignTokens.spacingXs),
              Text('Currency changed to $newCurrency'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      
      await _refreshDataInBackground(
        dashboardNotifier: dashboardNotifier,
        accountsNotifier: accountsNotifier,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onError,
                size: 20,
              ),
              const Gap(DesignTokens.spacingXs),
              Expanded(child: Text('Failed to change currency: $e')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDataInBackground({
    required DashboardNotifier dashboardNotifier,
    required AccountsNotifier accountsNotifier,
  }) async {
    try {
      await dashboardNotifier.loadDashboardData();
      await accountsNotifier.loadAccounts();
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to refresh data after currency change',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
