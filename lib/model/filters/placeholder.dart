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

  static const country = PlaceholderFilter._private(_country);
  static const state = PlaceholderFilter._private(_state);
  static const place = PlaceholderFilter._private(_place);

  @override
  List<Object?> get props => [placeholder];

  const new _private(this.placeholder) : super(reversed: false);

  factory fromMap(Map<String, Object?> json) {
    return PlaceholderFilter._private(
      json['placeholder'] as String,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
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
          await entry.locate(
            background: false,
            force: false,
            geocoderLocale: settings.avesLocale,
          );
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
  EntryPredicate get positiveTest =>
      (entry) => throw Exception('this is not a test');

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

  IconData? getIcon() {
    switch (placeholder) {
      case _country:
        return AIcons.country;
      case _state:
        return AIcons.state;
      case _place:
        return AIcons.place;
    }
    return null;
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(getIcon(), size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$placeholder';
}
