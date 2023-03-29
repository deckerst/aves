import 'package:aves/l10n/l10n.dart';
import 'package:aves_model/aves_model.dart';

extension ExtraSourceStateView on SourceState {
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
