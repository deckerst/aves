import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/info/credential/assertions.dart';
import 'package:aves/widgets/viewer/info/credential/thumbnail.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const Manifest({
  super.key,
  required final AvesEntry entry,
  required final Map<String, Object?> json,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signatureInfo = json['signature_info'] as Map<String, Object?>?;
    if (signatureInfo == null) return const SizedBox();

    final signName = signatureInfo['common_name'] as String?;
    final signIssuer = signatureInfo['issuer'] as String?;
    final signedBy = (signName != null && signIssuer != null) ? '$signName ($signIssuer)' : null;

    var signDate = signatureInfo['time'] as String?;
    if (signDate != null) {
      final date = DateTime.tryParse(signDate);
      if (date != null) {
        final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);
        signDate = formatDateTime(date, settings.avesLocale, use24hour);
      }
    }

    final thumbnail = json['thumbnail'] as Map<String, Object?>?;
    final thumbnailUri = thumbnail != null ? thumbnail['identifier'] as String? : null;

    final assertions = (json['assertions'] as List?)?.cast<Map<String, Object?>>();
    var actionLine = '';
    var creativeLineByType = <String, String>{};
    if (assertions != null) {
      actionLine = assertions
          .expand<String?>((v) {
            final label = v['label'] as String?;
            switch (label) {
              case Assertions.actionsV2:
                final data = v['data'] as Map<String, Object?>?;
                if (data == null) return [];
                final actions = (data['actions'] as List?)?.cast<Map<String, Object?>>();
                if (actions == null) return [];
                return actions.map((v) {
                  final action = v['action'] as String?;
                  final source = v['digitalSourceType'] as String?;
                  if (action == null) return null;

                  if (DigitalSourceTypes.genAiSources.contains(source)) {
                    return '$action (AI)';
                  }
                  return action;
                });
              case Assertions.metadataC2pa:
              case Assertions.metadataCawg:
              case Assertions.metadataExif:
              case Assertions.metadataIptc:
                return [label];
              case Assertions.creativeWork:
              case Assertions.hashBmffV2:
              case Assertions.hashBmffV3:
              case Assertions.hashDataPart:
              case Assertions.hashMultiAsset:
              case Assertions.identity:
              case Assertions.softBinding:
              case Assertions.trainingMiningC2pa:
              case Assertions.trainingMiningCawg:
                // ignore
                return [];
              default:
                debugPrint('unhandled assertion label=$label');
            }
            return [];
          })
          .nonNulls
          .map((v) => v.replaceFirst(Assertions.actionPrefixPattern, '').toSentenceCase())
          .toSet()
          .toList()
          .join(AText.separator);

      final creativesByTypeMap = <String, Set<String>>{};
      assertions.forEach((v) {
        final label = v['label'] as String?;
        switch (label) {
          case Assertions.creativeWork:
            final data = v['data'] as Map<String, Object?>?;
            if (data == null) return;
            final authors = (data['author'] as List?)?.cast<Map<String, Object?>>();
            authors?.forEach((v) {
              final type = v['@type'] as String?;
              final name = v['name'] as String?;
              if (type != null && name != null) {
                creativesByTypeMap.putIfAbsent(type, () => {}).add(name);
              }
            });
        }
      });
      creativeLineByType = creativesByTypeMap.map((k, v) => MapEntry(k, v.toList().sorted().join(AText.separator)));
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final mainStyle = textTheme.bodyMedium!;
    final subColor = theme.colorScheme.onSurfaceVariant;
    final subStyle = mainStyle.copyWith(color: subColor);

    const double iconSize = 16;
    return Container(
      decoration: BoxDecoration(
        border: AvesBorder.border(context),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (signedBy != null) Text(signedBy, style: mainStyle),
                    if (signDate != null) Text(signDate, style: subStyle),
                  ],
                ),
              ),
              if (thumbnailUri != null)
                ManifestThumbnail(
                  entry: entry,
                  thumbnailUri: thumbnailUri,
                ),
            ],
          ),
          if (actionLine.isNotEmpty)
            Row(
              children: [
                Icon(AIcons.edit, size: iconSize, color: subColor),
                const SizedBox(width: 4),
                Expanded(child: Text(actionLine, style: mainStyle)),
              ],
            ),
          if (creativeLineByType.isNotEmpty)
            ...creativeLineByType.entries.map(
              (kv) {
                final type = kv.key;
                final creativeLine = kv.value;

                IconData? icon;
                switch (type) {
                  case CreativeWorkAuthorTypes.organization:
                    icon = AIcons.authorOrganization;
                  case CreativeWorkAuthorTypes.person:
                    icon = AIcons.authorPerson;
                }
                return Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: iconSize, color: subColor),
                      const SizedBox(width: 4),
                    ],
                    Expanded(child: Text(creativeLine, style: mainStyle)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
