// lib/features/onboarding/ui/widgets/pin_input_widget.dart (Enhanced)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class PinInputWidget extends StatefulWidget {
  const PinInputWidget({
    super.key,
    required this.pin,
    required this.onChanged,
    this.maxLength = 6,
    this.obscureText = true,
    this.errorText,
  });

  final String pin;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final bool obscureText;
  final String? errorText;

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List<FocusNode>.generate(widget.maxLength, (int index) => FocusNode());
    _controllers = List<TextEditingController>.generate(widget.maxLength, (int index) => TextEditingController());
    
    // Pre-fill controllers with existing PIN
    for (int i = 0; i < widget.pin.length && i < widget.maxLength; i++) {
      _controllers[i].text = widget.pin[i];
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePin() {
    final String pin = _controllers.map((TextEditingController c) => c.text).join();
    widget.onChanged(pin);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<Widget>.generate(widget.maxLength, (int index) {
            return Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: widget.errorText != null
                      ? theme.colorScheme.error
                      : _focusNodes[index].hasFocus
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                  width: 2,
                ),
                color: theme.colorScheme.surface,
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                obscureText: widget.obscureText,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (String value) {
                  if (value.isNotEmpty) {
                    if (index < widget.maxLength - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  }
                  _updatePin();
                },
                onTap: () {
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index].text.length),
                  );
                },
              ),
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  delay: Duration(milliseconds: index * 100),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(delay: Duration(milliseconds: index * 100));
          }),
        ),
        if (widget.errorText != null) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .shake(hz: 4, curve: Curves.easeInOut)
              .fadeIn(),
        ],
      ],
    );
  }
}
