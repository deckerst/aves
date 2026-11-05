import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class const AspectRatioFilter(
  final double threshold,
  final String op, {
  super.reversed = false,
}) extends CollectionFilter {
  static const type = 'aspect_ratio';

  static const landscape = AspectRatioFilter(1, QueryFilter.opGreater);
  static const portrait = AspectRatioFilter(1, QueryFilter.opLower);

  @override
  List<Object?> get props => [threshold, op, reversed];

  factory fromMap(Map<String, Object?> json) {
    return AspectRatioFilter(
      json['threshold'] as double,
      json['op'] as String,
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
    'type': type,
    'threshold': threshold,
    'op': op,
    if (reversed) 'reversed': reversed,
  };

  @override
  EntryPredicate get positiveTest {
    switch (op) {
      case QueryFilter.opEqual:
        return (entry) => entry.displayAspectRatio == threshold;
      case QueryFilter.opLower:
        return (entry) => entry.displayAspectRatio < threshold;
      case QueryFilter.opGreater:
        return (entry) => entry.displayAspectRatio > threshold;
    }
    return (entry) => false;
  }

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => '$op $threshold';

  @override
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    if (threshold == 1) {
      switch (op) {
        case QueryFilter.opGreater:
          return l10n.filterAspectRatioLandscapeLabel;
        case QueryFilter.opLower:
          return l10n.filterAspectRatioPortraitLabel;
      }
    }
    return universalLabel;
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    final isPortrait = op == QueryFilter.opLower;
    return RotatedBox(
      quarterTurns: isPortrait ? 1 : 0,
      child: Icon(AIcons.aspectRatioLandscape, size: size),
    );
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$threshold-$op';
}
