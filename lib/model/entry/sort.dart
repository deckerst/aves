import 'package:aves/model/entry/entry.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:collection/collection.dart';

class AvesEntrySort {
  // compare by:
  // 1) title ascending
  // 2) extension ascending
  static int compareByName(AvesEntry a, AvesEntry b) {
    final c = compareAsciiUpperCaseNatural(a.bestTitle ?? '', b.bestTitle ?? '');
    return c != 0 ? c : compareAsciiUpperCase(a.extension ?? '', b.extension ?? '');
  }

  // compare by:
  // 1) date descending
  // 2) name descending
  static int compareByDate(AvesEntry a, AvesEntry b) {
    var c = (b.bestDate ?? epoch).compareTo(a.bestDate ?? epoch);
    if (c != 0) return c;
    return compareByName(b, a);
  }

  // compare by:
  // 1) rating descending
  // 2) date descending
  static int compareByRating(AvesEntry a, AvesEntry b) {
    final c = b.rating.compareTo(a.rating);
    return c != 0 ? c : compareByDate(a, b);
  }

  // compare by:
  // 1) size descending
  // 2) date descending
  static int compareBySize(AvesEntry a, AvesEntry b) {
    final c = (b.sizeBytes ?? 0).compareTo(a.sizeBytes ?? 0);
    return c != 0 ? c : compareByDate(a, b);
  }

  // compare by:
  // 1) duration descending
  // 2) date descending
  static int compareByDuration(AvesEntry a, AvesEntry b) {
    final c = (b.durationMillis ?? 0).compareTo(a.durationMillis ?? 0);
    return c != 0 ? c : compareByDate(a, b);
  }

  // compare by:
  // 1) path ascending
  static int compareByPath(AvesEntry a, AvesEntry b) {
    return compareAsciiUpperCase(a.path ?? '', b.path ?? '');
  }
}
