import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class MissingFilter extends CollectionFilter {
  static const type = 'missing';

  static const _date = 'date';
  static const _fineAddress = 'fine_address';
  static const _title = 'title';

  final String metadataType;
  late final IconData _icon;
  late final EntryPredicate _test;

  static final date = MissingFilter._private(_date);
  static final fineAddress = MissingFilter._private(_fineAddress);
  static final title = MissingFilter._private(_title);

  @override
  List<Object?> get props => [metadataType, reversed];

  MissingFilter._private(this.metadataType, {super.reversed = false}) {
    switch (metadataType) {
      case _date:
        _test = (entry) => (entry.catalogMetadata?.dateMillis ?? 0) == 0;
        _icon = AIcons.dateUndated;
      case _fineAddress:
        _test = (entry) => entry.hasGps && !entry.hasFineAddress;
        _icon = AIcons.locationUnlocated;
      case _title:
        _test = (entry) => (entry.catalogMetadata?.xmpTitle ?? '').isEmpty;
        _icon = AIcons.descriptionUntitled;
    }
  }

  factory MissingFilter.fromMap(Map<String, dynamic> json) {
    return MissingFilter._private(
      json['metadataType'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'metadataType': metadataType,
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => metadataType;

  @override
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (metadataType) {
      _date => l10n.filterNoDateLabel,
      _fineAddress => l10n.filterNoAddressLabel,
      _title => l10n.filterNoTitleLabel,
      _ => metadataType,
    };
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(_icon, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$metadataType';
}
