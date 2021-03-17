import 'package:aves/model/availability.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAvesAvailability extends Fake implements AvesAvailability {
  @override
  Future<bool> get canLocatePlaces => SynchronousFuture(false);
}
