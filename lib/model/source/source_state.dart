import 'package:aves/model/source/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ExtraSourceState on SourceState {
  String? getName(AppLocalizations l10n) {
    switch (this) {
      case SourceState.loading:
        return l10n.sourceStateLoading;
      case SourceState.cataloguing:
        return l10n.sourceStateCataloguing;
      case SourceState.locatingCountries:
        return l10n.sourceStateLocatingCountries;
      case SourceState.locatingPlaces:
        return l10n.sourceStateLocatingPlaces;
      case SourceState.ready:
        return null;
    }
  }
}
