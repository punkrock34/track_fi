import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/cards/feature_card.dart';
import '../../../../shared/widgets/common/security_info_dialog.dart';
import '../../models/feature_data.dart';
import '../../providers/onboarding_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.03),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              children: <Widget>[
                Gap(size.height * 0.08),
                _buildHeroSection(theme, size),
                Gap(size.height * 0.06),
                _buildFeaturesSection(theme),
                Gap(size.height * 0.04),
                _buildActionButtons(context, theme, ref, size),
                const Gap(DesignTokens.spacingMd),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, Size size) {
    return Column(
      children: <Widget>[
        // App Icon with enhanced styling
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: theme.colorScheme.secondary.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 16),
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
              duration: 800.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(delay: 200.ms),
        
        const Gap(DesignTokens.spacingLg),
        
        // App Name with enhanced typography
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: <Color>[
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ).createShader(bounds);
          },
          child: Text(
            'TrackFi',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 500.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 500.ms),
        
        const Gap(DesignTokens.spacingSm),
        
        // Tagline with better styling
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMd,
            vertical: DesignTokens.spacingXs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            'Your complete financial command center',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 700.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 700.ms),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    final List<FeatureData> features = <FeatureData>[
      const FeatureData(
        icon: Icons.account_balance_rounded,
        title: 'Unified Banking',
        description: 'Connect all your accounts in one secure, encrypted dashboard',
      ),
      const FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Smart Analytics',
        description: 'Powerful insights to optimize your financial health and spending',
      ),
      const FeatureData(
        icon: Icons.security_rounded,
        title: 'Bank-Grade Security',
        description: 'Military-grade encryption with biometric protection',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(DesignTokens.spacingSm),
              Text(
                'Why choose TrackFi?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ).animate().slideX(begin: -0.3, delay: 900.ms).fadeIn(delay: 900.ms),
        
        const Gap(DesignTokens.spacingMd),
        
        ...features.asMap().entries.map((MapEntry<int, FeatureData> entry) {
          final int index = entry.key;
          final FeatureData feature = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < features.length - 1 ? DesignTokens.spacingSm : 0,
            ),
            child: FeatureCard(
              icon: feature.icon,
              title: feature.title,
              description: feature.description,
              animationDelay: Duration(milliseconds: 1000 + (index * 150)),
              gradient: LinearGradient(
                colors: <Color>[
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, WidgetRef ref, Size size) {
    return Column(
      children: <Widget>[
        // Primary CTA with enhanced styling
        Container(
          width: double.infinity,
          height: DesignTokens.buttonHeightLg,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => ref.read(onboardingProvider.notifier).nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
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
                  size: 20,
                ),
              ],
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.5,
              delay: 1500.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 1500.ms),
        
        const Gap(DesignTokens.spacingSm),
        
        // Secondary link with subtle styling
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingSm,
            vertical: DesignTokens.spacingXs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
          child: InkWell(
            onTap: () => SecurityInfoDialog.show(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingXs,
                vertical: DesignTokens.spacing2xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const Gap(DesignTokens.spacing2xs),
                  Text(
                    'Learn about our security',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(DesignTokens.spacing2xs),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 12,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              delay: 1700.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: 1700.ms),
      ],
    );
  }
}
