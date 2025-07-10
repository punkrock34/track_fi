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
    
    _updateControllersFromPin();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNextEmpty();
    });
  }

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pin != widget.pin) {
      _updateControllersFromPin();
    }
  }

  void _updateControllersFromPin() {
    for (int i = 0; i < widget.maxLength; i++) {
      _controllers[i].text = i < widget.pin.length ? widget.pin[i] : '';
    }
  }

  void _focusNextEmpty() {
    for (int i = 0; i < widget.maxLength; i++) {
      if (_controllers[i].text.isEmpty) {
        _focusNodes[i].requestFocus();
        return;
      }
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

  void _onFieldChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.maxLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _updatePin();
  }

  bool _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        _updatePin();
        return true;
      } else if (_controllers[index].text.isNotEmpty) {
        _controllers[index].clear();
        _updatePin();
        return true;
      }
    }
    return false;
  }

  void _onFieldTapped(int index) {
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: _controllers[index].text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasError = widget.errorText != null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<Widget>.generate(widget.maxLength, (int index) {
            final bool hasFocus = _focusNodes[index].hasFocus;
            final bool hasValue = _controllers[index].text.isNotEmpty;
            
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: hasError
                      ? theme.colorScheme.error
                      : hasFocus
                          ? theme.colorScheme.primary
                          : hasValue
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.outline,
                  width: hasFocus || hasError ? 2 : 1,
                ),
                color: hasValue
                    ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                    : theme.colorScheme.surface,
                boxShadow: hasFocus
                    ? <BoxShadow>[
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: <Widget>[
                  // The actual TextField (always there for input handling)
                  KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (KeyEvent event) => _onKeyEvent(event, index),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.obscureText && hasValue
                            ? Colors.transparent  // Hide text when obscured
                            : (hasValue ? theme.colorScheme.primary : null),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (String value) => _onFieldChanged(value, index),
                      onTap: () => _onFieldTapped(index),
                    ),
                  ),
                  
                  // Custom centered dot overlay when obscured
                  if (widget.obscureText && hasValue)
                    Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            )
                .animate()
                .slideY(
                  begin: 0.3,
                  delay: Duration(milliseconds: index * 50),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(delay: Duration(milliseconds: index * 50));
          }),
        ),
        
        // Length indicator
        const Gap(DesignTokens.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${widget.pin.length}/${widget.maxLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.pin.length >= 4) ...<Widget>[
              const Gap(DesignTokens.spacingXs),
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
        
        if (hasError) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingSm,
              vertical: DesignTokens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const Gap(DesignTokens.spacingXs),
                Text(
                  widget.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .shake(hz: 4, curve: Curves.easeInOut)
              .fadeIn(),
        ],
      ],
    );
  }
}
