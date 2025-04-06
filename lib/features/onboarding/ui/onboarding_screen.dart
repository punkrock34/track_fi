import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackfi/app/theme/theme_extensions.dart';
import 'package:trackfi/features/onboarding/ui/widgets/feature_item.dart';
import 'package:trackfi/features/onboarding/ui/widgets/theme_toggle.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.backgroundGradientStart, theme.backgroundGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),

                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TrackFi',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track all your finances in one place',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withAlpha((8 * 255).round()),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  const FeatureItem(
                    icon: Icons.account_balance,
                    title: 'All Your Accounts',
                    description: 'Bank, trading, and crypto in one dashboard',
                  ),
                  const SizedBox(height: 24),
                  const FeatureItem(
                    icon: Icons.insights,
                    title: 'Smart Analytics',
                    description: 'Track performance and optimize your portfolio',
                  ),
                  const SizedBox(height: 24),
                  const FeatureItem(
                    icon: Icons.lock,
                    title: 'Secure & Private',
                    description: 'Your financial data stays protected',
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                      minimumSize: Size(size.width * 0.8, 56),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const ThemeToggle(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
