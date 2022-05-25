import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:flutter/material.dart';

class RatingSectionHeader<T> extends StatelessWidget {
  final int rating;

  const RatingSectionHeader({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: EntryRatingSectionKey(rating),
      title: RatingFilter.formatRating(context, rating),
    );
  }
}
