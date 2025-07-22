import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/providers/database/storage/category_storage_service_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/category_utils.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.transactionType,
    required this.onCategoryChanged,
  });

  final String? selectedCategoryId;
  final TransactionType transactionType;
  final ValueChanged<String?> onCategoryChanged;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload categories if transaction type changed
    if (oldWidget.transactionType != widget.transactionType) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> allCategories = 
          await ref.read(categoryStorageProvider).getAll();
      
      // Filter categories by transaction type
      final String filterType = widget.transactionType == TransactionType.credit 
          ? 'income' 
          : 'expense';
      
      setState(() {
        _categories = allCategories
            .where((Map<String, dynamic> cat) => cat['type'] == filterType)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _categories = <Map<String, dynamic>>[];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, dynamic>? selectedCategory = widget.selectedCategoryId != null
        ? _categories.cast<Map<String, dynamic>?>().firstWhere(
            (Map<String, dynamic>? cat) => cat?['id'] == widget.selectedCategoryId,
            orElse: () => null,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Category (Optional)',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        if (_isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          InkWell(
            onTap: () => _showCategoryPicker(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacingSm),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: widget.selectedCategoryId != null
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: widget.selectedCategoryId != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selectedCategory != null
                          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Icon(
                      selectedCategory != null
                          ? CategoryUtils.getCategoryIcon(selectedCategory['id'] as String)
                          : Icons.category_outlined,
                      size: 16,
                      color: selectedCategory != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    child: Text(
                      selectedCategory != null
                          ? selectedCategory['name'] as String
                          : 'Select category',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: selectedCategory != null 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                        color: selectedCategory != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (widget.selectedCategoryId != null) ...<Widget>[
                    InkWell(
                      onTap: () => widget.onCategoryChanged(null),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ] else
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

  void _showCategoryPicker(BuildContext context) {
    if (_categories.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Select Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    itemCount: _categories.length + 1, // +1 for "None" option
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        // "None" option
                        final bool isSelected = widget.selectedCategoryId == null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                          child: InkWell(
                            onTap: () {
                              widget.onCategoryChanged(null);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.all(DesignTokens.spacingSm),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Gap(DesignTokens.spacingSm),
                                  Expanded(
                                    child: Text(
                                      'None',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final Map<String, dynamic> category = _categories[index - 1];
                      final bool isSelected = category['id'] == widget.selectedCategoryId;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                        child: InkWell(
                          onTap: () {
                            widget.onCategoryChanged(category['id'] as String);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(DesignTokens.spacingSm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CategoryUtils.getCategoryColor(
                                      category['id'] as String,
                                      Theme.of(context),
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  ),
                                  child: Icon(
                                    CategoryUtils.getCategoryIcon(category['id'] as String),
                                    size: 20,
                                    color: CategoryUtils.getCategoryColor(
                                      category['id'] as String,
                                      Theme.of(context),
                                    ),
                                  ),
                                ),
                                const Gap(DesignTokens.spacingSm),
                                Expanded(
                                  child: Text(
                                    category['name'] as String,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
