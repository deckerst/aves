import 'package:aves/model/filters/filters.dart';

mixin ContainerFilter<T extends CollectionFilter> on CollectionFilter {
  Set<CollectionFilter> get innerFilters;

  bool containsFilter(CollectionFilterPredicate test) {
    return innerFilters.any(test) || innerFilters.whereType<ContainerFilter>().any((v) => v.containsFilter(test));
  }

  T? replaceFilters(CollectionFilter? Function(CollectionFilter oldFilter) toElement);
}
