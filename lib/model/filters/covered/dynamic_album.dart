import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

class DynamicAlbumFilter extends AlbumBaseFilter with CoveredFilter {
  static const type = 'dynamic_album';

  final String name;
  final CollectionFilter filter;

  @override
  List<Object?> get props => [name, filter, reversed];

  DynamicAlbumFilter(this.name, this.filter, {super.reversed = false});

  static DynamicAlbumFilter? fromMap(Map<String, dynamic> json) {
    final filter = CollectionFilter.fromJson(json['filter']);
    if (filter == null) return null;

    return DynamicAlbumFilter(
      json['name'],
      filter,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'filter': filter.toJson(),
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => filter.test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => name;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(AIcons.dynamicAlbum, size: size) : null;
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$name';

  @override
  bool match(String query) => name.toUpperCase().contains(query);

  @override
  StorageVolume? get storageVolume => null;

  @override
  bool get canRename => true;

  @override
  bool get isVault => false;
}
