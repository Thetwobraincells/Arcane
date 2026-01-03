import 'package:flutter/material.dart';

/// A button widget that expands and pops on hover
class HoverButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final double hoverScale;
  final Duration animationDuration;

  const HoverButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.hoverScale = 1.05,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: widget.style,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A hover button specifically for icon buttons
class HoverIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final double hoverScale;

  const HoverIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.hoverScale = 1.2,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
          color: widget.color,
        ),
      ),
    );
  }
}

