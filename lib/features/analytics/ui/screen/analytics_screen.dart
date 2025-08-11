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
import '../widgets/analytics_overview_cards.dart';
import '../widgets/category_spending_chart.dart';
import '../widgets/insights_section.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/quick_stats_grid.dart';

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
        SliverAppBar(
          expandedHeight: 120,
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
                  child: _buildHeader(theme),
                ),
              ),
            ),
          ),
        ),
        analyticsState.when(
          data: (AnalyticsData data) => _buildAnalyticsContent(data, baseCurrency, theme),
          loading: () => const SliverFillRemaining(
            child: LoadingState(message: 'Analyzing your financial data...'),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const Gap(DesignTokens.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Financial insights & trends',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingXs,
                vertical: DesignTokens.spacing2xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.insights,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const Gap(DesignTokens.spacing2xs),
                  Text(
                    _selectedPeriod.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),
      ],
    );
  }

  Widget _buildAnalyticsContent(AnalyticsData data, String baseCurrency, ThemeData theme) {
    final String currencySymbol = CurrencyUtils.getCurrencySymbol(baseCurrency);
    final EdgeInsets screenPadding = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width > 600 ? DesignTokens.spacingLg : DesignTokens.spacingMd,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            AnalyticsOverviewCards(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            QuickStatsGrid(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            MonthlyTrendChart(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            CategorySpendingChart(
              data: data,
              currencySymbol: currencySymbol,
            ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),

            const Gap(DesignTokens.spacingLg),

            InsightsSection(
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
