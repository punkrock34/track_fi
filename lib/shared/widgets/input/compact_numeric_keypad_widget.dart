import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import 'compact_keypad_button_widget.dart';

class CompactNumericKeypad extends StatelessWidget {
  const CompactNumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    this.onBiometricPressed,
    this.showBiometric = false,
    required this.currentLength,
    required this.maxLength,
  });

  final ValueChanged<String> onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final int currentLength;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildKeypadRow(<String>['1', '2', '3']),
        const Gap(DesignTokens.spacingXs),
        _buildKeypadRow(<String>['4', '5', '6']),
        const Gap(DesignTokens.spacingXs),
        _buildKeypadRow(<String>['7', '8', '9']),
        const Gap(DesignTokens.spacingXs),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((String number) => CompactKeypadButton(
        text: number,
        onPressed: currentLength < maxLength ? () => onNumberPressed(number) : null,
      )).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if (showBiometric) CompactKeypadButton(
                icon: Icons.fingerprint,
                onPressed: onBiometricPressed,
                isSpecial: true,
              ) else const SizedBox(width: 48, height: 48),
        
        CompactKeypadButton(
          text: '0',
          onPressed: currentLength < maxLength ? () => onNumberPressed('0') : null,
        ),
        
        CompactKeypadButton(
          icon: Icons.backspace_outlined,
          onPressed: currentLength > 0 ? onBackspace : null,
          isSpecial: true,
        ),
      ],
    );
  }
}
