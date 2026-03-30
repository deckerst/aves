class ViewerDebugUtils {
  static String toDateValue(int? time, {int factor = 1}) {
    var value = '$time';
    if (time != null && time > 0) {
      try {
        value += ' (${DateTime.fromMillisecondsSinceEpoch(time * factor)})';
      } catch (error) {
        value += ' (invalid DateTime})';
      }
    }
    return value;
  }
}
