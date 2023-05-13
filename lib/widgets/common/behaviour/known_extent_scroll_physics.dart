import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

// adapted from Flutter `FixedExtentScrollPhysics` in `/widgets/list_wheel_scroll_view.dart`
class KnownExtentScrollPhysics extends ScrollPhysics {
  final double Function(int index) indexToScrollOffset;
  final int Function(double offset) scrollOffsetToIndex;

  const KnownExtentScrollPhysics({
    required this.indexToScrollOffset,
    required this.scrollOffsetToIndex,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  KnownExtentScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return KnownExtentScrollPhysics(
      indexToScrollOffset: indexToScrollOffset,
      scrollOffsetToIndex: scrollOffsetToIndex,
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final ScrollMetrics metrics = position;

    // Scenario 1:
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at the scrollable's boundary.
    if ((velocity <= 0.0 && metrics.pixels <= metrics.minScrollExtent) || (velocity >= 0.0 && metrics.pixels >= metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen
    // naturally without settling onto items.
    final Simulation? testFrictionSimulation = super.createBallisticSimulation(metrics, velocity);

    // Scenario 2:
    // If it was going to end up past the scroll extent, defer back to the
    // parent physics' ballistics again which should put us on the scrollable's
    // boundary.
    if (testFrictionSimulation != null && (testFrictionSimulation.x(double.infinity) == metrics.minScrollExtent || testFrictionSimulation.x(double.infinity) == metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // From the natural final position, find the nearest item it should have
    // settled to.
    final offset = (testFrictionSimulation?.x(double.infinity) ?? metrics.pixels).clamp(metrics.minScrollExtent, metrics.maxScrollExtent);
    final int settlingItemIndex = scrollOffsetToIndex(offset);
    final double settlingPixels = indexToScrollOffset(settlingItemIndex);

    // Scenario 3:
    // If there's no velocity and we're already at where we intend to land,
    // do nothing.
    if (velocity.abs() < toleranceFor(position).velocity && (settlingPixels - metrics.pixels).abs() < toleranceFor(position).distance) {
      return null;
    }

    // Scenario 4:
    // If we're going to end back at the same item because initial velocity
    // is too low to break past it, use a spring simulation to get back.
    if (settlingItemIndex == scrollOffsetToIndex(metrics.pixels)) {
      return SpringSimulation(
        spring,
        metrics.pixels,
        settlingPixels,
        velocity,
        tolerance: toleranceFor(position),
      );
    }

    // Scenario 5:
    // Create a new friction simulation except the drag will be tweaked to land
    // exactly on the item closest to the natural stopping point.
    return FrictionSimulation.through(
      metrics.pixels,
      settlingPixels,
      velocity,
      toleranceFor(position).velocity * velocity.sign,
    );
  }
}
