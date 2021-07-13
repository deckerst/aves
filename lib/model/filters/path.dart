import 'package:aves/model/filters/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PathFilter extends CollectionFilter {
  static const type = 'path';

  final String path;

  const PathFilter(this.path);

  PathFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['path'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'path': path,
      };

  @override
  EntryFilter get test => (entry) => entry.directory?.startsWith(path) ?? false;

  @override
  String get universalLabel => path;

  @override
  String get category => type;

  @override
  String get key => '$type-$path';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is PathFilter && other.path == path;
  }

  @override
  int get hashCode => hashValues(type, path);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{path=$path}';
}
