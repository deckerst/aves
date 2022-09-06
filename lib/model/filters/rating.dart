import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class RatingFilter extends CollectionFilter {
  static const type = 'rating';

  final int rating;

  @override
  List<Object?> get props => [rating];

  const RatingFilter(this.rating);

  factory RatingFilter.fromMap(Map<String, dynamic> json) {
    return RatingFilter(
      json['rating'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'rating': rating,
      };

  @override
  EntryFilter get test => (entry) => entry.rating == rating;

  @override
  String get universalLabel => '$rating';

  @override
  String getLabel(BuildContext context) => formatRating(context, rating);

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    switch (rating) {
      case -1:
        return Icon(AIcons.ratingRejected, size: size);
      case 0:
        return Icon(AIcons.ratingUnrated, size: size);
      default:
        return null;
    }
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$rating';

  static String formatRating(BuildContext context, int rating) {
    switch (rating) {
      case -1:
        return context.l10n.filterRatingRejectedLabel;
      case 0:
        return context.l10n.filterNoRatingLabel;
      default:
        return '\u2B50' * rating;
    }
  }
}
