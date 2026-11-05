import 'dart:collection';
import 'dart:convert';

import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/metadata/cards/json.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const C2paDirTileBody({
  super.key,
  required final SplayTreeMap<String, String> tags,
}) extends StatelessWidget {
  static const _resourceUriPrefix = 'self#jumbf';

  @override
  Widget build(BuildContext context) {
    final jsonString = tags['json'];
    if (jsonString == null) return const SizedBox();

    final content = jsonDecode(jsonString) as Map<String, Object?>;
    final subKeys = content.entries.where((kv) => JsonCard.isMapOrMapList(kv.value)).map((kv) => kv.key).toList().sorted();

    return Column(
      crossAxisAlignment: .start,
      children: [
        InfoRowGroup(
          info: Map.fromEntries(
            content.entries.whereNot((kv) => subKeys.contains(kv.key)).map((kv) => MapEntry(JsonCard.formatKey(kv.key), kv.value.toString())),
          ),
        ),
        ...subKeys
            .map((key) {
              return JsonCard(
                titleKey: key,
                content: content[key],
                getLinkHandlers: _getLinkHandlers,
                padding: const EdgeInsets.only(top: 8),
              );
            })
            .whereNot((v) => v is SizedBox),
      ],
    );
  }

  static Map<String, InfoValueSpanBuilder> _getLinkHandlers(SplayTreeMap<String, String> tags) {
    return Map.fromEntries(
      tags.entries.where((kv) => kv.value.startsWith(_resourceUriPrefix)).map((kv) {
        final resourceUri = kv.value;
        final lastSeparator = resourceUri.lastIndexOf('/');
        final lastSegment = lastSeparator != -1 ? resourceUri.substring(lastSeparator + 1).replaceFirst('c2pa.', '') : null;
        return MapEntry(
          kv.key,
          InfoRowGroup.linkSpanBuilder(
            linkText: (context) {
              var linkText = context.l10n.viewerInfoOpenLinkText;
              if (lastSegment != null) {
                linkText += ' $lastSegment';
              }
              return linkText;
            },
            onTap: (context) => OpenEmbeddedDataNotification.c2paResource(dataUri: resourceUri).dispatch(context),
          ),
        );
      }),
    );
  }
}
