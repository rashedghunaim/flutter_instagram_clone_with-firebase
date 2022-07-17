import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final bool alwaysAnimate;

  final VoidCallback? onEnd;
  const LikeAnimation({
    Key? key,
    required this.child,
    this.alwaysAnimate = false , 
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
   
  }) : super(key: key);

  @override
  _LikeAnimationState createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    );
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  startAnimation() async {
    if (widget.isAnimating || widget.alwaysAnimate) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(
        Duration(milliseconds: 400),
      );
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
