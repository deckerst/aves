import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class PlaceholderFilter extends CollectionFilter {
  static const type = 'placeholder';

  static const _country = 'country';
  static const _state = 'state';
  static const _place = 'place';

  final String placeholder;
  late final IconData _icon;

  static final country = PlaceholderFilter._private(_country);
  static final state = PlaceholderFilter._private(_state);
  static final place = PlaceholderFilter._private(_place);

  @override
  List<Object?> get props => [placeholder];

  PlaceholderFilter._private(this.placeholder) : super(reversed: false) {
    switch (placeholder) {
      case _country:
        _icon = AIcons.country;
      case _state:
        _icon = AIcons.state;
      case _place:
        _icon = AIcons.place;
    }
  }

  factory PlaceholderFilter.fromMap(Map<String, dynamic> json) {
    return PlaceholderFilter._private(
      json['placeholder'],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'placeholder': placeholder,
      };

  Future<String?> toTag(AvesEntry entry) async {
    switch (placeholder) {
      case _country:
      case _state:
      case _place:
        if (!entry.isCatalogued) {
          await entry.catalog(background: false, force: false, persist: true);
        }
        if (!entry.hasGps) return null;

        if (!entry.hasFineAddress) {
          await entry.locate(background: false, force: false, geocoderLocale: settings.appliedLocale);
        }
        final address = entry.addressDetails;
        if (address == null) return null;

        switch (placeholder) {
          case _country:
            return address.countryName;
          case _state:
            return address.stateName;
          case _place:
            return address.place;
        }
    }
    return null;
  }

  @override
  EntryFilter get positiveTest => (entry) => throw Exception('this is not a test');

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => placeholder;

  @override
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (placeholder) {
      _country => l10n.tagPlaceholderCountry,
      _state => l10n.tagPlaceholderState,
      _place => l10n.tagPlaceholderPlace,
      _ => placeholder,
    };
  }

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(_icon, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$placeholder';
}
