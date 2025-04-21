import 'package:aves/model/filters/filters.dart';

abstract class AlbumBaseFilter extends CollectionFilter {
  const AlbumBaseFilter({required super.reversed});

  bool match(String query);

  bool get canRename;

  bool get isVault;
}
