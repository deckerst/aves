import 'package:flutter/foundation.dart';

// `ChangeNotifier` wrapper so that it can be used anywhere, not just as a mixin
class AChangeNotifier extends ChangeNotifier {
  void notify() {
    // why is this protected?
    super.notifyListeners();
  }
}
