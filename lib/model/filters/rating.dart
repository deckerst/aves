import 'package:aves/model/filters/filters.dart';
import 'package:aves/ref/unicode.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class RatingFilter extends CollectionFilter {
  static const type = 'rating';

  final int rating;
  final String op;
  late final EntryFilter _test;

  static const opEqual = '=';
  static const opOrLower = '<=';
  static const opOrGreater = '>=';

  @override
  List<Object?> get props => [rating, op, reversed];

  RatingFilter(this.rating, {this.op = opEqual, super.reversed = false}) {
    _test = switch (op) {
      opOrLower => (entry) => entry.rating <= rating && entry.rating > 0,
      opOrGreater => (entry) => entry.rating >= rating,
      opEqual || _ => (entry) => entry.rating == rating,
    };
  }

  RatingFilter copyWith(String op) => RatingFilter(
        rating,
        op: op,
        reversed: reversed,
      );

  factory RatingFilter.fromMap(Map<String, dynamic> json) {
    return RatingFilter(
      json['rating'] ?? 0,
      op: json['op'] ?? opEqual,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'rating': rating,
        'op': op,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => '$op $rating';

  @override
  String getLabel(BuildContext context) => switch (op) {
        opOrLower || opOrGreater => '${UniChars.whiteMediumStar} ${formatRatingRange(context, rating, op)}',
        opEqual || _ => formatRating(context, rating),
      };

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return switch (rating) {
      -1 => Icon(AIcons.ratingRejected, size: size),
      0 => Icon(AIcons.ratingUnrated, size: size),
      _ => null,
    };
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$rating-$op';

  static String formatRating(BuildContext context, int rating) {
    return switch (rating) {
      -1 => context.l10n.filterRatingRejectedLabel,
      0 => context.l10n.filterNoRatingLabel,
      _ => UniChars.whiteMediumStar * rating,
    };
  }

  static String formatRatingRange(BuildContext context, int rating, String op) {
    return switch (op) {
      opOrLower => '1~$rating',
      opOrGreater => '$rating~5',
      opEqual || _ => '$rating',
    };
  }
}
