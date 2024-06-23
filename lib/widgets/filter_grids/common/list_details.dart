import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/filter_grids/common/list_details_theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterListDetails<T extends CollectionFilter> extends StatelessWidget {
  final FilterGridItem<T> gridItem;
  final bool pinned, locked;

  T get filter => gridItem.filter;

  AvesEntry? get entry => gridItem.entry;

  const FilterListDetails({
    super.key,
    required this.gridItem,
    required this.pinned,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final detailsTheme = context.watch<FilterListDetailsThemeData>();

    final leading = filter.iconBuilder(context, detailsTheme.titleIconSize, showGenericIcon: false);
    final hasTitleLeading = leading != null;

    return Container(
      padding: FilterListDetailsTheme.contentPadding,
      foregroundDecoration: BoxDecoration(
        border: Border(top: AvesBorder.straightSide(context)),
      ),
      margin: FilterListDetailsTheme.contentMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (hasTitleLeading)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: FilterListDetailsTheme.titleIconPadding),
                      child: IconTheme(
                        data: IconThemeData(color: detailsTheme.titleStyle.color),
                        child: leading,
                      ),
                    ),
                  ),
                TextSpan(
                  text: filter.getLabel(context),
                  style: detailsTheme.titleStyle,
                ),
              ],
            ),
            softWrap: false,
            overflow: detailsTheme.titleMaxLines == 1 ? TextOverflow.fade : TextOverflow.ellipsis,
            maxLines: detailsTheme.titleMaxLines,
            // `textScaler` is applied to font size and icon size at the theme level,
            // otherwise the leading icon will be low-res scaled up/down
            textScaler: TextScaler.noScaling,
          ),
          if (!locked) ...[
            const SizedBox(height: FilterListDetailsTheme.titleDetailPadding),
            if (detailsTheme.showDate) _buildDateRow(context, detailsTheme, hasTitleLeading),
            if (detailsTheme.showCount) _buildCountRow(context, detailsTheme, hasTitleLeading),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, FilterListDetailsThemeData detailsTheme, bool hasTitleLeading) {
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);
    final date = entry?.bestDate;
    final dateText = date != null ? formatDateTime(date, context.locale, use24hour) : AText.valueNotAvailable;

    Widget leading = const Icon(AIcons.date);
    if (hasTitleLeading) {
      leading = ConstrainedBox(
        constraints: BoxConstraints(minWidth: detailsTheme.titleIconSize),
        child: leading,
      );
    }
    return IconTheme.merge(
      data: detailsTheme.captionIconTheme,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateText,
              style: detailsTheme.captionStyle,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountRow(BuildContext context, FilterListDetailsThemeData detailsTheme, bool hasTitleLeading) {
    final _filter = filter;
    final removableStorage = _filter is AlbumFilter && androidFileUtils.isOnRemovableStorage(_filter.album);

    List<Widget> leadingIcons = [
      if (pinned) const Icon(AIcons.pin),
      if (removableStorage) const Icon(AIcons.storageCard),
    ];

    Widget? leading;
    if (leadingIcons.isNotEmpty) {
      leading = Row(
        children: leadingIcons
            .mapIndexed((i, child) => i > 0
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: child,
                  )
                : child)
            .toList(),
      );
    }

    leading = ConstrainedBox(
      constraints: BoxConstraints(minWidth: hasTitleLeading ? detailsTheme.titleIconSize : detailsTheme.captionIconTheme.size!),
      child: Center(child: leading ?? const SizedBox()),
    );

    final source = context.read<CollectionSource>();

    return IconTheme.merge(
      data: detailsTheme.captionIconTheme,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Text(
            '${context.l10n.itemCount(source.count(filter))} • ${formatFileSize(context.locale, source.size(filter))}',
            style: detailsTheme.captionStyle,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }
}
