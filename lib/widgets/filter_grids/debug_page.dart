import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/storage_permission_service.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:material_ui/material_ui.dart';

class FilterDebugPage extends StatefulWidget {
  static const routeName = '/filter_debug';

  final CollectionFilter filter;

  const new({
    super.key,
    required this.filter,
  });

  @override
  State<FilterDebugPage> createState() => _FilterDebugPageState();
}

class _FilterDebugPageState extends State<FilterDebugPage> {
  CollectionFilter get filter => widget.filter;
  Future<List<StorageApi>?>? _storageApiLoader;

  @override
  void initState() {
    super.initState();
    final _filter = filter;
    if (_filter is StoredAlbumFilter) {
      _storageApiLoader = storagePermissionService.getEditionApis({_filter.album}, insertion: false).then((v) {
        return v.entries.firstOrNull?.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoRowGroup(
              info: filter.toJsonMap().map((k, v) => MapEntry(k, v.toString())),
            ),
            const Divider(),
            FutureBuilder<List<StorageApi>?>(
              future: _storageApiLoader,
              builder: (context, snapshot) {
                final apis = snapshot.data;
                if (apis == null) return const SizedBox();
                return InfoRowGroup(
                  info: {
                    'Storage APIs': apis.map((v) => v.name).join(', '),
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
