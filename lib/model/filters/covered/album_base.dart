import 'package:aves/model/filters/filters.dart';
import 'package:aves_model/aves_model.dart';

abstract class AlbumBaseFilter extends CollectionFilter {
  const AlbumBaseFilter({required super.reversed});

  bool match(String query);

  StorageVolume? get storageVolume;

  bool get canRename;

  bool get isVault;
}
