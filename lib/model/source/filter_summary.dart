import 'package:aves/model/entry/entry.dart';

class FilterSummary({
  required final int entryCount,
  required final int size,
  required final AvesEntry? recentEntry,
}) {
  static FilterSummary empty = FilterSummary(entryCount: 0, size: 0, recentEntry: null);
}
