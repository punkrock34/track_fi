import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/design_tokens/design_tokens.dart';
import 'keypad_button_widget.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    this.onBiometricPressed,
    this.showBiometric = false,
    this.biometricIcon = Icons.fingerprint,
    this.maxLength = 6,
    this.currentLength = 0,
    this.hapticFeedback = true,
    this.animationDelay = Duration.zero,
  });

  final ValueChanged<String> onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final IconData biometricIcon;
  final int maxLength;
  final int currentLength;
  final bool hapticFeedback;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData _ = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildKeypadRow(context, <String>['1', '2', '3'], 0),
          const Gap(DesignTokens.spacingSm),

          _buildKeypadRow(context, <String>['4', '5', '6'], 1),
          const Gap(DesignTokens.spacingSm),

          _buildKeypadRow(context, <String>['7', '8', '9'], 2),
          const Gap(DesignTokens.spacingSm),

          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(BuildContext context, List<String> numbers, int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.asMap().entries.map((MapEntry<int, String> entry) {
        final int index = entry.key;
        final String number = entry.value;
        final int globalIndex = rowIndex * 3 + index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: KeypadButton(
            text: number,
            onPressed: currentLength < maxLength ? () => _onNumberPressed(number) : null,
            animationDelay: animationDelay + Duration(milliseconds: globalIndex * 50),
            isSpecial: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: showBiometric
              ? KeypadButton(
                  icon: biometricIcon,
                  onPressed: onBiometricPressed,
                  isSpecial: true,
                  animationDelay: animationDelay + const Duration(milliseconds: 350),
                )
              : const SizedBox(height: KeypadButton.defaultHeight, width: KeypadButton.defaultWidth),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: KeypadButton(
            text: '0',
            onPressed: currentLength < maxLength ? () => _onNumberPressed('0') : null,
            animationDelay: animationDelay + const Duration(milliseconds: 400),
            isSpecial: false,
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: KeypadButton(
            icon: Icons.backspace_outlined,
            onPressed: currentLength > 0 ? onBackspace : null,
            isSpecial: true,
            animationDelay: animationDelay + const Duration(milliseconds: 450),
          ),
        ),
        
      ],
    );
  }

  void _onNumberPressed(String number) {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onNumberPressed(number);
  }
}
