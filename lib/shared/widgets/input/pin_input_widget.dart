import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import 'numeric_keypad_widget.dart';
import 'pin_display_widget.dart';

enum PinInputMode {
  setup,
  confirm,
  auth,
}

class PinInputWidget extends StatefulWidget {
  const PinInputWidget({
    super.key,
    required this.pin,
    required this.onChanged,
    this.mode = PinInputMode.setup,
    this.maxLength = 6,
    this.minLength = 4,
    this.obscureText = true,
    this.showBiometric = false,
    this.biometricIcon = Icons.fingerprint,
    this.onBiometricPressed,
    this.onAutoSubmit,
    this.expectedPinLength,
    this.autoSubmit = false,
    this.showRealTimeValidation = true,
    this.animationDelay = Duration.zero,
  });

  final String pin;
  final ValueChanged<String> onChanged;
  final PinInputMode mode;
  final int maxLength;
  final int minLength;
  final bool obscureText;
  final bool showBiometric;
  final IconData biometricIcon;
  final VoidCallback? onBiometricPressed;
  final VoidCallback? onAutoSubmit;
  final int? expectedPinLength;
  final bool autoSubmit;
  final bool showRealTimeValidation;
  final Duration animationDelay;

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    final bool isComplete = _isComplete();
    final bool shouldAutoSubmit = widget.autoSubmit &&
                                 isComplete &&
                                 !_isSubmitting &&
                                 widget.mode == PinInputMode.auth &&
                                 widget.onAutoSubmit != null;

    if (shouldAutoSubmit) {
      _isSubmitting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.onAutoSubmit == null) {
          return;
        }

        widget.onAutoSubmit!();
      });
    }

    return Column(
      children: <Widget>[
        PinDisplayWidget(
          pin: widget.pin,
          maxLength: _getEffectiveMaxLength(),
          minLength: widget.minLength,
          obscureText: widget.obscureText,
          showValidation: widget.showRealTimeValidation && widget.mode != PinInputMode.confirm,
          animationDelay: widget.animationDelay,
        ),

        const Gap(DesignTokens.spacingSm),
        
        NumericKeypad(
          onNumberPressed: (String number) {
            final int effectiveMaxLength = _getEffectiveMaxLength();
            if (widget.pin.length < effectiveMaxLength) {
              widget.onChanged(widget.pin + number);
            }
          },
          onBackspace: () {
            if (widget.pin.isNotEmpty) {
              widget.onChanged(widget.pin.substring(0, widget.pin.length - 1));
            }
          },
          onBiometricPressed: widget.onBiometricPressed,
          showBiometric: widget.showBiometric,
          biometricIcon: widget.biometricIcon,
          maxLength: _getEffectiveMaxLength(),
          currentLength: widget.pin.length,
          animationDelay: widget.animationDelay + const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset flag when PIN changes (important for retry after failed attempt)
    if (oldWidget.pin != widget.pin) {
      _isSubmitting = false;
    }
  }

  bool _isComplete() {
    if (widget.expectedPinLength != null) {
      return widget.pin.length == widget.expectedPinLength;
    }
    return widget.pin.length >= widget.minLength;
  }

  int _getEffectiveMaxLength() {
    if (widget.mode == PinInputMode.auth && widget.expectedPinLength != null) {
      return widget.expectedPinLength!;
    }
    return widget.maxLength;
  }
}
