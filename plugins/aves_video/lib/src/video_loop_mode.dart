import 'package:aves_model/aves_model.dart';

extension ExtraVideoLoopMode on VideoLoopMode {
  static const shortVideoThreshold = Duration(seconds: 30);

  bool shouldLoop(AvesEntryBase entry) {
    if (entry.isAnimated) return true;

    switch (this) {
      case .never:
        return false;
      case .shortOnly:
        final durationMillis = entry.durationMillis;
        return durationMillis != null ? durationMillis < shortVideoThreshold.inMilliseconds : false;
      case .always:
        return true;
    }
  }
}
