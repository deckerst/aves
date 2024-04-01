import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ABRepeat {
  final int? start, end;

  ABRepeat({this.start, this.end});

  ABRepeat sanitize() {
    if (start != null && end != null && start! > end!) {
      return ABRepeat(start: end, end: start);
    }
    return ABRepeat(start: start, end: end);
  }

  int clamp(int position) => (start != null && end != null) ? position.clamp(start!, end!) : position;
}

mixin ABRepeatMixin {
  int get currentPosition;

  ValueNotifier<ABRepeat?> abRepeatNotifier = ValueNotifier(null);

  void toggleABRepeat() => _setAbRepeat(abRepeatNotifier.value != null ? null : ABRepeat());

  void resetABRepeat() => _setAbRepeat(ABRepeat());

  void setABRepeatStart() => _setAbRepeat(ABRepeat(start: currentPosition, end: abRepeatNotifier.value?.end));

  void setABRepeatEnd() => _setAbRepeat(ABRepeat(start: abRepeatNotifier.value?.start, end: currentPosition));

  void _setAbRepeat(ABRepeat? v) => abRepeatNotifier.value = v?.sanitize();
}
