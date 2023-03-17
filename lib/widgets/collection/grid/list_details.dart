import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/collection/grid/list_details_theme.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryListDetails extends StatelessWidget {
  final AvesEntry entry;

  const EntryListDetails({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final detailsTheme = context.watch<EntryListDetailsThemeData>();

    return Container(
      padding: EntryListDetailsTheme.contentPadding,
      foregroundDecoration: BoxDecoration(
        border: Border(top: AvesBorder.straightSide(context)),
      ),
      margin: EntryListDetailsTheme.contentMargin,
      child: IconTheme.merge(
        data: detailsTheme.iconTheme,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.bestTitle ?? context.l10n.viewerInfoUnknown,
              style: detailsTheme.titleStyle,
              softWrap: false,
              overflow: detailsTheme.titleMaxLines == 1 ? TextOverflow.fade : TextOverflow.ellipsis,
              maxLines: detailsTheme.titleMaxLines,
            ),
            const SizedBox(height: EntryListDetailsTheme.titleDetailPadding),
            if (detailsTheme.showDate) _buildDateRow(context, detailsTheme.captionStyle),
            if (detailsTheme.showLocation && entry.hasGps) _buildLocationRow(context, detailsTheme.captionStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<InlineSpan> spans, TextStyle style) {
    return Text.rich(
      TextSpan(
        children: spans,
      ),
      style: style,
      strutStyle: Constants.overflowStrutStyle,
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }

  WidgetSpan _buildIconSpan(IconData icon, {EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero}) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8, bottom: 1) + padding,
        child: Icon(icon),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, TextStyle style) {
    final locale = context.l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);
    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : Constants.overlayUnknown;

    final size = entry.sizeBytes;
    final sizeText = size != null ? formatFileSize(locale, size) : Constants.overlayUnknown;

    return _buildRow(
      [
        _buildIconSpan(AIcons.date),
        TextSpan(text: dateText),
        _buildIconSpan(AIcons.size, padding: const EdgeInsetsDirectional.only(start: 8)),
        TextSpan(text: sizeText),
      ],
      style,
    );
  }

  Widget _buildLocationRow(BuildContext context, TextStyle style) {
    final location = entry.hasAddress ? entry.shortAddress : settings.coordinateFormat.format(context.l10n, entry.latLng!);

    return _buildRow(
      [
        _buildIconSpan(AIcons.location),
        TextSpan(text: location),
      ],
      style,
    );
  }
}
