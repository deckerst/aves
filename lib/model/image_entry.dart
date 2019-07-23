class ImageEntry {
  static DateTime getBestDate(Map entry) {
    final dateTakenMillis = entry['sourceDateTakenMillis'] as int;
    if (dateTakenMillis != null && dateTakenMillis > 0) return DateTime.fromMillisecondsSinceEpoch(dateTakenMillis);

    final dateModifiedSecs = entry['dateModifiedSecs'] as int;
    if (dateModifiedSecs != null && dateModifiedSecs > 0) return DateTime.fromMillisecondsSinceEpoch(dateModifiedSecs * 1000);

    return null;
  }

  static DateTime getDayTaken(Map entry) {
    final d = getBestDate(entry);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }
}
