class ViewerDebugUtils {
  static String toDateValue(int? time, {int factor = 1, bool isUtc = false}) {
    var value = '$time';
    if (time != null && time > 0) {
      try {
        value += ' (${DateTime.fromMillisecondsSinceEpoch(time * factor, isUtc: isUtc)})';
      } catch (error) {
        value += ' (invalid DateTime})';
      }
    }
    return value;
  }
}
