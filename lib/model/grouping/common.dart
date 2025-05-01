import 'package:aves/services/common/services.dart';

class FilterGrouping {
  static const scheme = 'aves';
  static const _groupPath = '/group';
  static const _pathParamKey = 'path';

  static String? getGroupPath(Uri? uri) => uri?.queryParameters[_pathParamKey];

  static String? getGroupName(Uri? uri) {
    final path = getGroupPath(uri);
    return path != null ? pContext.split(path).lastOrNull : null;
  }

  static bool isGroupUri(Uri uri) => uri.path == FilterGrouping._groupPath;

  // parent group URI is `null` for root
  static Uri buildGroupUri(String host, Uri? parentGroupUri, String name) {
    if (parentGroupUri != null) {
      final path = getGroupPath(parentGroupUri);
      if (path != null) {
        return parentGroupUri.replace(
          queryParameters: {
            _pathParamKey: pContext.join(path, name),
          },
        );
      }
    }
    return Uri(
      scheme: scheme,
      host: host,
      path: _groupPath,
      queryParameters: {
        _pathParamKey: name,
      },
    );
  }

  // returns `null` for root
  static Uri? getParentGroup(Uri? groupUri) {
    if (groupUri != null) {
      final path = getGroupPath(groupUri);
      if (path != null) {
        final segments = pContext.split(path);
        final newLength = segments.length - 1;
        if (newLength > 0) {
          return groupUri.replace(
            queryParameters: {
              _pathParamKey: pContext.joinAll(segments.take(newLength)),
            },
          );
        }
      }
    }
    return null;
  }
}
