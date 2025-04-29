import 'package:aves/services/common/services.dart';

class FilterGrouping {
  static const scheme = 'aves';
  static const groupPath = '/group';
  static const _pathParamKey = 'path';

  static String? getGroupPath(Uri? uri) => uri?.queryParameters[_pathParamKey];

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
      path: groupPath,
      queryParameters: {
        _pathParamKey: name,
      },
    );
  }

  // return `null` for root
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
