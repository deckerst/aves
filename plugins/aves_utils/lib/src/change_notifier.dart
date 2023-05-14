import 'package:flutter/foundation.dart';

// `ChangeNotifier` wrapper to call `notify` without constraint
class AChangeNotifier extends ChangeNotifier {
  void notify() {
    // why is this protected?
    super.notifyListeners();
  }
}
