import 'dart:async';
import 'dart:ui';

import 'package:aves/widgets/editor/transform/crop_region.dart';
import 'package:aves/widgets/editor/transform/transformation.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

class TransformController {
  ValueNotifier<CropAspectRatio> aspectRatioNotifier = ValueNotifier(CropAspectRatio.free);

  TransformActivity _activity = TransformActivity.none;

  TransformActivity get activity => _activity;

  Transformation _transformation = Transformation.zero;

  Transformation get transformation => _transformation;

  bool get modified => _transformation != Transformation.zero;

  final StreamController<Transformation> _transformationStreamController = StreamController.broadcast();

  Stream<Transformation> get transformationStream => _transformationStreamController.stream;

  final StreamController<TransformEvent> _eventStreamController = StreamController.broadcast();

  Stream<TransformEvent> get eventStream => _eventStreamController.stream;

  static const double straightenDegreesMin = -45;
  static const double straightenDegreesMax = 45;

  final Size displaySize;

  TransformController(this.displaySize) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$TransformController',
        object: this,
      );
    }
    reset();
    aspectRatioNotifier.addListener(_onAspectRatioChanged);
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    aspectRatioNotifier.dispose();
  }

  void reset() {
    _transformation = Transformation.zero.copyWith(
      region: CropRegion.fromRect(Offset.zero & displaySize),
    );
    _transformationStreamController.add(_transformation);
  }

  void flipHorizontally() {
    _transformation = _transformation.copyWith(
      orientation: _transformation.orientation.flipHorizontally(),
      straightenDegrees: -transformation.straightenDegrees,
    );
    _transformationStreamController.add(_transformation);
  }

  void rotateClockwise() {
    _transformation = _transformation.copyWith(
      orientation: _transformation.orientation.rotateClockwise(),
    );
    _transformationStreamController.add(_transformation);
  }

  set straightenDegrees(double straightenDegrees) {
    _transformation = _transformation.copyWith(
      straightenDegrees: straightenDegrees.clamp(straightenDegreesMin, straightenDegreesMax),
    );
    _transformationStreamController.add(_transformation);
  }

  set cropRegion(CropRegion region) {
    _transformation = _transformation.copyWith(
      region: region,
    );
    _transformationStreamController.add(_transformation);
  }

  set activity(TransformActivity activity) {
    _activity = activity;
    _eventStreamController.add(TransformEvent(activity: _activity));
  }

  void _onAspectRatioChanged() {
    // TODO TLAD [crop] apply
  }
}
