import 'package:aves/services/window_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:test/fake.dart';

class FakeWindowService extends Fake implements WindowService {
  @override
  Future<bool> isActivity() => SynchronousFuture(true);

  @override
  Future<void> keepScreenOn(bool on) => SynchronousFuture(null);

  @override
  Future<bool> isRotationLocked() => SynchronousFuture(false);

  @override
  Future<void> requestOrientation([Orientation? orientation]) => SynchronousFuture(null);

  @override
  Future<bool> isCutoutAware() => SynchronousFuture(true);

  @override
  Future<void> setCutoutMode(bool use) => SynchronousFuture(null);

  @override
  Future<EdgeInsets> getCutoutInsets() => SynchronousFuture(EdgeInsets.zero);
}
