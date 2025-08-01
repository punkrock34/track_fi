import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/cards/feature_card.dart';
import '../../models/feature_data.dart';
import '../../providers/onboarding_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            children: <Widget>[
              _buildBrandingSection(theme),
              Gap(size.height * 0.06),
              _buildFeaturesSection(theme),
              Gap(size.height * 0.04),
              _buildActionButtons(context, theme, ref),
              const Gap(DesignTokens.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(ThemeData theme) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: theme.colorScheme.onPrimary,
          ),
        )
            .animate()
            .scale(
              delay: 200.ms,
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(delay: 200.ms),
        const Gap(DesignTokens.spacingMd),
        Text(
          'TrackFi',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 400.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 400.ms),
        const Gap(DesignTokens.spacingXs),
        Text(
          'Your complete financial command center',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 600.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    final List<FeatureData> features = <FeatureData>[
      const FeatureData(
        icon: Icons.account_balance_rounded,
        title: 'Unified Banking',
        description: 'Connect Revolut, BT, and more in one secure dashboard',
      ),
      const FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Smart Analytics',
        description: 'AI-powered insights to optimize your financial health',
      ),
      const FeatureData(
        icon: Icons.security_rounded,
        title: 'Bank-Grade Security',
        description: 'Military-grade encryption keeps your data safe',
      ),
    ];

    return Column(
      children:
          features.asMap().entries.map((MapEntry<int, FeatureData> entry) {
        final int index = entry.key;
        final FeatureData feature = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < features.length - 1 ? DesignTokens.spacingMd : 0,
          ),
          child: FeatureCard(
            icon: feature.icon,
            title: feature.title,
            description: feature.description,
            animationDelay: Duration(milliseconds: 800 + (index * 200)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: DesignTokens.buttonHeightLg,
          child: ElevatedButton(
            onPressed: () => ref.read(onboardingProvider.notifier).nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const Gap(DesignTokens.spacingXs),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.5,
              delay: 1400.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 1400.ms),
        const Gap(DesignTokens.spacingSm),
        TextButton(
          onPressed: () => _showSecurityInfoDialog(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Learn more about security',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(DesignTokens.spacing2xs),
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ],
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 1600.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 1600.ms),
      ],
    );
  }

  void _showSecurityInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bank-Grade Security'),
          content: const SingleChildScrollView(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
              'nisi ut aliquip ex ea commodo consequat.\n\n'
              'Duis aute irure dolor in reprehenderit in voluptate velit esse '
              'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat '
              'cupidatat non proident, sunt in culpa qui officia deserunt mollit '
              'anim id est laborum.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
