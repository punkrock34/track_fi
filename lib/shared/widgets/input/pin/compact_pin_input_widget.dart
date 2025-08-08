import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../keyboard/compact_numeric_keypad_widget.dart';
import 'compact_pin_display_widget.dart';
import 'pin_input_widget.dart';

class CompactPinInput extends StatelessWidget {
  const CompactPinInput({
    super.key,
    required this.pin,
    required this.onChanged,
    required this.mode,
    this.maxLength = 6,
    this.showBiometric = false,
    this.onBiometricPressed,
  });

  final String pin;
  final ValueChanged<String> onChanged;
  final PinInputMode mode;
  final int maxLength;
  final bool showBiometric;
  final VoidCallback? onBiometricPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // PIN Display
        CompactPinDisplay(
          pin: pin,
          maxLength: maxLength,
        ),
        
        const Gap(DesignTokens.spacingMd),
        
        // Compact Keypad
        CompactNumericKeypad(
          onNumberPressed: (String number) {
            if (pin.length < maxLength) {
              final String newPin = pin + number;
              onChanged(newPin);
            }
          },
          onBackspace: () {
            if (pin.isNotEmpty) {
              onChanged(pin.substring(0, pin.length - 1));
            }
          },
          onBiometricPressed: onBiometricPressed,
          showBiometric: showBiometric,
          currentLength: pin.length,
          maxLength: maxLength,
        ),
      ],
    );
  }
}
