import 'package:aves/services/android_file_service.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';

class StorageAccessTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsStorageAccessTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: StorageAccessPage.routeName),
            builder: (context) => StorageAccessPage(),
          ),
        );
      },
    );
  }
}

class StorageAccessPage extends StatefulWidget {
  static const routeName = '/settings/storage_access';

  @override
  _StorageAccessPageState createState() => _StorageAccessPageState();
}

class _StorageAccessPageState extends State<StorageAccessPage> {
  Future<List<String>> _pathLoader;
  List<String> _lastPaths;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _pathLoader = AndroidFileService.getGrantedDirectories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsStorageAccessTitle),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(AIcons.info),
                  SizedBox(width: 16),
                  Expanded(child: Text(context.l10n.settingsStorageAccessBanner)),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _pathLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState != ConnectionState.done && _lastPaths == null) {
                    return SizedBox.shrink();
                  }
                  _lastPaths = snapshot.data..sort();
                  if (_lastPaths.isEmpty) {
                    return EmptyContent(
                      text: context.l10n.settingsStorageAccessEmpty,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _lastPaths
                        .map((path) => ListTile(
                              title: Text(path),
                              dense: true,
                              trailing: IconButton(
                                icon: Icon(AIcons.clear),
                                onPressed: () async {
                                  await AndroidFileService.revokeDirectoryAccess(path);
                                  _load();
                                  setState(() {});
                                },
                                tooltip: context.l10n.settingsStorageAccessRevokeTooltip,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
