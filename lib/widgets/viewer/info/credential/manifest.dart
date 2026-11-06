import 'dart:collection';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/info/credential/assertions.dart';
import 'package:aves/widgets/viewer/info/credential/thumbnail.dart';
import 'package:material_ui/material_ui.dart';

class const Manifest({
  super.key,
  required final AvesEntry entry,
  required final Map<String, Object?> json,
  required final double thumbnailExtent,
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
    var actions = '';
    if (assertions != null) {
      actions = assertions
          .where((v) => v['label'] == Assertions.actionsV2)
          .expand((v) {
            final data = v['data'] as Map<String, Object?>?;
            if (data == null) return [];
            final actions = (data['actions'] as List?)?.cast<Map<String, Object?>>();
            if (actions == null) return [];
            return actions.map((v) => v['action'] as String?).nonNulls.map((v) => v.replaceFirst('c2pa.', '').toSentenceCase()).toSet().toList();
          })
          .join(AText.separator);
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final mainStyle = textTheme.bodyMedium!;
    final subStyle = mainStyle.copyWith(color: theme.colorScheme.onSurfaceVariant);

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
                  thumbnailExtent: thumbnailExtent,
                ),
            ],
          ),
          if (actions.isNotEmpty) Text(actions, style: mainStyle),
        ],
      ),
    );
  }
}
