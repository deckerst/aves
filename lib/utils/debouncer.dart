import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration delay;

  Timer? _timer;

  new({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}
