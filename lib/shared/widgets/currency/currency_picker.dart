import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/currency_utils.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({
    super.key,
    required this.currentCurrency,
  });

  final String currentCurrency;

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  late TextEditingController _searchController;
  List<Map<String, String>> _allCurrencies = <Map<String, String>>[];
  List<Map<String, String>> _filteredCurrencies = <Map<String, String>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadCurrencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      final List<Map<String, String>> currencies = await CurrencyUtils.getAllCurrencies();
      final List<String> popularCurrencies = CurrencyUtils.getPopularCurrencies();
      
      // Sort: popular currencies first, then alphabetical
      final List<Map<String, String>> popular = <Map<String, String>>[];
      final List<Map<String, String>> others = <Map<String, String>>[];
      
      for (final Map<String, String> currency in currencies) {
        if (popularCurrencies.contains(currency['code'])) {
          popular.add(currency);
        } else {
          others.add(currency);
        }
      }
      
      // Sort popular by the order in popularCurrencies list
      popular.sort((Map<String, String> a, Map<String, String> b) {
        final int indexA = popularCurrencies.indexOf(a['code'] ?? '');
        final int indexB = popularCurrencies.indexOf(b['code'] ?? '');
        return indexA.compareTo(indexB);
      });
      
      setState(() {
        _allCurrencies = <Map<String, String>>[...popular, ...others];
        _filteredCurrencies = _allCurrencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final String query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _allCurrencies;
      } else {
        _filteredCurrencies = _allCurrencies.where((Map<String, String> currency) {
          final String code = (currency['code'] ?? '').toLowerCase();
          final String name = (currency['name'] ?? '').toLowerCase();
          return code.contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> popularCurrencies = CurrencyUtils.getPopularCurrencies();
    
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.5,
      initialChildSize: 0.7,
      expand: false,
      builder: (_, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Select Currency',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Gap(DesignTokens.spacingSm),
                  
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search currencies...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingSm,
                        vertical: DesignTokens.spacingXs,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Currency List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCurrencyList(scrollController, popularCurrencies, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrencyList(
    ScrollController scrollController,
    List<String> popularCurrencies,
    ThemeData theme,
  ) {
    if (_filteredCurrencies.isEmpty) {
      return const Center(
        child: Text('No currencies found'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      itemCount: _filteredCurrencies.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, String> currency = _filteredCurrencies[index];
        final String code = currency['code'] ?? '';
        final String name = currency['name'] ?? '';
        final String symbol = currency['symbol'] ?? '';
        
        final bool isSelected = code == widget.currentCurrency;
        final bool isPopular = popularCurrencies.contains(code);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(code),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spacingSm),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: isSelected 
                    ? Border.all(color: theme.colorScheme.primary)
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  // Currency Symbol
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  const Gap(DesignTokens.spacingSm),
                  
                  // Currency Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              code,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isPopular) ...<Widget>[
                              const Gap(DesignTokens.spacingXs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spacingXs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                                ),
                                child: Text(
                                  'Popular',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
