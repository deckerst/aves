import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DebugPage extends StatefulWidget {
  final List<ImageEntry> entries;

  const DebugPage({this.entries});

  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  Future<List<CatalogMetadata>> _dbMetadataLoader;
  Future<List<AddressDetails>> _dbAddressLoader;

  List<ImageEntry> get entries => widget.entries;

  @override
  void initState() {
    super.initState();
    _dbMetadataLoader = metadataDb.loadMetadataEntries();
    _dbAddressLoader = metadataDb.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<ImageEntry>> byMimeTypes = groupBy(entries, (entry) => entry.mimeType);
    final catalogued = entries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final located = withGps.where((entry) => entry.isLocated);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Info'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paths'),
            Text('DCIM path: ${androidFileUtils.dcimPath}'),
            Text('pictures path: ${androidFileUtils.picturesPath}'),
            const Divider(),
            const Text('Settings'),
            Text('collectionGroupFactor: ${settings.collectionGroupFactor}'),
            Text('collectionSortFactor: ${settings.collectionSortFactor}'),
            Text('infoMapZoom: ${settings.infoMapZoom}'),
            const Divider(),
            Text('Entries: ${entries.length}'),
            ...byMimeTypes.keys.map((mimeType) => Text('- $mimeType: ${byMimeTypes[mimeType].length}')),
            Text('Catalogued: ${catalogued.length}'),
            Text('With GPS: ${withGps.length}'),
            Text('With address: ${located.length}'),
            const Divider(),
            RaisedButton(
              onPressed: () => metadataDb.reset(),
              child: const Text('Reset DB'),
            ),
            FutureBuilder(
              future: _dbMetadataLoader,
              builder: (futureContext, AsyncSnapshot<List<CatalogMetadata>> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                return Text('DB metadata rows: ${snapshot.data.length}');
              },
            ),
            FutureBuilder(
              future: _dbAddressLoader,
              builder: (futureContext, AsyncSnapshot<List<AddressDetails>> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                return Text('DB address rows: ${snapshot.data.length}');
              },
            ),
            const Divider(),
            const Text('Time dilation'),
            Slider(
              value: timeDilation,
              onChanged: (v) => setState(() => timeDilation = v),
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: '$timeDilation',
            ),
          ],
        ),
      ),
    );
  }
}
