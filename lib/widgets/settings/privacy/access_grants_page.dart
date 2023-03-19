import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';

class StorageAccessPage extends StatefulWidget {
  static const routeName = '/settings/storage_access';

  const StorageAccessPage({super.key});

  @override
  State<StorageAccessPage> createState() => _StorageAccessPageState();
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
    return AvesScaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsStorageAccessPageTitle),
      ),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
          future: _pathLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState != ConnectionState.done && _lastPaths == null) {
              return const SizedBox();
            }
            _lastPaths = snapshot.data!..sort();
            if (_lastPaths!.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const Divider(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: EmptyContent(
                        text: context.l10n.settingsStorageAccessEmpty,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              children: [
                const _Header(),
                const Divider(),
                ..._lastPaths!.map((path) => ListTile(
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
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const FontSizeIconTheme(child: Icon(AIcons.info)),
          const SizedBox(width: 16),
          Expanded(child: Text(context.l10n.settingsStorageAccessBanner)),
        ],
      ),
    );
  }
}
