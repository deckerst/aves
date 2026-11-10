import 'dart:typed_data';

import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_debug_service.dart';
import 'package:aves/widgets/common/basic/keep_alive.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:material_ui/material_ui.dart';

class const ThumbnailsTab({
  super.key,
  required final AvesEntry entry,
}) extends StatefulWidget {
  @override
  State<ThumbnailsTab> createState() => _ThumbnailsTabState();
}

class _ThumbnailsTabState extends State<ThumbnailsTab> {
  late final Future<List<MapEntry<ThumbnailMethod, Uint8List?>>> _byMethodLoader;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    final providerKey = ThumbnailProviderKey(
      uri: entry.uri,
      mimeType: entry.mimeType,
      pageId: entry.pageId,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      dateModifiedMillis: entry.dateModifiedMillis ?? -1,
      videoThumbnailMethods: entry.isVideo ? settings.videoThumbnailMethods : null,
    );
    _byMethodLoader = Future.wait(
      ThumbnailMethod.values.map((method) async {
        final bytes = await AndroidDebugService.getThumbnail(providerKey, method);
        return MapEntry(method, bytes);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        AKeepAlive(
          child: AvesExpansionTile(
            title: 'Cached',
            locale: KnownLocale.english,
            children: entry.cachedThumbnails
                .expand(
                  (provider) => [
                    Text('Thumb extent: ${provider.key.extent}'),
                    Image(image: provider),
                    const SizedBox(height: 16),
                  ],
                )
                .toList(),
          ),
        ),
        AKeepAlive(
          child: FutureBuilder<List<MapEntry<ThumbnailMethod, Uint8List?>>>(
            future: _byMethodLoader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

              final result = snapshot.data!;

              return AvesExpansionTile(
                title: 'By method',
                locale: KnownLocale.english,
                children: result.expand((kv) {
                  final method = kv.key;
                  final bytes = kv.value;
                  return <Widget>[
                    Text('$method'),
                    if (bytes != null) Image.memory(bytes) else const Text('null'),
                  ];
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
