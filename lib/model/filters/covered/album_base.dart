import 'package:aves/model/filters/filters.dart';

// TODO TLAD [nested] convert to mixin or remove
abstract class AlbumBaseFilter extends CollectionFilter {
  const AlbumBaseFilter({required super.reversed});

  bool match(String query);
}
