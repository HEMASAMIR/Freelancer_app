import 'package:flutter/material.dart';

class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AnimatedPressButton({required this.child, required this.onTap});

  @override
  State<AnimatedPressButton> createState() => AnimatedPressButtonState();
}

class AnimatedPressButtonState extends State<AnimatedPressButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
