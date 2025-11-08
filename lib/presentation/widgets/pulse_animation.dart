import 'package:flutter/material.dart';

class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  final Widget child;
  final Duration duration;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      child: widget.child,
    );
  }
}
