import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';


class KeypadButton extends StatefulWidget {
  const KeypadButton({super.key,
    this.text,
    this.icon,
    required this.onPressed, required this.isSpecial, required this.animationDelay,
  }) : assert(text != null || icon != null, 'Either text or icon must be provided');

  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSpecial;
  final Duration animationDelay;

  static const double defaultHeight = 64.0;
  static const double defaultWidth = 64.0;

  @override
  State<KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<KeypadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runTapAnimation() {
    _controller
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              _runTapAnimation();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          height: KeypadButton.defaultHeight,
          width: KeypadButton.defaultWidth,
          decoration: BoxDecoration(
            color: widget.isSpecial
                ? (isEnabled
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : theme.colorScheme.surface.withOpacity(0.5))
                : (isEnabled
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surface.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: isEnabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.text != null
                ? Text(
                    widget.text!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: 28,
                    color: widget.isSpecial
                        ? (isEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withOpacity(0.38))
                        : (isEnabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.38)),
                  ),
          ),
        ),
      ),
    ).animate(delay: widget.animationDelay)
     .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
     .fadeIn();
  }
}
