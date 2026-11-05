import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/collection/grid/headers/album.dart';
import 'package:aves/widgets/collection/grid/headers/date.dart';
import 'package:aves/widgets/collection/grid/headers/rating.dart';
import 'package:material_ui/material_ui.dart';

class const CollectionSectionHeader({
  super.key,
  required final CollectionLens collection,
  required final SectionKey sectionKey,
  required final double height,
  required final bool selectable,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final header = _buildHeader(context);
    return header != null
        ? SizedBox(
            height: height,
            child: header,
          )
        : const SizedBox();
  }

  Widget? _buildHeader(BuildContext context) {
    switch (collection.sortFactor) {
      case .date:
        switch (collection.sectionFactor) {
          case .album:
            return _buildAlbumHeader(context);
          case .month:
            var k = sectionKey as EntryDateSectionKey;
            final date = collection.calendar.ops.fromYearMonthDay(k.year, k.month, k.day);
            return MonthSectionHeader<AvesEntry>(
              key: ValueKey(sectionKey),
              sectionKey: sectionKey,
              date: date,
              selectable: selectable,
            );
          case .day:
            var k = sectionKey as EntryDateSectionKey;
            final date = collection.calendar.ops.fromYearMonthDay(k.year, k.month, k.day);
            return DaySectionHeader<AvesEntry>(
              key: ValueKey(sectionKey),
              sectionKey: sectionKey,
              date: date,
              selectable: selectable,
            );
          case .none:
            break;
          case .name:
          case .rating:
            throw UnimplementedError();
        }
      case .albumItemName:
      case .path:
        return _buildAlbumHeader(context);
      case .rating:
        return RatingSectionHeader<AvesEntry>(
          key: ValueKey(sectionKey),
          rating: (sectionKey as EntryRatingSectionKey).rating,
          selectable: selectable,
        );
      case .size:
      case .duration:
      case .random:
        break;
      case .chipName:
      case .count:
        throw UnimplementedError();
    }
    return null;
  }

  Widget _buildAlbumHeader(BuildContext context) {
    final source = collection.source;
    final directory = (sectionKey as EntryAlbumSectionKey).directory;
    return AlbumSectionHeader(
      key: ValueKey(sectionKey),
      directory: directory,
      albumName: directory != null ? source.getStoredAlbumDisplayName(context, directory) : null,
      selectable: selectable,
    );
  }
}
