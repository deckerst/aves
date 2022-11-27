import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';

class PathFilter extends CollectionFilter {
  static const type = 'path';

  // including trailing separator
  final String path;

  // without trailing separator
  final String _rootAlbum;

  late final EntryFilter _test;

  @override
  List<Object?> get props => [path, reversed];

  PathFilter(this.path, {super.reversed = false}) : _rootAlbum = path.substring(0, path.length - 1) {
    _test = (entry) {
      final dir = entry.directory;
      if (dir == null) return false;
      // avoid string building in most cases
      return dir.startsWith(_rootAlbum) && '$dir${pContext.separator}'.startsWith(path);
    };
  }

  factory PathFilter.fromMap(Map<String, dynamic> json) {
    return PathFilter(
      json['path'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'path': path,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => path;

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$path';
}
