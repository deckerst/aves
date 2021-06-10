import 'package:aves/services/services.dart';
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
            settings: const RouteSettings(name: StorageAccessPage.routeName),
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
  late Future<List<String>> _pathLoader;
  List<String>? _lastPaths;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _pathLoader = storageService.getGrantedDirectories();

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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(AIcons.info),
                  const SizedBox(width: 16),
                  Expanded(child: Text(context.l10n.settingsStorageAccessBanner)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _pathLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState != ConnectionState.done && _lastPaths == null) {
                    return const SizedBox.shrink();
                  }
                  _lastPaths = snapshot.data!..sort();
                  if (_lastPaths!.isEmpty) {
                    return EmptyContent(
                      text: context.l10n.settingsStorageAccessEmpty,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _lastPaths!
                        .map((path) => ListTile(
                              title: Text(path),
                              dense: true,
                              trailing: IconButton(
                                icon: const Icon(AIcons.clear),
                                onPressed: () async {
                                  await storageService.revokeDirectoryAccess(path);
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
