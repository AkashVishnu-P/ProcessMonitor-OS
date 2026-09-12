import 'package:flutter/material.dart';

class PulseStateIndicator extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color pulseColor;

  const PulseStateIndicator({
    super.key,
    required this.child,
    this.isActive = true,
    this.pulseColor = Colors.green,
  });

  @override
  State<PulseStateIndicator> createState() => _PulseStateIndicatorState();
}

class _PulseStateIndicatorState extends State<PulseStateIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withValues(alpha: _opacityAnimation.value),
                blurRadius: 10 * _scaleAnimation.value,
                spreadRadius: 2 * _scaleAnimation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
