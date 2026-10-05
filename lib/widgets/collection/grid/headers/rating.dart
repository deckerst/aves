import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:material_ui/material_ui.dart';

class const RatingSectionHeader<T>({
  super.key,
  required final int rating,
  required final bool selectable,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: EntryRatingSectionKey(rating),
      title: RatingFilter.formatRating(context, rating),
      selectable: selectable,
    );
  }
}
