import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class AspectRatioFilter extends CollectionFilter {
  static const type = 'aspect_ratio';

  final double threshold;
  final String op;
  late final EntryFilter _test;

  static final landscape = AspectRatioFilter(1, QueryFilter.opGreater);
  static final portrait = AspectRatioFilter(1, QueryFilter.opLower);

  @override
  List<Object?> get props => [threshold, op, reversed];

  AspectRatioFilter(this.threshold, this.op, {super.reversed = false}) {
    switch (op) {
      case QueryFilter.opEqual:
        _test = (entry) => entry.displayAspectRatio == threshold;
        break;
      case QueryFilter.opLower:
        _test = (entry) => entry.displayAspectRatio < threshold;
        break;
      case QueryFilter.opGreater:
        _test = (entry) => entry.displayAspectRatio > threshold;
        break;
    }
  }

  factory AspectRatioFilter.fromMap(Map<String, dynamic> json) {
    return AspectRatioFilter(
      json['threshold'] as double,
      json['op'] as String,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'threshold': threshold,
        'op': op,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

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
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    return Icon(AIcons.aspectRatio, size: size);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$threshold-$op';
}
