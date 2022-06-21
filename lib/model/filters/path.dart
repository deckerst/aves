import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';

class PathFilter extends CollectionFilter {
  static const type = 'path';

  // including trailing separator
  final String path;

  // without trailing separator
  final String _rootAlbum;

  @override
  List<Object?> get props => [path];

  PathFilter(this.path) : _rootAlbum = path.substring(0, path.length - 1);

  factory PathFilter.fromMap(Map<String, dynamic> json) {
    return PathFilter(
      json['path'],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'path': path,
      };

  @override
  EntryFilter get test => (entry) {
        final dir = entry.directory;
        if (dir == null) return false;
        // avoid string building in most cases
        return dir.startsWith(_rootAlbum) && '$dir${pContext.separator}'.startsWith(path);
      };

  @override
  String get universalLabel => path;

  @override
  String get category => type;

  @override
  String get key => '$type-$path';
}
