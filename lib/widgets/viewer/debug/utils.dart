class ViewerDebugUtils {
  static String toDateValue(int? time, {int factor = 1, bool isUtc = false}) {
    String value;
    if (time != null && time > 0) {
      try {
        value = '${DateTime.fromMillisecondsSinceEpoch(time * factor, isUtc: isUtc)} ($time)';
      } catch (error) {
        value = '$time (invalid DateTime})';
      }
    } else {
      value = '$time';
    }
    return value;
  }
}
