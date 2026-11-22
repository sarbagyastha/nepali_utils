import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// A filled Material shape that morphs, with an expressive spring, whenever
/// [shape] changes.
class const MorphingShape({
  /// The shape to show, usually one of [MaterialShapes].
  required final RoundedPolygon shape,
  required final Color color,
  final double size = 56,

  /// Shown, unrotated, in the middle of the shape.
  final Widget? child,
  final SpringDescription spring = Springs.expressiveDefaultSpatial,
  super.key,
}) extends StatefulWidget {
  @override
  State<MorphingShape> createState() => _MorphingShapeState();
}

class _MorphingShapeState extends State<MorphingShape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  late RoundedPolygon _from = widget.shape;
  late RoundedPolygon _to = widget.shape;

  @override
  void didUpdateWidget(MorphingShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape == widget.shape) return;
    _from = _to;
    _to = widget.shape;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.animateWith(SpringSimulation(widget.spring, 0, 1, 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final border = ShapeBorder.lerp(
            MaterialShapeBorder(shape: _from),
            MaterialShapeBorder(shape: _to),
            t.clamp(0, 1),
          )!;
          // The spring overshoots past 1, which gives the shape a little
          // bounce in size and a twist.
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: (1 - t) * math.pi / 2,
                child: Transform.scale(
                  scale: 0.8 + 0.2 * t,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: widget.color,
                      shape: border,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              ?child,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
