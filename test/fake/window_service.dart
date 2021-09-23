import 'package:aves/services/window_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWindowService extends Fake implements WindowService {
  @override
  Future<void> keepScreenOn(bool on) => SynchronousFuture(null);

  @override
  Future<bool> isRotationLocked() => SynchronousFuture(false);

  @override
  Future<void> requestOrientation([Orientation? orientation]) => SynchronousFuture(null);

  @override
  Future<bool> canSetCutoutMode() => SynchronousFuture(true);

  @override
  Future<void> setCutoutMode(bool use) => SynchronousFuture(null);
}
