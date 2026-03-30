import 'package:flutter/foundation.dart';

// mixins that need disposal should be constrained to apply on this class
// cf https://github.com/dart-lang/sdk/issues/53416
// cf https://github.com/dart-lang/sdk/issues/53549
// cf https://github.com/dart-lang/language/issues/3323
abstract class Disposer {
  @mustCallSuper
  void dispose() {
    // No-op.
  }
}