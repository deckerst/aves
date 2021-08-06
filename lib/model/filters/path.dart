import 'package:aves/model/filters/filters.dart';

class PathFilter extends CollectionFilter {
  static const type = 'path';

  final String path;

  @override
  List<Object?> get props => [path];

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
}
