import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../shared/widgets/feature_card.dart';
import '../../../shared/widgets/theme_toggle.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              children: <Widget>[
                Gap(size.height * 0.08),

                _buildBrandingSection(theme),
                
                Gap(size.height * 0.06),

                _buildFeaturesSection(theme),
                
                Gap(size.height * 0.04),

                _buildActionButtons(context, theme, size),
                
                const Gap(DesignTokens.spacingMd),

                const Center(
                  child: ThemeToggle(
                    showLabel: false,
                  ),
                ),
                
                const Gap(DesignTokens.spacingMd),
              ],
            ),
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
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: Colors.white,
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
            color: Colors.white,
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
            color: Colors.white.withOpacity(0.9),
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
    final List<_FeatureData> features = <_FeatureData>[
      const _FeatureData(
        icon: Icons.account_balance_rounded,
        title: 'Unified Banking',
        description: 'Connect Revolut, BT, and more in one secure dashboard',
      ),
      const _FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Smart Analytics',
        description: 'AI-powered insights to optimize your financial health',
      ),
      const _FeatureData(
        icon: Icons.security_rounded,
        title: 'Bank-Grade Security',
        description: 'Military-grade encryption keeps your data safe',
      ),
    ];

    return Column(
      children: features.asMap().entries.map((MapEntry<int, _FeatureData> entry) {
        final int index = entry.key;
        final _FeatureData feature = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < features.length - 1 ? DesignTokens.spacingMd : 0,
          ),
          child: FeatureCard(
            icon: feature.icon,
            title: feature.title,
            description: feature.description,
            gradient: LinearGradient(
              colors: <Color>[
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            animationDelay: Duration(milliseconds: 800 + (index * 200)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, Size size) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: DesignTokens.buttonHeightLg,
          child: ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Start Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(DesignTokens.spacingXs),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
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
          onPressed: () {
            // TODO(Navigate): Navigate to learn more
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Learn more about security',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(DesignTokens.spacing2xs),
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.8),
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
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
