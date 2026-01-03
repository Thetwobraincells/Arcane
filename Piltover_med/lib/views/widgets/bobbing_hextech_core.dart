import 'package:flutter/material.dart';

class BobbingHextechCore extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;

  const BobbingHextechCore({
    super.key, 
    this.width = 60,
    this.height = 60,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<BobbingHextechCore> createState() => _BobbingHextechCoreState();
}

class _BobbingHextechCoreState extends State<BobbingHextechCore> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/hextechcore.png',
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
