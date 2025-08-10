import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../models/analytics_data.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_header.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/spending_chart.dart';
import '../widgets/top_categories_list.dart';
import '../widgets/trend_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).loadAnalytics(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AnalyticsData> analyticsState = ref.watch(analyticsProvider);
    final AsyncValue<String> baseCurrencyAsync = ref.watch(baseCurrencyProvider);
    final ThemeData theme = Theme.of(context);

    return SwipeNavigationWrapper(
      currentRoute: 'analytics',
      child: Scaffold(
        body: baseCurrencyAsync.when(
          data: (String baseCurrency) => _buildContent(context, theme, analyticsState, baseCurrency),
          loading: () => const LoadingState(message: 'Loading currency...'),
          error: (Object error, StackTrace _) => ErrorState(
            title: 'Error loading currency',
            message: error.toString(),
            onRetry: () => ref.refresh(baseCurrencyProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    AsyncValue<AnalyticsData> analyticsState,
    String baseCurrency,
  ) {
    return CustomScrollView(
      slivers: <Widget>[
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    theme.colorScheme.primaryContainer.withOpacity(0.1),
                    theme.colorScheme.secondaryContainer.withOpacity(0.05),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  child: AnalyticsHeader(
                    onPeriodChanged: _onPeriodChanged,
                    selectedPeriod: _selectedPeriod,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        analyticsState.when(
          data: (AnalyticsData data) => _buildAnalyticsContent(data, baseCurrency, theme),
          loading: () => const SliverFillRemaining(
            child: LoadingState(message: 'Analyzing your spending patterns...'),
          ),
          error: (Object error, StackTrace _) => SliverFillRemaining(
            child: ErrorState(
              title: 'Failed to load analytics',
              message: error.toString(),
              onRetry: () => ref.read(analyticsProvider.notifier).loadAnalytics(_selectedPeriod),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent(AnalyticsData data, String baseCurrency, ThemeData theme) {
    final String currencySymbol = CurrencyUtils.getCurrencySymbol(baseCurrency);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Period Selector
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            // Summary Cards
            AnalyticsSummaryCards(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            // Income vs Expenses Chart
            SpendingChart(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            // Category Breakdown
            CategoryBreakdownChart(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            // Trend Chart
            TrendChart(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            // Top Categories
            TopCategoriesList(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),

            const Gap(DesignTokens.spacingXl),
          ],
        ),
      ),
    );
  }

  void _onPeriodChanged(AnalyticsPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    ref.read(analyticsProvider.notifier).loadAnalytics(period);
  }
}
