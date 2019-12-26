import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/album/all_collection_drawer.dart';
import 'package:aves/widgets/album/all_collection_page.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/media_store_collection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen/screen.dart';

void main() {
  runApp(AvesApp());
}

class AvesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aves',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.indigoAccent,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            title: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Concourse Caps',
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _appSetup;

  @override
  void initState() {
    debugPrint('$runtimeType initState');
    super.initState();
    _appSetup = _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
    Screen.keepOn(true);
  }

  Future<void> _setup() async {
    debugPrint('$runtimeType _setup');
    // TODO reduce permission check time
    // TODO TLAD ask android.permission.ACCESS_MEDIA_LOCATION (unredacted EXIF with scoped storage)
    final permissions = await PermissionHandler().requestPermissions([
      PermissionGroup.storage,
    ]); // 350ms
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      unawaited(SystemNavigator.pop());
      return;
    }

    androidFileUtils.init();
    // TODO notify when icons are ready for drawer and section header refresh
    unawaited(IconUtils.init()); // 170ms

    await settings.init(); // <20ms
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: FutureBuilder(
          future: _appSetup,
          builder: (context, AsyncSnapshot<void> snapshot) {
            if (snapshot.hasError) return const Icon(Icons.error);
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            debugPrint('$runtimeType FutureBuilder builder');
            return const MediaStoreCollectionPage();
          }),
    );
  }
}

class MediaStoreCollectionPage extends StatelessWidget {
  const MediaStoreCollectionPage();

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType build');
    return const MediaStoreCollectionProvider(
      child: Scaffold(
        body: AllCollectionPage(),
        drawer: AllCollectionDrawer(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
