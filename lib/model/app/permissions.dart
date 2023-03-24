import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static const storage = [
    Permission.storage,
    // for media access on Android >=13
    Permission.photos,
    Permission.videos,
  ];

  static const mediaAccess = [
    ...storage,
    // to access media with unredacted metadata with scoped storage (Android >=10)
    Permission.accessMediaLocation,
  ];
}
