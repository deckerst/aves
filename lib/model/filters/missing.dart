import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class MissingFilter extends CollectionFilter {
  static const type = 'missing';

  static const _date = 'date';
  static const _title = 'title';

  final String metadataType;
  late final EntryFilter _test;
  late final IconData _icon;

  static final date = MissingFilter._private(_date);
  static final title = MissingFilter._private(_title);

  @override
  List<Object?> get props => [metadataType];

  MissingFilter._private(this.metadataType) {
    switch (metadataType) {
      case _date:
        _test = (entry) => (entry.catalogMetadata?.dateMillis ?? 0) == 0;
        _icon = AIcons.dateUndated;
        break;
      case _title:
        _test = (entry) => (entry.catalogMetadata?.xmpTitle ?? '').isEmpty;
        _icon = AIcons.descriptionUntitled;
        break;
    }
  }

  factory MissingFilter.fromMap(Map<String, dynamic> json) {
    return MissingFilter._private(
      json['metadataType'],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'metadataType': metadataType,
      };

  @override
  EntryFilter get test => _test;

  @override
  String get universalLabel => metadataType;

  @override
  String getLabel(BuildContext context) {
    switch (metadataType) {
      case _date:
        return context.l10n.filterNoDateLabel;
      case _title:
        return context.l10n.filterNoTitleLabel;
      default:
        return metadataType;
    }
  }

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(_icon, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$metadataType';
}
